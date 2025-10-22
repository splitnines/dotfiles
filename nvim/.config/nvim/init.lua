--@meta
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
  pattern = { "c", "cpp", "python" },
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

-- Turn off vertical lines at indents
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    require("ibl").setup_buffer(0, { enabled = false })
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
    -- git status in the gutter
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

    -- Show pending keybinds
    {
      "folke/which-key.nvim",
      event = "VimEnter",
      config = function()
        local wk = require("which-key")

        wk.setup({
          plugins = { spelling = true },
          replace = { ["<leader>"] = "SPC", ["<space>"] = "SPC" },
          icons = {
            -- set icon mappings to true if you have a Nerd Font
            mappings = vim.g.have_nerd_font,
            -- if using a Nerd Font, use default icons
            keys = vim.g.have_nerd_font and {} or {
              Up = "<Up> ",
              Down = "<Down> ",
              Left = "<Left> ",
              Right = "<Right> ",
              C = "<C-…> ",
              M = "<M-…> ",
              D = "<D-…> ",
              S = "<S-…> ",
              CR = "<CR> ",
              Esc = "<Esc> ",
              ScrollWheelDown = "<ScrollWheelDown> ",
              ScrollWheelUp = "<ScrollWheelUp> ",
              NL = "<NL> ",
              BS = "<BS> ",
              Space = "<Space> ",
              Tab = "<Tab> ",
              F1 = "<F1>",
              F2 = "<F2>",
              F3 = "<F3>",
              F4 = "<F4>",
              F5 = "<F5>",
              F6 = "<F6>",
              F7 = "<F7>",
              F8 = "<F8>",
              F9 = "<F9>",
              F10 = "<F10>",
              F11 = "<F11>",
              F12 = "<F12>",
            },
          },
        })

        wk.add({
          -- key groups
          { "<leader>", group = "Leader", mode = { "n", "v" } },
          { "<C-w>", group = "Windows", mode = { "n" } },
          { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
          { "<leader>d", group = "[D]ocument" },
          { "<leader>r", group = "[R]ename" },
          { "<leader>s", group = "[S]earch" },
          { "<leader>w", group = "[W]orkspace" },
          { "<leader>t", group = "[T]oggle" },
          { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        })
      end,
    },

    -- Fix language filter window in Mason
    {
      "stevearc/dressing.nvim",
      opts = {},
      event = "VeryLazy",
    },

    -- Auto close brackets
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true,
    },

    -- Vertical lines at indent levels
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {
        indent = {
          char = "│",
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
        },
      },
    },

    -- File browser
    {
      "nvim-telescope/telescope-file-browser.nvim",
      dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
      config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local fb_actions = require("telescope").extensions.file_browser.actions

        telescope.setup({
          defaults = {
            path_display = function(_, path)
              local max_width = 64 -- adjust for your terminal width
              if #path <= max_width then
                return path
              end
              return path:sub(1, max_width - 3) .. "…"
            end,
          },

          extensions = {
            file_browser = {
              hijack_netrw = true,
              hidden = true,
              grouped = true,
              respect_gitignore = false,
              initial_mode = "normal",
              previewer = true,
              display_stat = false,
              mappings = {
                ["n"] = {
                  ["h"] = fb_actions.goto_parent_dir,
                  ["l"] = fb_actions.open,
                  ["N"] = fb_actions.create,
                  ["r"] = fb_actions.rename,
                  ["d"] = fb_actions.remove,
                  ["y"] = fb_actions.copy,
                  ["m"] = fb_actions.move,
                },
                ["i"] = {
                  ["<CR>"] = function(prompt_bufnr)
                    local entry = require("telescope.actions.state").get_selected_entry()
                    if entry and entry.path and vim.fn.isdirectory(entry.path) == 1 then
                      fb_actions.goto_parent_dir(prompt_bufnr)
                      telescope.extensions.file_browser.file_browser({
                        path = entry.path,
                        select_buffer = true,
                      })
                    else
                      actions.select_default(prompt_bufnr)
                    end
                  end,
                  ["<C-h>"] = fb_actions.goto_parent_dir,
                },
              },
            },
          },
        })

        telescope.load_extension("file_browser")

        vim.keymap.set("n", "\\", function()
          telescope.extensions.file_browser.file_browser({
            path = vim.loop.cwd(),
            select_buffer = false,
            hidden = true,
          })
        end, { desc = "Telescope File Browser" })
      end,
    },

    -- Telescope fuzzy finder
    {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      event = "VeryLazy",
      dependencies = {
        "nvim-lua/plenary.nvim",
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          build = "make",
          cond = function()
            return vim.fn.executable("make") == 1
          end,
        },
        "nvim-telescope/telescope-ui-select.nvim",
        { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
      },

      opts = function()
        local actions = require("telescope.actions")
        local themes = require("telescope.themes")

        return {
          defaults = {
            mappings = {
              i = {
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
                ["<Esc>"] = actions.close,
              },
            },
            layout_strategy = "flex",
            layout_config = {
              prompt_position = "bottom",
            },
            sorting_strategy = "descending",
            display_stat = false,
          },
          pickers = {
            buffers = {
              previewer = true,
            },
          },
          extensions = {
            ["ui-select"] = themes.get_dropdown(),
          },
        }
      end,

      config = function(_, opts)
        local telescope = require("telescope")
        telescope.setup(opts)

        -- Load optional extensions safely
        pcall(telescope.load_extension, "fzf")
        pcall(telescope.load_extension, "ui-select")

        local builtin = require("telescope.builtin")

        -- Keymaps
        local map = vim.keymap.set
        map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
        map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
        map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
        map("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect" })
        map("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
        map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
        map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
        map("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
        map("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        map("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

        map("n", "<leader>/", function()
          builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
            layout_config = { prompt_position = "bottom" },
            sorting_strategy = "descending",
          }))
        end, { desc = "[/] Fuzzily search in current buffer" })

        map("n", "<leader>s/", function()
          builtin.live_grep({
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
          })
        end, { desc = "[S]earch [/] in Open Files" })

        map("n", "<leader>sn", function()
          builtin.find_files({ cwd = vim.fn.stdpath("config") })
        end, { desc = "[S]earch [N]eovim config files" })
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

    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        local harpoon = require("harpoon")

        -- REQUIRED
        harpoon:setup()
        -- REQUIRED

        -- Keymaps
        vim.keymap.set("n", "<leader>a", function()
          harpoon:list():add()
        end)
        vim.keymap.set("n", "<C-e>", function()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end)

        vim.keymap.set("n", "<C-h>", function()
          harpoon:list():select(1)
        end)
        vim.keymap.set("n", "<C-t>", function()
          harpoon:list():select(2)
        end)
        vim.keymap.set("n", "<C-n>", function()
          harpoon:list():select(3)
        end)
        vim.keymap.set("n", "<C-s>", function()
          harpoon:list():select(4)
        end)

        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "<C-S-P>", function()
          harpoon:list():prev()
        end)
        vim.keymap.set("n", "<C-S-N>", function()
          harpoon:list():next()
        end)
      end,
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

    -- ChatGPT plugin
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

    -- Status line
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("lualine").setup({
          options = {
            icons_enabled = true,
            theme = "auto",
            component_separators = { left = "▏", right = "▕" },
            section_separators = { left = "", right = "" },
            disabled_filetypes = { "NvimTree", "packer", "lazy" },
            always_divide_middle = true,
            globalstatus = true,
          },
          sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = { { "filename", path = 2 } }, -- path=1 shows relative, path=2 shows full
            lualine_x = {
              "encoding",
              "fileformat",
              "filetype",
            },
            lualine_y = {
              function()
                local line_count = vim.api.nvim_buf_line_count(0)
                return line_count
              end,
            },
            lualine_z = { "location" },
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { "filename" },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
          },
          tabline = {},
          extensions = { "fugitive", "quickfix", "nvim-tree" },
        })
      end,
    },
  },
})
-- END PLUGINS

-- CSV Tools
require("csv.tools")

vim.api.nvim_create_user_command("CSVAlign", function()
  vim.cmd("%!column -t -s,")
end, { desc = "Align CSV columns (no borders)" })

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
---@diagnostic disable: duplicate-set-field
do
  local lint_disabled = {}
  local orig_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]

  vim.api.nvim_create_user_command("ToggleLint", function()
    local bufnr = vim.api.nvim_get_current_buf()

    if lint_disabled[bufnr] then
      -- Re-enable diagnostics
      lint_disabled[bufnr] = false
      vim.lsp.handlers["textDocument/publishDiagnostics"] = orig_publish_diagnostics
      print("Diagnostics enabled")
    else
      -- Disable diagnostics for this buffer
      lint_disabled[bufnr] = true
      vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
        if vim.uri_to_bufnr(result.uri) == bufnr then
          return
        end
        return orig_publish_diagnostics(err, result, ctx, config)
      end
      vim.diagnostic.reset(nil, bufnr)
      print("Diagnostics disabled")
    end
  end, {})
end

-- ===========================
-- Misc Fixes
-- ===========================
vim.opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
vim.api.nvim_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { noremap = true, silent = true })
