-- ~/dotfiles/nvim/.config/nvim/lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  main = "nvim-treesitter.config",
  opts = {
    ensure_installed = { "bash", "c", "lua", "python" },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  },
}
