-- ~/dotfiles/nvim/.config/nvim/lua/plugins/treesitter.lua
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    require("nvim-treesitter").install({
      "bash",
      "c",
      "lua",
      "python",
    })

    vim.treesitter.language.register("bash", "sh")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sh", "bash" },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
