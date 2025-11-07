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
vim.opt.list = false
vim.opt.inccommand = "split"
vim.opt.smartindent = true

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

-- Visual Tweaks
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#0a0a0a" })
vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff", bg = "#0a0a0a" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#111111" })

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "Search", { fg = "#000000", bg = "#61afef", bold = true })
    vim.api.nvim_set_hl(0, "IncSearch", { fg = "#000000", bg = "#56b6c2", bold = true })
  end,
})

vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
