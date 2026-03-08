-- ~/dotfiles/nvim/.config/nvim/lua/plugins/extras.lua
-- CSV Tools + ToggleLint + Hover Fix
require("csv.tools")

-- Toggle lint
do
  vim.api.nvim_create_user_command("ToggleLint", function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.diagnostic.is_enabled({ bufnr = bufnr }) then
      vim.diagnostic.enable(false, { bufnr = bufnr })
      vim.diagnostic.reset(nil, bufnr)
      print("Diagnostics disabled")
    else
      vim.diagnostic.enable(true, { bufnr = bufnr })
      print("Diagnostics enabled")
    end
  end, {})
end
vim.keymap.set("n", "K", vim.lsp.buf.hover, {
  noremap = true,
  silent = true,
})
