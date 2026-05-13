-- latex-math-preview.lua
--
-- This file is one lazy.nvim plugin spec. It is a "local" plugin: lazy.nvim
-- does not download anything from GitHub. Instead, this file returns a normal
-- plugin table at the bottom, and lazy.nvim calls M.setup() when a tex/typst
-- buffer opens.
--
-- What the plugin does:
--   * LaTeX: preview math, tikzcd, table, and figure snippets under the cursor.
--   * Typst: preview only $...$ math and #image(...) calls under the cursor.
--   * Draw the PNG with Neovim's experimental vim.ui.img API.
--   * Reserve virtual lines below the source so the image has a place to sit.
--
-- Important mental model:
--   vim.ui.img does not insert text into the buffer. It paints a terminal image
--   over the UI, more like a tiny floating picture. That is why this plugin must
--   keep recalculating the screen row/column during redraws and scrolling.

local M = {}

local ns = vim.api.nvim_create_namespace("math_preview")

local file_patterns = { "*.tex", "*.md", "*.typ" }

local config = {
        -- Used by both pdftocairo and typst when producing PNG files.
        dpi = 300,

        -- Neovim does not expose terminal cell size in a portable way. This value
        -- converts image pixel height into terminal rows. You can override it from
        -- init.lua with:
        --   vim.g.latex_math_preview_cell_height_px  = 22
        cell_height_px = tonumber(vim.g.latex_math_preview_cell_height_px) or 24,

        -- Delay before starting an expensive LaTeX compile. Typst uses a much shorter
        -- fixed delay because its compiler is fast and there is no cache.
        compile_delay_ms = tonumber(vim.g.latex_math_preview_compile_delay_ms) or 80,

        -- A very low zindex keeps terminal images below completion popups/statusline
        -- in terminals that support image layering.
        zindex = tonumber(vim.g.latex_math_preview_zindex) or -1073741825,
}

-- Runtime state for the one visible hover preview.
local state = {
        img_id       = nil, -- id returned by vim.ui.img.set()
        range        = nil, -- { start_line, start_col, end_line, end_col }
        hash         = nil, -- stable id of the currently displayed source/render body
        last_pos     = { row = nil, col = nil },
        pending_jobs = {}, -- LaTeX jobs keyed by hash
        generation   = 0,  -- cancellation token for delayed callbacks
        render_all   = { running = false, cancelled = false },
}

local tex_template = [[
\documentclass[preview,border=1pt,varwidth]{standalone}
\usepackage{amsmath,mathtools,nicematrix,xcolor,libertinus-otf,graphicx}
%s
\begin{document}
{ \Large \selectfont
  \color[HTML]{FFFFFF}
%s
}
\end{document}
]]

local typst_template = [[
#set page(width: auto, height: auto, margin: 1pt, fill: none)
#set text(fill: white, size: 18pt)
%s
]]

-- ---------------------------------------------------------------------------
-- Tiny Generic Helpers
-- ---------------------------------------------------------------------------

local function trim(s)
        return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function notifyError(opts, msg)
        if not (opts and opts.silent) then
                vim.notify(msg, vim.log.levels.ERROR)
        end
end

local function cacheDir()
        return vim.fn.stdpath("cache") .. "/math-preview"
end

local function documentDir(buf)
        local name = vim.api.nvim_buf_get_name(buf)
        if name == "" then
                return ""
        end
        return vim.fn.fnamemodify(name, ":p:h")
end

-- A range is stored as:
--   { start_line, start_col, end_line, end_col }
-- Lines are 1-indexed because screenpos() and nvim_win_get_cursor() use
-- 1-indexed lines. Columns are byte columns, mostly from Treesitter.
local function cursorInRange(cursor, range)
        if not range then
                return false
        end

        if range[1] == range[3] then
                return cursor[1] == range[1] and cursor[2] >= range[2] and cursor[2] <= range[4]
        end

        return cursor[1] >= range[1] and cursor[1] <= range[3]
end

local function sameStart(a, b)
        return a and b and a[1] == b[1] and a[2] == b[2]
end

local function lineCount(text)
        local _, n = text:gsub("\n", "\n")
        return n + 1
end

local function readFileBytes(path)
        local ok, bytes = pcall(vim.fn.readblob, path)
        if ok and bytes then
                return bytes
        end

        local file = io.open(path, "rb")
        if not file then
                return nil
        end

        bytes = file:read("*a")
        file:close()
        return bytes
end

-- PNG files store width/height in the IHDR chunk at fixed byte positions. This
-- avoids shelling out to identify/magick just to know how tall the image is.
local function pngSize(bytes)
        if type(bytes) ~= "string" or #bytes < 24 or bytes:sub(1, 8) ~= "\137PNG\r\n\26\n" then
                return 0, 0
        end

        local w = bytes:byte(17) * 16777216 + bytes:byte(18) * 65536 + bytes:byte(19) * 256 + bytes:byte(20)
        local h = bytes:byte(21) * 16777216 + bytes:byte(22) * 65536 + bytes:byte(23) * 256 + bytes:byte(24)
        return w, h
end

local function imageHeightCells(pngH, minimumLines)
        local by_pixels = math.max(1, math.ceil(pngH / config.cell_height_px))
        return math.max(by_pixels, (minimumLines or 1) * 2)
end

-- ---------------------------------------------------------------------------
-- Terminal Image Placement
-- ---------------------------------------------------------------------------

local function clearPreview()
        if state.img_id and vim.ui and vim.ui.img then
                pcall(vim.ui.img.del, state.img_id)
        end

        state.img_id       = nil
        state.range        = nil
        state.hash         = nil
        state.last_pos.row = nil
        state.last_pos.col = nil
        state.generation   = state.generation + 1

        pcall(vim.api.nvim_buf_clear_namespace, 0, ns, 0, -1)
end

-- Virtual lines are attached after the source range. The image itself is drawn
-- by the terminal, so these fake lines are what make room in the buffer layout.
local function setVirtualSpace(winid, range, heightCells)
        local virt_lines  = {}
        local border_line = string.rep("─", vim.api.nvim_win_get_width(winid) - 4)

        table.insert(virt_lines, { { border_line, "Comment" } })
        for _ = 1, heightCells do
                table.insert(virt_lines, { { "", "Normal" } })
        end
        table.insert(virt_lines, { { border_line, "Comment" } })

        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        vim.api.nvim_buf_set_extmark(0, ns, range[3] - 1, 0, {
                virt_lines = virt_lines,
        })
end

local function previewAnchorScreenpos(winid, range)
        -- If a source line wraps on screen, virtual lines appear after the final
        -- wrapped screen row. Anchoring to the logical line end matches that behavior.
        local line = vim.api.nvim_buf_get_lines(0, range[3] - 1, range[3], false)[1] or ""
        local pos  = vim.fn.screenpos(winid, range[3], math.max(#line, 1))
        if pos.row ~= 0 then
                return pos
        end

        return vim.fn.screenpos(winid, range[3], range[2] + 1)
end

local function updateImgPos(winid)
        if not state.img_id or not state.range then
                return
        end

        winid            = winid or vim.api.nvim_get_current_win()
        local pos        = previewAnchorScreenpos(winid, state.range)
        local target_row = pos.row == 0 and 9999 or pos.row + 2
        local target_col = pos.row == 0 and 1 or 2

        if state.last_pos.row == target_row and state.last_pos.col == target_col then
                return
        end

        state.last_pos.row = target_row
        state.last_pos.col = target_col
        pcall(vim.ui.img.set, state.img_id, { row = target_row, col = target_col })
end

local function previewIsCurrent(hash, range)
        return state.range
                   and state.hash == hash
                   and sameStart(state.range, range)
                   and cursorInRange(vim.api.nvim_win_get_cursor(0), state.range)
end

-- Prepare state for a render attempt. Return false when the requested preview
-- is already shown and only needed a position refresh.
local function beginPreview(obj, hash, opts)
        local same_range = sameStart(state.range, obj.range) and
                   cursorInRange(vim.api.nvim_win_get_cursor(0), obj.range)

        if same_range and state.hash == hash then
                updateImgPos()
                return false
        end

        if not same_range or not (opts and opts.keep_old) then
                clearPreview()
        else
                state.generation = state.generation + 1
        end

        state.range = obj.range
        state.hash  = hash
        return true
end

local function showPngBytes(bytes, hash, range, minimumLines, opts)
        if not previewIsCurrent(hash, range) or not bytes or not (vim.ui and vim.ui.img) then
                return
        end

        local winid = vim.api.nvim_get_current_win()
        local pos   = previewAnchorScreenpos(winid, range)
        if pos.row == 0 then
                return
        end

        local _, png_h     = pngSize(bytes)
        local height_cells = imageHeightCells(png_h > 0 and png_h or 92, minimumLines)
        local old_img_id   = state.img_id

        -- Create the new image before deleting the old one. This keeps live editing
        -- from flashing blank between successful renders.
        local ok, img_id = pcall(vim.ui.img.set, bytes, {
                row    = pos.row + 2,
                col    = 2,
                height = height_cells,
                zindex = config.zindex,
        })

        if not ok then
                return notifyError(opts, "vim.ui.img.set failed: " .. tostring(img_id))
        end

        state.img_id = img_id
        if old_img_id and old_img_id ~= img_id then
                pcall(vim.ui.img.del, old_img_id)
        end

        pcall(setVirtualSpace, winid, range, height_cells)
        vim.schedule(updateImgPos)
end

local function showPngFile(path, hash, range, minimumLines, opts, cleanup)
        if not previewIsCurrent(hash, range) then
                if cleanup then
                        cleanup()
                end
                return
        end

        local bytes = readFileBytes(path)
        if cleanup then
                cleanup()
        end

        showPngBytes(bytes, hash, range, minimumLines, opts)
end

local function deferCurrent(delayMs, hash, range, callback, cleanup)
        state.generation = state.generation + 1
        local generation = state.generation

        vim.defer_fn(function()
                             if generation ~= state.generation or not previewIsCurrent(hash, range) then
                                     if cleanup then
                                             cleanup()
                                     end
                                     return
                             end

                             callback()
                     end, delayMs)
end

-- ---------------------------------------------------------------------------
-- LaTeX Object Detection
-- ---------------------------------------------------------------------------

local function latexEnvironmentName(text)
        return text:match("^%s*\\begin%s*{%s*([%a%-%*]+)%s*}")
end

local function baseEnvironmentName(name)
        return name and name:gsub("%*$", "") or nil
end

local function isLatexMathNode(nodeType)
        return nodeType == "inline_formula" or nodeType == "displayed_equation" or nodeType == "math_environment"
end

local function isLatexPreviewEnvironment(name)
        name = baseEnvironmentName(name)
        return name == "tikzcd" or name == "tikz-cd" or name == "figure" or name == "table"
end

local function nodeRange(node)
        local start_row, start_col, end_row, end_col = node:range()
        return { start_row + 1, start_col, end_row + 1, end_col }
end

local function objectFromLatexNode(buf, node)
        local node_type = node:type()
        local text      = vim.treesitter.get_node_text(node, buf)

        if isLatexMathNode(node_type) then
                return { kind = "latex", text = text, node_type = node_type, range = nodeRange(node) }
        end

        if node_type:find("environment", 1, true) then
                local env = baseEnvironmentName(latexEnvironmentName(text))
                if isLatexPreviewEnvironment(env) then
                        return { kind = "latex", text = text, node_type = node_type, env = env, range = nodeRange(node) }
                end
        end

        return nil
end

local function findLatexContainer(buf, node)
        local current = node
        while current do
                if current:type():find("environment", 1, true) then
                        local text = vim.treesitter.get_node_text(current, buf)
                        local env  = baseEnvironmentName(latexEnvironmentName(text))
                        if env == "table" or env == "figure" then
                                return current
                        end
                end
                current = current:parent()
        end
        return nil
end

local function getLatexAtCursor()
        local buf      = vim.api.nvim_get_current_buf()
        local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf })
        if not ok or not node then
                return nil
        end

        -- Tables and figures are treated as simple containers. If the cursor is
        -- anywhere inside one, render the whole outer environment and do not inspect
        -- inner tabular/tikzpicture/includegraphics nodes.
        local container = findLatexContainer(buf, node)
        if container then
                return objectFromLatexNode(buf, container)
        end

        while node do
                local obj = objectFromLatexNode(buf, node)
                if obj then
                        return obj
                end
                node = node:parent()
        end

        return nil
end

-- ---------------------------------------------------------------------------
-- Typst Object Detection
-- ---------------------------------------------------------------------------

local function lineOffsets(lines)
        local offsets = {}
        local pos     = 1
        for i, line in ipairs(lines) do
                offsets[i] = pos
                pos        = pos + #line + 1
        end
        return offsets
end

local function absToLineCol(offsets, lines, absPos)
        for i = #offsets, 1, -1 do
                if absPos >= offsets[i] then
                        return i, math.min(absPos - offsets[i], #lines[i])
                end
        end
        return 1, 0
end

local function cursorAbsPos(lines, cursor)
        local offsets = lineOffsets(lines)
        local line    = lines[cursor[1]] or ""
        local base    = offsets[cursor[1]] or 1
        return base + math.min(cursor[2], #line), offsets
end

local function isEscapedAt(s, pos)
        local count = 0
        local i     = pos - 1
        while i >= 1 and s:sub(i, i) == "\\" do
                count = count + 1
                i     = i - 1
        end
        return count % 2 == 1
end

local function findMatchingParen(s, openPos)
        local depth   = 0
        local quote   = nil
        local escaped = false

        for i = openPos, #s do
                local ch = s:sub(i, i)

                if quote then
                        if escaped then
                                escaped = false
                        elseif ch == "\\" then
                                escaped = true
                        elseif ch == quote then
                                quote = nil
                        end
                elseif ch == '"' or ch == "'" then
                        quote = ch
                elseif ch == "(" then
                        depth = depth + 1
                elseif ch == ")" then
                        depth = depth - 1
                        if depth == 0 then
                                return i
                        end
                end
        end

        return nil
end

local function typstObjectRange(offsets, lines, startPos, endPos)
        local start_line, start_col = absToLineCol(offsets, lines, startPos)
        local end_line, end_col     = absToLineCol(offsets, lines, endPos + 1)
        return { start_line, start_col, end_line, end_col }
end

local function findTypstImage(fullText, offsets, lines, cursorAbs)
        local search = 1
        while true do
                local start_pos, call_end = fullText:find("#image%s*%(", search)
                if not start_pos then
                        return nil
                end

                local open_pos = fullText:find("%(", call_end)
                local end_pos  = open_pos and findMatchingParen(fullText, open_pos)
                if end_pos and cursorAbs >= start_pos and cursorAbs <= end_pos then
                        return {
                                kind      = "typst",
                                node_type = "typst_image",
                                text      = fullText:sub(start_pos, end_pos),
                                range     = typstObjectRange(offsets, lines, start_pos, end_pos),
                        }
                end

                search = (end_pos or call_end) + 1
        end
end

local function findTypstMath(fullText, offsets, lines, cursorAbs)
        local start_pos = nil
        for i = cursorAbs, 1, -1 do
                if fullText:sub(i, i) == "$" and not isEscapedAt(fullText, i) then
                        start_pos = i
                        break
                end
        end
        if not start_pos then
                return nil
        end

        local end_pos = nil
        for i = start_pos + 1, #fullText do
                if fullText:sub(i, i) == "$" and not isEscapedAt(fullText, i) then
                        end_pos = i
                        break
                end
        end
        if not end_pos or cursorAbs > end_pos then
                return nil
        end

        return {
                kind      = "typst",
                node_type = "typst_math",
                text      = fullText:sub(start_pos, end_pos),
                range     = typstObjectRange(offsets, lines, start_pos, end_pos),
        }
end

local function getTypstAtCursor()
        local buf                 = vim.api.nvim_get_current_buf()
        local lines               = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local full_text           = table.concat(lines, "\n")
        local cursor_abs, offsets = cursorAbsPos(lines, vim.api.nvim_win_get_cursor(0))

        -- Insert mode can put the cursor byte just after the visual cursor position.
        -- Trying nearby bytes keeps live preview working at the edges of $...$.
        local candidates = {
                cursor_abs,
                math.max(1, cursor_abs - 1),
                math.min(#full_text, cursor_abs + 1),
        }

        local tried = {}
        for _, pos in ipairs(candidates) do
                if not tried[pos] then
                        tried[pos] = true
                        local obj  = findTypstImage(full_text, offsets, lines, pos) or
                                   findTypstMath(full_text, offsets, lines, pos)
                        if obj then
                                return obj
                        end
                end
        end

        return nil
end

-- ---------------------------------------------------------------------------
-- LaTeX Document Building
-- ---------------------------------------------------------------------------

local function stripLatexDelimiters(s)
        s = trim(s)

        for _, pattern in ipairs({
                "^%$%$(.*)%$%$$", -- $$ ... $$
                "^\\%[(.*)\\%]$", -- \[ ... \]
                "^%$(.*)%$$",     -- $ ... $
                "^\\%((.*)\\%)$", -- \( ... \)
        }) do
                local inner = s:match(pattern)
                if inner then
                        return trim(inner)
                end
        end

        return s
end

local function normalizeLatexMath(s)
        s = stripLatexDelimiters(s)

        local env, body = s:match("^\\begin%s*{%s*([%a*]+)%s*}(.*)\\end%s*{%s*%1%s*}%s*$")
        if not env then
                return s
        end

        env  = env:gsub("%*$", "")
        body = trim(body)

        if env == "equation" then
                return body
        elseif env == "align" then
                return "\\begin{aligned}" .. body .. "\\end{aligned}"
        elseif env == "gather" or env == "multline" then
                return "\\begin{gathered}" .. body .. "\\end{gathered}"
        end

        return s
end

local function latexLineCount(s)
        local count = 1
        for _ in s:gmatch("\\\\") do
                count = count + 1
        end
        return count
end

local function documentTikzLibraries(buf)
        local libs, seen = {}, {}
        for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
                for raw in line:gmatch("\\usetikzlibrary%s*{([^}]+)}") do
                        for lib in raw:gmatch("[^,%s]+") do
                                if not seen[lib] then
                                        seen[lib] = true
                                        table.insert(libs, lib)
                                end
                        end
                end
        end

        return #libs > 0 and "\\usetikzlibrary{" .. table.concat(libs, ",") .. "}" or ""
end

local function documentGraphicsPath(buf)
        local dir = documentDir(buf)
        if dir == "" then
                return ""
        end

        dir = dir:gsub("\\", "/")
        if not dir:match("/$") then
                dir = dir .. "/"
        end
        return "\\graphicspath{{" .. dir .. "}}"
end

local function unwrapLatexEnvironment(s, env)
        for _, suffix in ipairs({ "", "%*" }) do
                local begin_pat = "\\begin%s*{%s*" .. env .. suffix .. "%s*}"
                local end_pat   = "\\end%s*{%s*" .. env .. suffix .. "%s*}"
                local body      = s:match("^%s*" .. begin_pat .. "%s*%b[]%s*(.-)%s*" .. end_pat .. "%s*$")
                           or s:match("^%s*" .. begin_pat .. "%s*(.-)%s*" .. end_pat .. "%s*$")
                if body then
                        return trim(body)
                end
        end
        return s
end

local function captionToPlainText(s)
        s = s:gsub("\\caption%s*%b[]%s*(%b{})", "\\par\\smallskip\\noindent\\textit%1")
        return s:gsub("\\caption%s*(%b{})", "\\par\\smallskip\\noindent\\textit%1")
end

local function latexRenderSetup(s, buf)
        local env = baseEnvironmentName(latexEnvironmentName(s))

        if env == "tikzcd" or env == "tikz-cd" then
                return table.concat({
                                            "\\usepackage{tikz-cd}",
                                            documentTikzLibraries(buf),
                                    }, "\n"), s
        end

        if env == "figure" then
                return table.concat({
                                            "\\usepackage{tikz}",
                                            "\\usepackage{mwe}",
                                            documentGraphicsPath(buf),
                                            documentTikzLibraries(buf),
                                    }, "\n"), captionToPlainText(unwrapLatexEnvironment(s, "figure"))
        end

        if env == "table" then
                return table.concat({
                                            "\\usepackage{array}",
                                            "\\usepackage{booktabs}",
                                            "\\usepackage{tabularx}",
                                            "\\usepackage{longtable}",
                                            "\\usepackage{multirow}",
                                            "\\usepackage{makecell}",
                                    }, "\n"), captionToPlainText(unwrapLatexEnvironment(s, "table"))
        end

        return "", "\\(\\displaystyle " .. s .. "\\)"
end

local function makeLatexTask(buf, obj)
        -- A task is a complete recipe for producing one LaTeX PNG. Separating this
        -- from rendering keeps the rest of the code simple: hover preview and
        -- :LatexMathPreviewRenderAll can both use the same task structure.
        local normalized     = normalizeLatexMath(obj.text)
        local preamble, body = latexRenderSetup(normalized, buf)
        local hash           = vim.fn.sha256(preamble .. "\n" .. body)
        local dir            = cacheDir()

        return {
                obj        = obj,
                hash       = hash,
                range      = obj.range,
                line_count = latexLineCount(normalized),
                tex_file   = dir .. "/" .. hash .. ".tex",
                pdf_file   = dir .. "/" .. hash .. ".pdf",
                png_file   = dir .. "/" .. hash .. ".png",
                png_prefix = dir .. "/" .. hash,
                tmpdir     = dir,
                preamble   = preamble,
                body       = body,
        }
end

local function writeLatexTask(task)
        vim.fn.mkdir(task.tmpdir, "p")
        vim.fn.writefile(vim.split(string.format(tex_template, task.preamble, task.body), "\n"), task.tex_file)
end

-- ---------------------------------------------------------------------------
-- Typst Document Building
-- ---------------------------------------------------------------------------

local function typstEscapeStringPath(path)
        return path:gsub("\\", "\\\\"):gsub('"', '\\"')
end

local function typstRewriteImagePaths(s, buf)
        local dir = documentDir(buf)
        if dir == "" then
                return s
        end

        return s:gsub('(#image%s*%(%s*)"([^"]+)"', function(prefix, path)
                if path:match("^/") or path:match("^%a+://") then
                        return prefix .. '"' .. path .. '"'
                end

                local absolute = vim.fn.fnamemodify(dir .. "/" .. path, ":p")
                return prefix .. '"' .. typstEscapeStringPath(absolute) .. '"'
        end)
end

local function typstTempFiles()
        local base = vim.fn.tempname()
        return base .. ".typ", base .. ".png"
end

local function makeTypstTask(buf, obj)
        -- Typst tasks are deliberately smaller than LaTeX tasks. There is no cache
        -- and no PDF conversion step because typst compile can write PNG directly.
        local body = obj.text
        if obj.node_type == "typst_image" then
                body = typstRewriteImagePaths(body, buf)
        end

        local typ_file, png_file = typstTempFiles()
        return {
                obj        = obj,
                hash       = "typst:" .. vim.fn.sha256(body),
                range      = obj.range,
                line_count = lineCount(body),
                typ_file   = typ_file,
                png_file   = png_file,
                body       = body,
        }
end

local function cleanupTypstTask(task)
        vim.fn.delete(task.typ_file)
        vim.fn.delete(task.png_file)
end

-- ---------------------------------------------------------------------------
-- External Commands
-- ---------------------------------------------------------------------------

local function compileTex(texFile, tmpdir, callback)
        vim.system({
                           "xelatex",
                           "-interaction=nonstopmode",
                           "-halt-on-error",
                           "-output-directory=" .. tmpdir,
                           texFile,
                   }, {}, callback)
end

local function convertPdfToPng(pdfFile, pngPrefix, callback)
        vim.system({
                           "pdftocairo",
                           "-png",
                           "-singlefile",
                           "-r",
                           tostring(config.dpi),
                           "-transp",
                           pdfFile,
                           pngPrefix,
                   }, {}, callback)
end

local function compileTypstToPng(typFile, pngFile, callback)
        vim.system({
                           "typst",
                           "compile",
                           "--format",
                           "png",
                           "--ppi",
                           tostring(config.dpi),
                           "--root",
                           "/",
                           typFile,
                           pngFile,
                   }, {}, callback)
end

local function compileLatexTask(task, callback)
        -- callback(success, message)
        --   success == true   -> PNG is ready.
        --   success == false  -> command failed; message is user-facing.
        --   success == nil    -> another job for the same hash is already running.
        if vim.fn.filereadable(task.png_file) == 1 then
                return callback(true, "cached")
        end

        if state.pending_jobs[task.hash] then
                return callback(nil, "already running")
        end

        state.pending_jobs[task.hash] = true
        writeLatexTask(task)

        compileTex(task.tex_file, task.tmpdir, function(texRes)
                if texRes.code ~= 0 then
                        state.pending_jobs[task.hash] = nil
                        return callback(false, "xelatex failed: " .. (texRes.stderr or ""))
                end

                convertPdfToPng(task.pdf_file, task.png_prefix, function(pngRes)
                        state.pending_jobs[task.hash] = nil
                        if pngRes.code == 0 then
                                callback(true, "rendered")
                        else
                                callback(false, "pdftocairo failed: " .. (pngRes.stderr or ""))
                        end
                end)
        end)
end

-- ---------------------------------------------------------------------------
-- Render Current Object
-- ---------------------------------------------------------------------------

local function renderLatex(obj, opts)
        local task = makeLatexTask(vim.api.nvim_get_current_buf(), obj)
        if not beginPreview(obj, task.hash, opts) then
                return
        end

        local function show()
                showPngFile(task.png_file, task.hash, task.range, task.line_count, opts)
        end

        if vim.fn.filereadable(task.png_file) == 1 then
                return show()
        end

        -- LaTeX is slow enough that we debounce it. If you move the cursor away or
        -- keep typing before the timer fires, defer_current drops the old callback.
        deferCurrent(config.compile_delay_ms, task.hash, task.range, function()
                compileLatexTask(task, function(success, msg)
                        if success then
                                vim.schedule(show)
                        elseif success == false then
                                vim.schedule(function()
                                        notifyError(opts, msg)
                                end)
                        end
                end)
        end)
end

local function renderTypst(obj, opts)
        local task = makeTypstTask(vim.api.nvim_get_current_buf(), obj)
        if not beginPreview(obj, task.hash, opts) then
                cleanupTypstTask(task)
                return
        end

        local function cleanup()
                cleanupTypstTask(task)
        end

        -- Typst is fast and uncached, but still async. The tiny delay keeps multiple
        -- TextChangedI events from spawning work for every intermediate keystroke.
        deferCurrent(10, task.hash, task.range, function()
                             vim.fn.writefile(vim.split(string.format(typst_template, task.body), "\n"), task.typ_file)
                             compileTypstToPng(task.typ_file, task.png_file, function(res)
                                     if res.code == 0 then
                                             vim.schedule(function()
                                                     showPngFile(task.png_file, task.hash, task.range, task
                                                                 .line_count, opts, cleanup)
                                             end)
                                     else
                                             vim.schedule(function()
                                                     cleanup()
                                                     notifyError(opts, "typst failed: " .. (res.stderr or ""))
                                             end)
                                     end
                             end)
                     end, cleanup)
end

local function renderCurrent(opts)
        opts = opts or {}

        -- Do not render while in visual/operator-pending/etc. Those modes can have
        -- unusual cursor/range semantics and the preview would feel jumpy.
        if vim.fn.mode() ~= "n" and vim.fn.mode() ~= "i" then
                return clearPreview()
        end

        local is_typst = vim.bo.filetype == "typst"
        local obj      = is_typst and getTypstAtCursor() or getLatexAtCursor()
        if not obj then
                return clearPreview()
        end

        if is_typst then
                renderTypst(obj, opts)
        else
                renderLatex(obj, opts)
        end
end

-- ---------------------------------------------------------------------------
-- Render All LaTeX Objects Into The Cache
-- ---------------------------------------------------------------------------

local function collectLatexObjects(buf)
        local ok, parser = pcall(vim.treesitter.get_parser, buf)
        if not ok or not parser then
                return {}
        end

        local tree = (parser:parse() or {})[1]
        if not tree then
                return {}
        end

        local objects, seen = {}, {}

        local function add(obj)
                local range = obj.range
                local key   = table.concat({ range[1], range[2], range[3], range[4], obj.text }, ":")
                if not seen[key] then
                        seen[key] = true
                        table.insert(objects, obj)
                end
        end

        local function walk(node)
                local obj = objectFromLatexNode(buf, node)
                if obj then
                        add(obj)
                        return
                end

                for child in node:iter_children() do
                        walk(child)
                end
        end

        walk(tree:root())
        table.sort(objects, function(a, b)
                if a.range[1] == b.range[1] then
                        return a.range[2] < b.range[2]
                end
                return a.range[1] < b.range[1]
        end)

        return objects
end

local function renderAll()
        local buf     = vim.api.nvim_get_current_buf()
        local objects = collectLatexObjects(buf)
        if #objects == 0 then
                vim.notify("No LaTeX math/table/figure previews found", vim.log.levels.INFO)
                return
        end

        state.render_all.cancelled = true
        state.render_all           = { running = true, cancelled = false }

        local tasks, seen_hash = {}, {}
        for _, obj in ipairs(objects) do
                local task = makeLatexTask(buf, obj)
                if not seen_hash[task.hash] then
                        seen_hash[task.hash] = true
                        table.insert(tasks, task)
                end
        end

        local max_jobs                 = math.max(1, math.min(6, tonumber(vim.g.latex_math_preview_render_all_jobs) or 6))
        local next_index, active, done = 1, 0, 0
        local ok_count, fail_count     = 0, 0
        local token                    = state.render_all

        vim.notify("Rendering " .. #tasks .. " LaTeX previews with " .. max_jobs .. " async jobs", vim.log.levels.INFO)

        local function finishIfDone()
                if done < #tasks or active > 0 then
                        return
                end

                token.running = false
                vim.schedule(function()
                        vim.notify(
                                "LaTeX preview render-all finished: " ..
                                ok_count .. " ready, " .. fail_count .. " failed",
                                fail_count > 0 and vim.log.levels.WARN or vim.log.levels.INFO
                        )
                end)
        end

        local function startMore()
                if token.cancelled then
                        token.running = false
                        return
                end

                while active < max_jobs and next_index <= #tasks do
                        local task = tasks[next_index]
                        next_index = next_index + 1
                        active     = active + 1

                        compileLatexTask(task, function(success)
                                active = active - 1
                                done   = done + 1
                                if success == false then
                                        fail_count = fail_count + 1
                                else
                                        ok_count = ok_count + 1
                                end

                                vim.schedule(function()
                                        startMore()
                                        finishIfDone()
                                end)
                        end)
                end

                finishIfDone()
        end

        startMore()
end

-- ---------------------------------------------------------------------------
-- Commands And Autocommands
-- ---------------------------------------------------------------------------

local function clearCache()
        clearPreview()
        state.pending_jobs         = {}
        state.render_all.cancelled = true

        local dir = cacheDir()
        if vim.fn.isdirectory(dir) ~= 1 then
                vim.notify("Math preview cache is already empty", vim.log.levels.INFO)
                return
        end

        for _, file in ipairs(vim.fn.globpath(dir, "*", false, true)) do
                vim.fn.delete(file, "rf")
        end

        vim.notify("Math preview cache cleared: " .. dir, vim.log.levels.INFO)
end

function M.setup()
        -- Decoration providers run during redraw. That makes on_win the right hook
        -- for keeping a terminal image glued to its source line while scrolling.
        vim.api.nvim_set_decoration_provider(ns, {
                on_win = function(_, winid, bufnr)
                        if state.img_id and state.range and bufnr == vim.api.nvim_get_current_buf() then
                                updateImgPos(winid)
                        end
                end,
        })

        local group = vim.api.nvim_create_augroup("MathPreview", { clear = true })

        vim.api.nvim_create_user_command("LatexMathPreviewClearCache", clearCache, {
                desc = "Clear cached LaTeX math preview images",
        })

        vim.api.nvim_create_user_command("LatexMathPreviewRenderAll", renderAll, {
                desc = "Asynchronously render all LaTeX math/table/figure previews into the cache",
        })

        vim.api.nvim_create_autocmd("CursorMoved", {
                group    = group,
                pattern  = file_patterns,
                callback = function()
                        renderCurrent()
                end,
        })

        vim.api.nvim_create_autocmd("CursorMovedI", {
                group    = group,
                pattern  = file_patterns,
                callback = function()
                        renderCurrent({ keep_old = true, silent = true })
                end,
        })

        vim.api.nvim_create_autocmd({ "TextChangedI", "TextChangedP" }, {
                group    = group,
                pattern  = file_patterns,
                callback = function()
                        renderCurrent({ keep_old = true, silent = true })
                end,
        })

        vim.api.nvim_create_autocmd({ "WinScrolled", "WinResized" }, {
                group    = group,
                pattern  = file_patterns,
                callback = function()
                        updateImgPos()
                end,
        })

        vim.api.nvim_create_autocmd("InsertLeave", {
                group    = group,
                pattern  = file_patterns,
                callback = function()
                        renderCurrent({ keep_old = true })
                end,
        })
end

return {
        dir          = vim.fn.stdpath("config"),
        name         = "latex-math-preview",
        ft           = { "tex", "markdown", "typst" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config       = M.setup,
}
