---@meta
---@diagnostic disable: undefined-field

-- Define once, globally available
_G.uv = vim.uv or vim.loop

-- ===========================
-- Basic Settings
-- ===========================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 5
vim.opt.cursorline = true
vim.opt.list = false
vim.opt.inccommand = "split"

vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- ===========================
-- FileType-specific Settings
-- ===========================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "python", "markdown" },
  callback = function()
    vim.opt_local.colorcolumn = "79"
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

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

-- Scroll centering
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Insert line above/below
vim.keymap.set("n", "<leader>o", ":put _<CR>")
vim.keymap.set("n", "<leader>O", ":put! _<CR>")

-- Diagnostics
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- ===========================
-- Yank Highlight
-- ===========================
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- ===========================
-- lazy.nvim Setup
-- ===========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Use vim.uv on Neovim ≥ 0.10, fallback to vim.loop for older versions
local uv = vim.uv or vim.loop

---@diagnostic disable-next-line: undefined-field
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- Utility plugins
    { "tpope/vim-sleuth" },
    { "lukas-reineke/virt-column.nvim", opts = {} },
    -- { "lewis6991/gitsigns.nvim", opts = {} },
    {
      "lewis6991/gitsigns.nvim",
      event = { "BufReadPre", "BufNewFile" },
      opts = {
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "-" },
          topdelete = { text = "‾" },
          changedelete = { text = "≈" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = { interval = 1000, follow_files = true },
        attach_to_untracked = true,
        current_line_blame = false,
      },
    },

    {
      "folke/which-key.nvim",
      event = "VimEnter",
      config = function()
        local wk = require("which-key")

        wk.setup({
          plugins = { spelling = true },
          replace = { ["<leader>"] = "SPC", ["<space>"] = "SPC" },
        })

        wk.add({
          { "<leader>", group = "Leader", mode = { "n", "v" } },
          { "<C-w>", group = "Windows", mode = { "n" } },
        })
      end,
    },

    {
      "stevearc/dressing.nvim",
      opts = {},
      event = "VeryLazy",
    },

    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true, -- or a function to customize settings
    },

    -- File explorer (fixed)
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      config = function()
        require("neo-tree").setup({
          filesystem = {
            filtered_items = {
              visible = true,
              hide_dotfiles = false,
              hide_gitignored = false,
            },
          },
        })
        vim.keymap.set("n", "\\", ":Neotree toggle<CR>", { noremap = true, silent = true })
      end,
    },

    -- Telescope fuzzy finder
    {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        local builtin = require("telescope.builtin")
        -- require("telescope").setup({})
        require("telescope").setup({
          defaults = {
            mappings = {
              i = {
                ["<esc>"] = require("telescope.actions").close,
              },
              n = {
                ["<esc>"] = require("telescope.actions").close,
              },
            },
          },
        })
        vim.keymap.set("n", "<leader>sf", builtin.find_files)
        vim.keymap.set("n", "<leader>sg", builtin.live_grep)
        vim.keymap.set("n", "<leader>sb", builtin.buffers)
        vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
      end,
    },

    -- Treesitter
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      main = "nvim-treesitter.configs",
      opts = {
        ensure_installed = { "bash", "c", "lua", "python", "markdown" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      },
    },

    -- LSP
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
        { "mason-org/mason.nvim" },
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        -- Useful status updates for LSP.
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { "j-hui/fidget.nvim", opts = {} },

        -- Allows extra capabilities provided by nvim-cmp
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
        -- Use the new native LSP configuration API
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
      end,
    },

    -- Formatting
    {
      "stevearc/conform.nvim",
      event = "BufWritePre",
      opts = {
        formatters_by_ft = {
          lua = {
            "stylua",
          },
        },
        formatters = {
          stylua = {
            prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
          },
        },
        format_on_save = function(bufnr)
          local disable = { c = true, cpp = true }
          return {
            timeout_ms = 500,
            lsp_format = disable[vim.bo[bufnr].filetype] and "never" or "fallback",
          }
        end,
      },
    },

    -- Completion
    {
      "hrsh7th/nvim-cmp",
      event = "InsertEnter",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
      },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete({}),
            ["<TAB>"] = cmp.mapping.confirm({ select = true }),
          }),
          sources = {
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "path" },
          },
        })
      end,
    },

    {
      "jackMort/ChatGPT.nvim",
      cond = function()
        local path = vim.fn.stdpath("data") .. "/lazy/ChatGPT.nvim"
        ---@diagnostic disable-next-line: undefined-field
        return uv.fs_stat(path) ~= nil
      end,

      event = "VeryLazy",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-telescope/telescope.nvim",
      },
      config = function()
        -- Guard against missing module (e.g., if manually removed)
        local ok, chatgpt = pcall(require, "chatgpt")
        if not ok then
          vim.notify("ChatGPT.nvim not found — skipping setup", vim.log.levels.WARN)
          return
        end

        chatgpt.setup({
          api_key_cmd = "echo $OPENAI_API_KEY",
          openai_params = {
            model = "gpt-5",
            max_tokens = 1024,
          },
          chat = {
            border_left_sign = "🤖",
            welcome_message = "Ask me anything about your code!",
          },
        })

        vim.keymap.set("n", "<leader>cg", "<cmd>ChatGPT<CR>", { desc = "ChatGPT" })
        vim.keymap.set("v", "<leader>ce", "<cmd>ChatGPTEditWithInstruction<CR>", { desc = "ChatGPT Edit" })
      end,
    },

    -- Colorscheme
    {
      "joshdick/onedark.vim",
      priority = 1000,
      init = function()
        vim.cmd.colorscheme("onedark")
        vim.cmd.hi("Comment gui=none")
      end,
    },

    -- To-do highlights
    { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = { signs = false } },
  },
})

-- ===========================
-- Visual Tweaks
-- ===========================
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#010101" })
vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff", bg = "#010101" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1a1a1a" })

-- ===========================
-- Diagnostics
-- ===========================
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
})

-- ===========================
-- Lint Toggle
-- ===========================
local lint_disabled = {}
vim.api.nvim_create_user_command("ToggleLint", function()
  local bufnr = vim.api.nvim_get_current_buf()
  if lint_disabled[bufnr] then
    lint_disabled[bufnr] = false
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.diagnostic.on_publish_diagnostics
    print("Diagnostics enabled")
  else
    lint_disabled[bufnr] = true
    local orig = vim.lsp.handlers["textDocument/publishDiagnostics"]
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

-- ===========================
-- Misc Fixes
-- ===========================
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })
