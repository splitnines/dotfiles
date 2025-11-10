-- ~/dotfiles/nvim/.config/nvim/lua/plugins/lsp.lua
-- return {
--   "neovim/nvim-lspconfig",
--   dependencies = {
--     { "williamboman/mason.nvim", config = true },
--     { "mason-org/mason.nvim" },
--     "williamboman/mason-lspconfig.nvim",
--     "WhoIsSethDaniel/mason-tool-installer.nvim",
--     { "j-hui/fidget.nvim", opts = {} },
--     "hrsh7th/cmp-nvim-lsp",
--     "hrsh7th/cmp-buffer",
--     "hrsh7th/cmp-path",
--     "hrsh7th/cmp-cmdline",
--     "saadparwaiz1/cmp_luasnip",
--     "L3MON4D3/LuaSnip",
--   },
--   config = function()
--     require("mason").setup()
--     require("mason-lspconfig").setup({
--       ensure_installed = { "lua_ls", "pyright", "clangd", "bashls" },
--     })
--
--     local capabilities = require("cmp_nvim_lsp").default_capabilities()
--     local cfg = vim.lsp.config
--
--     cfg("lua_ls", {
--       capabilities = capabilities,
--       settings = {
--         Lua = {
--           completion = { callSnippet = "Replace" },
--           diagnostics = { globals = { "vim" } },
--           workspace = {
--             library = vim.api.nvim_get_runtime_file("", true),
--             checkThirdParty = false,
--           },
--         },
--       },
--     })
--
--     cfg("clangd", {
--       capabilities = capabilities,
--       cmd = { "clangd", "--background-index", "--clang-tidy" },
--     })
--
--     cfg("pyright", { capabilities = capabilities })
--     cfg("bashls", { capabilities = capabilities })
--   end,
-- }
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

    -------------------------------------------------------------------
    -- Fix duplicate “Go to Definition” results (e.g., Pyright stubs)
    -------------------------------------------------------------------
    vim.lsp.handlers["textDocument/definition"] = function(_, result, ctx, _)
      if not result or vim.tbl_isempty(result) then
        vim.notify("No definition found", vim.log.levels.INFO)
        return
      end

      -- Deduplicate definitions by file + line
      local seen, locations = {}, {}
      for _, loc in ipairs(result) do
        local uri = loc.uri or loc.targetUri
        local range = loc.range or loc.targetRange
        local key = string.format("%s:%d:%d", uri, range.start.line, range.start.character)
        if not seen[key] then
          seen[key] = true
          table.insert(locations, loc)
        end
      end

      if #locations == 1 then
        vim.lsp.util.jump_to_location(locations[1], "utf-8", true)
      else
        vim.lsp.util.set_qflist(vim.lsp.util.locations_to_items(locations, "utf-8"))
        vim.cmd("copen")
      end
    end
  end,
}
