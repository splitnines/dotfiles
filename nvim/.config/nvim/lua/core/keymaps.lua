-- ===========================
-- Keymaps
-- ===========================
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

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

-- Scroll centering
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Insert line above/below
vim.keymap.set("n", "<leader>o", ":put _<CR>", { desc = "Insert line below" })
vim.keymap.set("n", "<leader>O", ":put! _<CR>", { desc = "Insert line above" })

-- Diagnostics
-- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics" })

-- Buffer scrolling
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>")

-- Alpha dashboard
vim.keymap.set("n", "<leader>mb", ":Alpha<CR>", { desc = "Show banner" })

-- Jump to definition
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

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
  local spell_enabled = vim.opt.spell:get() or vim.opt.spell
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

--
--
--
