-- ~/dotfiles/nvim/.config/nvim/lua/plugins/lsp.lua
-- return {
--   "neovim/nvim-lspconfig",
--   dependencies = {
--     "williamboman/mason.nvim",
--     "williamboman/mason-lspconfig.nvim",
--     { "j-hui/fidget.nvim", opts = {} },
--     "hrsh7th/cmp-nvim-lsp",
--     "L3MON4D3/LuaSnip",
--   },
--   config = function()
--     require("mason").setup({
--       ui = {
--         border = "rounded",
--       },
--     })
--     require("mason-lspconfig").setup({
--       ensure_installed = { "lua_ls", "clangd", "bashls" },
--     })
--
--     local capabilities = require("cmp_nvim_lsp").default_capabilities()
--
--     -- ==============================
--     -- global float border setup
--     -- ==============================
--     local orig = vim.lsp.util.open_floating_preview
--     function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
--       opts = opts or {}
--       opts.border = opts.border or "rounded"
--       return orig(contents, syntax, opts, ...)
--     end
--
--     -- ==============================
--     -- Helper to start servers via vim.lsp.config
--     -- ==============================
--     local cfg = vim.lsp.config
--
--     cfg("lua_ls", {
--       cmd = { "lua-language-server" },
--       capabilities = capabilities,
--       settings = {
--         Lua = {
--           completion = { callSnippet = "Replace" },
--           diagnostics = { globals = { "vim" } },
--           workspace = {
--             checkThirdParty = false,
--             library = vim.api.nvim_get_runtime_file("", true),
--           },
--         },
--       },
--     })
--     vim.lsp.enable("lua_ls")
--
--     cfg("clangd", {
--       cmd = { "clangd", "--background-index", "--clang-tidy" },
--       capabilities = capabilities,
--     })
--
--     cfg("bashls", {
--       cmd = { "bash-language-server", "start" },
--       capabilities = capabilities,
--     })
--     vim.lsp.enable("bashls")
--
--     -- ruff
--     cfg("ruff", {
--       init_options = {
--         settings = {
--           lineLength = 79,
--           configuration = nil,
--           configurationPreference = "editorFirst",
--           lint = {
--             enable = true,
--             select = { "E", "F", "W" },
--           },
--           format = {
--             enable = true,
--           },
--           organizeImports = true,
--         },
--       },
--       capabilities = capabilities,
--     })
--     vim.lsp.enable("ruff")
--
--     -- ty
--     vim.lsp.config("ty", {
--       settings = {
--         ty = {
--           inlayHints = {
--             variableTypes = true,
--           },
--           disableLanguageServices = false,
--           configuration = {
--             rules = {
--               ["unresolved-reference"] = "warn",
--             },
--           },
--         },
--       },
--     })
--     vim.lsp.enable("ty")
--   end,
-- }
-- ~/dotfiles/nvim/.config/nvim/lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
  },
  config = function()
    require("mason").setup({
      ui = {
        border = "rounded",
      },
    })

    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "clangd", "bashls", "jdtls" },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local cfg = vim.lsp.config

    vim.o.winborder = "rounded"

    -- vim.diagnostic.config({
    --   float = { border = "rounded" },
    --   virtual_text = true,
    --   signs = true,
    --   underline = true,
    --   update_in_insert = false,
    --   severity_sort = true,
    -- })

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
    vim.lsp.enable("lua_ls")

    cfg("clangd", {
      cmd = { "clangd", "--background-index", "--clang-tidy" },
      capabilities = capabilities,
    })
    vim.lsp.enable("clangd")

    cfg("bashls", {
      cmd = { "bash-language-server", "start" },
      capabilities = capabilities,
    })
    vim.lsp.enable("bashls")

    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local jdtls_workspace = vim.fn.stdpath("cache") .. "/jdtls-workspaces/" .. project_name

    cfg("jdtls", {
      cmd = {
        vim.fn.stdpath("data") .. "/mason/bin/jdtls",
        "-data",
        jdtls_workspace,
      },
      capabilities = capabilities,
    })
    vim.lsp.enable("jdtls")

    cfg("ruff", {
      cmd = { "ruff", "server" },
      capabilities = capabilities,
      init_options = {
        settings = {
          lineLength = 79,
          configurationPreference = "editorFirst",
          lint = {
            enable = true,
            select = { "E", "F", "W" },
          },
          format = {
            enable = true,
          },
          organizeImports = true,
        },
      },
    })
    vim.lsp.enable("ruff")

    cfg("ty", {
      cmd = { "ty", "server" },
      capabilities = capabilities,
      settings = {
        ty = {
          inlayHints = {
            variableTypes = true,
          },
          disableLanguageServices = false,
          configuration = {
            rules = {
              ["unresolved-reference"] = "warn",
            },
          },
        },
      },
    })
    vim.lsp.enable("ty")
  end,
}
