-- ~/dotfiles/nvim/.config/nvim/lua/plugins/surround.lua
return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({})
  end,
}
