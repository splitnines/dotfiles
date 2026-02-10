-- ~/dotfiles/nvim/.config/nvim/lua/plugins/init.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { "tpope/vim-sleuth" },
    { "folke/neodev.nvim",              opts = {} },
    { "lukas-reineke/virt-column.nvim", opts = {} },

    require("plugins.todo-comments"),
    require("plugins.gitsigns"),
    require("plugins.whichkey"),
    require("plugins.dressing"),
    require("plugins.autopairs"),
    require("plugins.indent"),
    require("plugins.telescope"),
    require("plugins.treesitter"),
    require("plugins.lsp"),
    require("plugins.conform"),
    require("plugins.cmp"),
    require("plugins.ui"),
    require("plugins.smear"),
    require("plugins.markdown"),
    require("plugins.surround"),
    require("plugins.gp"),
    require("plugins.undotree")
  },
})
