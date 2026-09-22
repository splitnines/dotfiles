-- ~/dotfiles/nvim/.config/nvim/lua/core/options.lua
_G.uv = vim.uv or vim.loop

vim.g.mapleader = " "
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
vim.opt.scrolloff = 3
vim.opt.cursorline = true
vim.opt.list = false
vim.g.have_nerd_font = true
vim.opt.inccommand = "split"
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
local bash_path = vim.fn.exepath("bash")
if bash_path ~= "" then
  vim.opt.shell = bash_path
end
vim.opt.autoread = true
vim.opt.clipboard = "unnamedplus"

vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  signs = true,
  update_in_insert = false,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
