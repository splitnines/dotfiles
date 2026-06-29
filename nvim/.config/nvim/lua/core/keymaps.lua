-- ~/.config/nvim/lua/core/options.lua
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- F1 is Esc because I always typo it
vim.keymap.set("n", "<F1>", "<Nop>", { silent = true })
vim.keymap.set({ "i", "v", "c" }, "<F1>", "<Esc>", { silent = true })

vim.keymap.set({ "n", "i", "v", "c" }, "<PageUp>", "<Nop>")
vim.keymap.set({ "n", "i", "v", "c" }, "<PageDown>", "<Nop>")

-- Remap :w1 and wq1 FFS
vim.cmd("cnoreabbrev w1 w!")
vim.cmd("cnoreabbrev wq1 wq!")

-- Remap for home/end of current line
vim.keymap.set("i", "<C-a>", "<C-o>0", { noremap = true })
vim.keymap.set("i", "<C-e>", "<C-o>$", { noremap = true })

-- Window navigation
local map_w = vim.keymap.set
local opts_w = { noremap = true, silent = true }
map_w("n", "<leader>wh", "<C-w>h", vim.tbl_extend("force", opts_w, { desc = "Move to window left" }))
map_w("n", "<leader>wj", "<C-w>j", vim.tbl_extend("force", opts_w, { desc = "Move to window below" }))
map_w("n", "<leader>wk", "<C-w>k", vim.tbl_extend("force", opts_w, { desc = "Move to window above" }))
map_w("n", "<leader>wl", "<C-w>l", vim.tbl_extend("force", opts_w, { desc = "Move to window right" }))
map_w("n", "<leader>wv", "<C-w>v", vim.tbl_extend("force", opts_w, { desc = "Vertical split" }))
map_w("n", "<leader>ws", "<C-w>s", vim.tbl_extend("force", opts_w, { desc = "Horizontal split" }))
map_w("n", "<leader>wq", "<C-w>q", vim.tbl_extend("force", opts_w, { desc = "Close window" }))
map_w("n", "<leader>wc", "<cmd>only<CR>", vim.tbl_extend("force", opts_w, { desc = "Close all other windows" }))
map_w("n", "<leader>wo", "<C-w>o", vim.tbl_extend("force", opts_w, { desc = "Keep only current window" }))
map_w("n", "<leader>w=", "<C-w>=", vim.tbl_extend("force", opts_w, { desc = "Equalize window sizes" }))
map_w("n", "<leader>w+", "<C-w>+", vim.tbl_extend("force", opts_w, { desc = "Increase window height" }))
map_w("n", "<leader>w-", "<C-w>-", vim.tbl_extend("force", opts_w, { desc = "Decrease window height" }))
map_w("n", "<leader>w<", "<C-w><", vim.tbl_extend("force", opts_w, { desc = "Decrease window width" }))
map_w("n", "<leader>w>", "<C-w>>", vim.tbl_extend("force", opts_w, { desc = "Increase window width" }))
map_w("n", "<leader>wr", "<C-w>r", vim.tbl_extend("force", opts_w, { desc = "Rotate windows" }))
map_w("n", "<leader>wx", "<C-w>x", vim.tbl_extend("force", opts_w, { desc = "Exchange windows" }))
map_w("n", "<leader>wt", "<C-w>T", vim.tbl_extend("force", opts_w, { desc = "Move window to new tab" }))
map_w("n", "<leader>wn", "<cmd>tabnew<CR>", vim.tbl_extend("force", opts_w, { desc = "Open new tab" }))
map_w("n", "<leader>wd", "<cmd>tabclose<CR>", vim.tbl_extend("force", opts_w, { desc = "Close current tab" }))

-- Insert mode navigation
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-j>", "<Down>")
vim.keymap.set("i", "<C-k>", "<Up>")
vim.keymap.set("i", "<C-l>", "<Right>")

-- Scroll centering
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Insert line above/below
vim.keymap.set("n", "<leader>o", ":put _<CR>", { desc = "Insert line below" })
vim.keymap.set("n", "<leader>O", ":put! _<CR>", { desc = "Insert line above" })

-- Diagnostics
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics" })

-- Buffer scrolling
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>")

-- Jump to definition
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- Explore
vim.keymap.set("n", "<leader>d", "<CMD>Explore<CR>", { desc = "Directory explorer" })

-- Center search results
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Toggle linter
vim.keymap.set("n", "<leader>tl", "<cmd>ToggleLint<CR>", {
  desc = "Toggle LSP diagnostics",
  silent = true,
})

-- Markdown toggle
vim.keymap.set("n", "<leader>tm", function()
  require("lazy").load({ plugins = { "render-markdown.nvim" } })
  local render = require("render-markdown")
  local buf = vim.api.nvim_get_current_buf()
  local is_enabled = vim.b[buf].markdown_render_enabled
  if is_enabled then
    render.disable()
    vim.b[buf].markdown_render_enabled = false
    vim.notify("Markdown rendering disabled", vim.log.levels.INFO)
  else
    render.enable()
    vim.b[buf].markdown_render_enabled = true
    vim.notify("Markdown rendering enabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle Markdown Render" })


-- Spell check toggle
vim.keymap.set("n", "<leader>ts", function()
  local spell_enabled = vim.opt.spell
  if type(spell_enabled) ~= "boolean" then
    spell_enabled = vim.wo.spell
  end

  local new_state = not spell_enabled
  vim.opt.spell = new_state

  if new_state then
    vim.notify("Spell check enabled", vim.log.levels.INFO)
  else
    vim.notify("Spell check disabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle spell checking" })

vim.keymap.set("n", "<leader>tg", function()
  local new_state = not vim.wo.number

  vim.wo.number = new_state
  vim.wo.relativenumber = new_state
  vim.wo.signcolumn = new_state and "yes" or "no"

  vim.notify(
    new_state and "Gutter enabled" or "Gutter disabled",
    vim.log.levels.INFO
  )
end, { desc = "Toggle gutter and line numbers" })

-- Toggle zen mode
local zen_mode = false
local zen_state = {}

vim.keymap.set("n", "<leader>tz", function()
  zen_mode = not zen_mode

  if zen_mode then
    zen_state = {
      number = vim.wo.number,
      relativenumber = vim.wo.relativenumber,
      signcolumn = vim.wo.signcolumn,
      laststatus = vim.o.laststatus,
    }

    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.o.laststatus = 0

    vim.notify("Zen mode enabled", vim.log.levels.INFO)
  else
    vim.wo.number = zen_state.number
    vim.wo.relativenumber = zen_state.relativenumber
    vim.wo.signcolumn = zen_state.signcolumn
    vim.o.laststatus = zen_state.laststatus

    vim.notify("Zen mode disabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle Zen mode" })

-- Force :Man to open in current window
vim.cmd([[
   cnoreabbrev <expr> Man
         \ getcmdtype() ==# ':' && getcmdline() ==# 'Man'
         \ ? 'hide Man'
         \ : 'Man'
   ]])
