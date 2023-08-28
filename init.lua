require('core.base')
require('core.highlights')
require('core.maps')
require('core.plugins')

local has = vim.fn.has
local is_mac = has "macunix"
local is_linux = has "unix"
local is_win = has "win32"
local is_wsl = has "wsl"

if is_mac == 1 then
  require('core.macos')
end
if is_linux == 1 then
  require('core.linux')
end
if is_win == 1 then
  require('core.windows')
end
if is_wsl == 1 then
  require('core.wsl')
end
