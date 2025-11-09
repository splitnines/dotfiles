-- ~/dotfiles/nvim/.config/nvim/lua/init.lua
-- Entrypoint: loads core settings and plugins

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("plugins.init")
require("plugins.extras")

-- Quiet known harmless deprecation messages without overwriting type info
-- do
--   local orig_deprecate = vim.deprecate
--   rawset(vim, "deprecate", function(name, alternative, version, plugin)
--     if name == "client.supports_method" or name == "vim.validate{<table>}" then
--       return -- suppress only these warnings
--     end
--     return orig_deprecate(name, alternative, version, plugin)
--   end)
-- end
