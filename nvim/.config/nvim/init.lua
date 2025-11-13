-- ~/dotfiles/nvim/.config/nvim/lua/init.lua
-- Entrypoint: loads core settings and plugins

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("plugins.init")
require("plugins.extras")
