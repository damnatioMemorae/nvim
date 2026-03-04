#!/usr/bin/env lua

local home   = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.local/share/bin/lua/?.lua"

local utils   = require("utils")
local exec    = utils.exec
local capture = utils.execCapture

------------------------------------------------------------------------------------------------------------------------

