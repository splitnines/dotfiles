-- ~/dotfiles/nvim/.config/nvim/lua/core/keymaps.lua
-- ===========================
-- Keymaps
-- ===========================
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Split navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<leader>x", "<C-w>q")

-- Scroll centering
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Insert line above/below
vim.keymap.set("n", "<leader>o", ":put _<CR>")
vim.keymap.set("n", "<leader>O", ":put! _<CR>")

-- Diagnostics
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- Buffer scrolling
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>")

-- Alpha dashboard
vim.keymap.set("n", "<leader>da", ":Alpha<CR>", { desc = "Show banner" })

-- Markdown toggle
vim.keymap.set("n", "<leader>mk", function()
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
vim.keymap.set("n", "<leader>sp", function()
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

-- Open LSP references in floating window
vim.keymap.del("n", "grr")

vim.keymap.set("n", "grr", function()
  -- cancel any pending operator state (prevents stray 'A')
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

  -- now run your Telescope reference picker (single-client version)
  local telescope = require("telescope.builtin")
  local util = vim.lsp.util

  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local client
  for _, c in ipairs(clients) do
    if c.supports_method("textDocument/references") then
      client = c
      break
    end
  end
  if not client then
    vim.notify("No LSP client supports textDocument/references", vim.log.levels.WARN)
    return
  end

  local encoding = client.offset_encoding or "utf-16"
  local params = util.make_position_params(0, encoding)
  local show_previewer = vim.o.columns >= 120

  client.request("textDocument/references", params, function(err, result)
    if err then
      vim.notify("LSP error: " .. err.message, vim.log.levels.ERROR)
      return
    end
    if not result or vim.tbl_isempty(result) then
      vim.notify("No references found", vim.log.levels.INFO)
      return
    end

    require("telescope.pickers")
      .new({}, {
        prompt_title = "LSP References",
        finder = require("telescope.finders").new_table({
          results = vim.lsp.util.locations_to_items(result, encoding),
          entry_maker = require("telescope.make_entry").gen_from_lsp_locations(),
        }),
        sorter = require("telescope.config").values.generic_sorter({}),
        previewer = show_previewer and require("telescope.config").values.qflist_previewer({}) or nil,
        layout_strategy = "horizontal",
        layout_config = {
          width = 0.9,
          height = 0.8,
          preview_width = show_previewer and 0.5 or 0,
        },
      })
      :find()
  end, 0)
end, {
  desc = "LSP References (Conditional Preview, Single Client)",
  noremap = true,
  silent = true,
})

-- vim.keymap.del("n", "grr")
-- vim.keymap.set("n", "grr", function()
--   local telescope = require("telescope.builtin")
--   local util = vim.lsp.util
--
--   local client = vim.lsp.get_clients({ bufnr = 0 })[1]
--   if not client then
--     vim.notify("No active LSP client found", vim.log.levels.WARN)
--     return
--   end
--
--   local encoding = client.offset_encoding or "utf-16"
--   local params = util.make_position_params(0, encoding)
--
--   local show_previewer = vim.o.columns >= 120
--
--   telescope.lsp_references({
--     layout_strategy = "horizontal",
--     layout_config = {
--       width = 0.9,
--       height = 0.8,
--       preview_width = show_previewer and 0.5 or 0,
--       preview_cutoff = 120,
--     },
--     previewer = show_previewer,
--     params = params,
--   })
-- end, {
--   desc = "LSP References",
--   noremap = true,
--   silent = true,
-- })
--
--
--
