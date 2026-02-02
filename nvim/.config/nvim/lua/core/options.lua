-- ~/dotfiles/nvim/.config/nvim/lua/core/options.lua
-- ===========================
-- Basic Settings
-- ===========================
_G.uv = vim.uv or vim.loop

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 5
vim.opt.cursorline = true
vim.opt.list = true
vim.g.have_nerd_font = true
-- vim.opt.listchars:append({ trail = "·", tab = "» " })
vim.opt.inccommand = "split"
vim.opt.smartindent = true
-- Use zsh
vim.opt.shell = "/usr/bin/zsh"
-- vim.opt.shellcmdflag = "-ic"

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- Diagnostics
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
})

vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
