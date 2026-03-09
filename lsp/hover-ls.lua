local ms = vim.lsp.protocol.Methods

local capabilities = {
        capabilities = { hoverProvider = true },
        serverInfo   = { name = "hover-ls", version = "0.0.1" },
}

local function cursorIsUrl()
        local urls = vim.ui._get_urls()

        if not vim.tbl_isempty(urls) and vim.startswith(urls[1], "https://") or vim.startswith(urls[1], "http://") then
                return true, urls[1]
        end
        return false, nil
end

local cache = {}

local function fetchMarkdown(url)
        if cache[url] then
                return cache[url]
        end
        local out = vim.system({ "curl", "-s", "https://markdown.new/" .. url }):wait()
        if out.code == 0 then
                cache[url] = out.stdout
                return out.stdout
        else
                return "Failed to fetch markdown content."
        end
end

return {
        cmd = function()
                return {
                        request    = function(method, _, handler, _)
                                if method == ms.textDocument_hover then
                                        local is_url, url = cursorIsUrl()
                                        if is_url then
                                                handler(nil,
                                                        { contents = { kind = "markdown", value = fetchMarkdown(url) } })
                                        end
                                elseif method == ms.initialize then
                                        handler(nil, capabilities)
                                end
                        end,
                        notify     = function() end,
                        is_closing = function() end,
                        terminate  = function() end,
                }
        end,

        filetypes = { "lua", "markdown" },
}
