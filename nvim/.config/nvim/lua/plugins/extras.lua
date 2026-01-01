-- ~/dotfiles/nvim/.config/nvim/lua/plugins/extras.lua
-- CSV Tools + ToggleLint + Hover Fix
require("csv.tools")

vim.api.nvim_create_user_command("CSVAlign", function()
  vim.cmd("%!column -t -s,")
end, { desc = "Align CSV columns (no borders)" })

-- Toggle lint
do
  local lint_disabled = {}
  local orig = vim.lsp.handlers["textDocument/publishDiagnostics"]
  vim.api.nvim_create_user_command("ToggleLint", function()
    local bufnr = vim.api.nvim_get_current_buf()
    if lint_disabled[bufnr] then
      lint_disabled[bufnr] = false
      vim.lsp.handlers["textDocument/publishDiagnostics"] = orig
      print("Diagnostics enabled")
    else
      lint_disabled[bufnr] = true
      vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
        if vim.uri_to_bufnr(result.uri) == bufnr then
          return
        end
        return orig(err, result, ctx, config)
      end
      vim.diagnostic.reset(nil, bufnr)
      print("Diagnostics disabled")
    end
  end, {})
end

vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })
