-- ~/dotfiles/nvim/.config/nvim/lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig", -- still needed for Mason integrations and defaults
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "clangd", "bashls" },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- ==============================
    -- global float border setup
    -- ==============================
    local orig = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or "rounded"
      return orig(contents, syntax, opts, ...)
    end

    -- ==============================
    -- Helper to start servers via vim.lsp.config
    -- ==============================
    local cfg = vim.lsp.config

    cfg("lua_ls", {
      cmd = { "lua-language-server" },
      capabilities = capabilities,
      settings = {
        Lua = {
          completion = { callSnippet = "Replace" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file("", true),
          },
        },
      },
    })

    cfg("clangd", {
      cmd = { "clangd", "--background-index", "--clang-tidy" },
      capabilities = capabilities,
    })

    cfg("pyright", {
      cmd = { "pyright-langserver", "--stdio" },
      capabilities = capabilities,
    })

    cfg("bashls", {
      cmd = { "bash-language-server", "start" },
      capabilities = capabilities,
    })
  end,
}
