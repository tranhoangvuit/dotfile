-- Require all .lua files in a directory
local function require_all(dir)
  local config_path = vim.fn.stdpath("config") .. "/lua/" .. dir

  for name, type in vim.fs.dir(config_path) do
    if type == "file" and name:match("%.lua$") then
      local module = name:gsub("%.lua$", "")
      require(dir .. "." .. module)
    end
  end
end

-- Load plugins first (vim.pack.add declarations)
require("plugins")

-- Load plugin configurations
require_all("plugins")

-- Load config files
require_all("config")
