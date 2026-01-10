-- ~/dotfiles/nvim/.config/nvim/lua/plugins/markdown.lua
return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  lazy = false,
  opts = {
    anti_conceal = { enabled = false },
    enabled = false,
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
  end,
}
