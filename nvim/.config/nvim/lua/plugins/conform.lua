-- ~/dotfiles/nvim/.config/nvim/lua/plugins/conform.lua
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "ruff_fix", "isort", "yapf" },
    },
    formatters = {
      stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" } },
    },
    autopep8 = {
      prepend_args = { "--style", "{based_on_style: pep8, colunm_limit: 79}" },
    },
    format_on_save = function(bufnr)
      local disable = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_format = disable[vim.bo[bufnr].filetype] and "never" or "fallback",
      }
    end,
  },
}
