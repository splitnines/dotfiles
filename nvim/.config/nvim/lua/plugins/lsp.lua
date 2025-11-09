-- ~/dotfiles/nvim/.config/nvim/lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    { "mason-org/mason.nvim" },
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    "L3MON4D3/LuaSnip",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "pyright", "clangd", "bashls" },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local cfg = vim.lsp.config

    cfg("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          completion = { callSnippet = "Replace" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
        },
      },
    })

    cfg("clangd", {
      capabilities = capabilities,
      cmd = { "clangd", "--background-index", "--clang-tidy" },
    })

    cfg("pyright", { capabilities = capabilities })
    cfg("bashls", { capabilities = capabilities })

    ----------------------------------------------------------------
    -- LSP keymaps
    ----------------------------------------------------------------
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(event)
        local opts = { buffer = event.buf, silent = true, noremap = true }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        -- Optional: other common LSP bindings
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end,
    })
  end,
}
