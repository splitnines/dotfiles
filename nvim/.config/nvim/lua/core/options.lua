-- ~/dotfiles/nvim/.config/nvim/lua/core/options.lua
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
vim.g.have_nerd_font = true
vim.opt.inccommand = "split"
vim.opt.smartindent = true
local zsh_path = vim.fn.exepath("zsh")
if zsh_path ~= "" then
  vim.opt.shell = zsh_path
elseif vim.env.SHELL and vim.env.SHELL ~= "" then
  vim.opt.shell = vim.env.SHELL
end
vim.opt.autoread = true

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  signs = true,
  update_in_insert = false,
})
vim.o.updatetime = 250

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

if has_osc52 then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = osc52.copy('+'),
      ['*'] = osc52.copy('*'),
    },
    paste = {
      ['+'] = osc52.paste('+'),
      ['*'] = osc52.paste('*'),
    },
  }
end
