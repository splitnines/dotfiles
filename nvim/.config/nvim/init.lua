-- Standalone Neovim configuration.
--
-- This file mirrors ~/.config/nvim/init.lua and everything under its lua/
-- directory. Keep the modular configuration untouched while testing this with:
--   NVIM_APPNAME=nvim-single nvim

-- ============================================================================
-- Options
-- ============================================================================
_G.uv = vim.uv or vim.loop

vim.g.mapleader = " "
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
vim.opt.scrolloff = 3
vim.opt.cursorline = true
vim.opt.list = false
vim.g.have_nerd_font = true
vim.opt.inccommand = "split"
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
local bash_path = vim.fn.exepath("bash")
if bash_path ~= "" then
  vim.opt.shell = bash_path
end
vim.opt.autoread = true
vim.opt.clipboard = "unnamedplus"

vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  signs = true,
  update_in_insert = false,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

-- Keep the custom dictionary self-contained instead of requiring spell/ files.
local custom_spellfile = vim.fn.stdpath("data") .. "/spell/en.utf-8.add"
vim.fn.mkdir(vim.fn.fnamemodify(custom_spellfile, ":h"), "p")
if vim.fn.filereadable(custom_spellfile) == 0 then
  vim.fn.writefile({ "Virtualzation", "virtualization", "virtualized" }, custom_spellfile)
end
vim.opt.spellfile = custom_spellfile

-- ============================================================================
-- Keymaps
-- ============================================================================
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- F1 is Esc because I always typo it
vim.keymap.set("n", "<F1>", "<Nop>", { silent = true })
vim.keymap.set({ "i", "v", "c" }, "<F1>", "<Esc>", { silent = true })

vim.keymap.set({ "n", "i", "v", "c" }, "<PageUp>", "<Nop>")
vim.keymap.set({ "n", "i", "v", "c" }, "<PageDown>", "<Nop>")

-- Remap :w1 and wq1 FFS
vim.cmd("cnoreabbrev w1 w!")
vim.cmd("cnoreabbrev wq1 wq!")

-- Remap for home/end of current line
vim.keymap.set("i", "<C-a>", "<C-o>0", { noremap = true })
vim.keymap.set("i", "<C-e>", "<C-o>$", { noremap = true })

-- Window navigation
local map_w = vim.keymap.set
local opts_w = { noremap = true, silent = true }
map_w("n", "<leader>wh", "<C-w>h", vim.tbl_extend("force", opts_w, { desc = "Move to window left" }))
map_w("n", "<leader>wj", "<C-w>j", vim.tbl_extend("force", opts_w, { desc = "Move to window below" }))
map_w("n", "<leader>wk", "<C-w>k", vim.tbl_extend("force", opts_w, { desc = "Move to window above" }))
map_w("n", "<leader>wl", "<C-w>l", vim.tbl_extend("force", opts_w, { desc = "Move to window right" }))
map_w("n", "<leader>wv", "<C-w>v", vim.tbl_extend("force", opts_w, { desc = "Vertical split" }))
map_w("n", "<leader>ws", "<C-w>s", vim.tbl_extend("force", opts_w, { desc = "Horizontal split" }))
map_w("n", "<leader>wq", "<C-w>q", vim.tbl_extend("force", opts_w, { desc = "Close window" }))
map_w("n", "<leader>wc", "<cmd>only<CR>", vim.tbl_extend("force", opts_w, { desc = "Close all other windows" }))
map_w("n", "<leader>wo", "<C-w>o", vim.tbl_extend("force", opts_w, { desc = "Keep only current window" }))
map_w("n", "<leader>w=", "<C-w>=", vim.tbl_extend("force", opts_w, { desc = "Equalize window sizes" }))
map_w("n", "<leader>w+", "<C-w>+", vim.tbl_extend("force", opts_w, { desc = "Increase window height" }))
map_w("n", "<leader>w-", "<C-w>-", vim.tbl_extend("force", opts_w, { desc = "Decrease window height" }))
map_w("n", "<leader>w<", "<C-w><", vim.tbl_extend("force", opts_w, { desc = "Decrease window width" }))
map_w("n", "<leader>w>", "<C-w>>", vim.tbl_extend("force", opts_w, { desc = "Increase window width" }))
map_w("n", "<leader>wr", "<C-w>r", vim.tbl_extend("force", opts_w, { desc = "Rotate windows" }))
map_w("n", "<leader>wx", "<C-w>x", vim.tbl_extend("force", opts_w, { desc = "Exchange windows" }))
map_w("n", "<leader>wt", "<C-w>T", vim.tbl_extend("force", opts_w, { desc = "Move window to new tab" }))
map_w("n", "<leader>wn", "<cmd>tabnew<CR>", vim.tbl_extend("force", opts_w, { desc = "Open new tab" }))
map_w("n", "<leader>wd", "<cmd>tabclose<CR>", vim.tbl_extend("force", opts_w, { desc = "Close current tab" }))

-- Insert mode navigation
vim.keymap.set("i", "<C-h>", "<Left>")
vim.keymap.set("i", "<C-j>", "<Down>")
vim.keymap.set("i", "<C-k>", "<Up>")
vim.keymap.set("i", "<C-l>", "<Right>")

-- Scroll centering
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Insert line above/below
vim.keymap.set("n", "<leader>o", ":put _<CR>", { desc = "Insert line below" })
vim.keymap.set("n", "<leader>O", ":put! _<CR>", { desc = "Insert line above" })

-- Diagnostics
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics" })

-- Buffer scrolling
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>")

-- Jump to definition
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- Explore
vim.keymap.set("n", "<leader>d", "<CMD>Explore<CR>", { desc = "Directory explorer" })

-- Center search results
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Toggle linter
vim.keymap.set("n", "<leader>tl", "<cmd>ToggleLint<CR>", {
  desc = "Toggle LSP diagnostics",
  silent = true,
})

-- Markdown toggle
vim.keymap.set("n", "<leader>tm", function()
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
vim.keymap.set("n", "<leader>ts", function()
  local spell_enabled = vim.opt.spell
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

-- toggle gutter
vim.keymap.set("n", "<leader>tg", function()
  local new_state = not vim.wo.number

  vim.wo.number = new_state
  vim.wo.relativenumber = new_state
  vim.wo.signcolumn = new_state and "yes" or "no"

  vim.notify(
    new_state and "Gutter enabled" or "Gutter disabled",
    vim.log.levels.INFO
  )
end, { desc = "Toggle gutter and line numbers" })

-- toggle zen mode
vim.keymap.set("n", "<leader>tz", function()
  ZEN_MODE = not ZEN_MODE

  if ZEN_MODE then
    ZEN_STATE = {
      number = vim.wo.number,
      relativenumber = vim.wo.relativenumber,
      signcolumn = vim.wo.signcolumn,
      laststatus = vim.o.laststatus,
      cmdheight = vim.o.cmdheight,
      ruler = vim.o.ruler,
    }

    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.o.laststatus = 0
    vim.o.ruler = false
    vim.o.cmdheight = 0

    -- vim.notify("Zen mode enabled", vim.log.levels.INFO)
  else
    vim.wo.number = ZEN_STATE.number
    vim.wo.relativenumber = ZEN_STATE.relativenumber
    vim.wo.signcolumn = ZEN_STATE.signcolumn
    vim.o.laststatus = ZEN_STATE.laststatus
    vim.o.ruler = ZEN_STATE.ruler
    vim.o.cmdheight = ZEN_STATE.cmdheight

    vim.notify("Zen mode disabled", vim.log.levels.INFO)
  end
end, { desc = "Toggle Zen mode" })

-- run formatter manually
vim.keymap.set({ "n", "v" }, "<leader>f", function()
  vim.lsp.buf.format({
    async = true,
    filter = function(client)
      return client.name == "ruff"
    end,
  })
end, { desc = "Format Python with Ruff" })

-- Force :Man to open in current window
vim.cmd([[
   cnoreabbrev <expr> Man
         \ getcmdtype() ==# ':' && getcmdline() ==# 'Man'
         \ ? 'hide Man'
         \ : 'Man'
   ]])

-- ============================================================================
-- Autocommands
-- ============================================================================
-- FileType-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.colorcolumn = "79"
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "sh", "bash" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "tcl", "java" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "xml" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- ====================================
-- Open file links in nvim
-- ====================================
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    vim.keymap.set("n", "gx", function()
      local target = vim.fn.expand("<cfile>")

      if vim.fn.filereadable(target) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(target))
        return
      end

      vim.ui.open(target)
    end, { buffer = args.buf })
  end,
})

-- =====================================
-- python format on save
-- =====================================
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.py",
--   callback = function()
--     vim.lsp.buf.format({
--       async = false,
--       filter = function(client)
--         return client.name == "ruff"
--       end,
--     })
--   end,
-- })

-- ============================================================================
-- Plugin specifications
-- ============================================================================

-- gitsigns.lua
local plugin_gitsigns = {
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
}

-- whichkey.lua
local plugin_whichkey = {
  "folke/which-key.nvim",
  event = "VimEnter",
  config = function()
    local wk = require("which-key")
    wk.setup({
      plugins = { spelling = true },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        nav = true,
      },
      win = {
        border = "single",
        wo = {
          winblend = 0,
        },
      },
      replace = { ["<leader>"] = "SPC", ["<space>"] = "SPC" },
      icons = {
        mappings = vim.g.have_nerd_font,
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
          Space = "<Space> ",
          Tab = "<Tab> ",
        },
      },
    })

    wk.add({
      { "<leader>",  group = "Leader",                           mode = { "n", "v" } },
      { "<leader>w", group = "Windows",                          mode = { "n" } },
      { "<leader>m", group = "Misc" },
      { "<leader>s", group = "Search" },
      { "<leader>t", group = "Toggle" },
      { "<leader>p", group = "Python Debugger",                  mode = { "n" } },
      { '"',         group = "Registers" },
      { "'",         group = "Marks" },
      { "`",         group = "Marks" },
      { "g",         group = "Goto" },
      { "z",         group = "Fold / Spell / View" },
      { "[",         group = "Previous" },
      { "]",         group = "Next" },
      -- nvim.surround
      { "ys",        desc = "Add surround",                      mode = "n" },
      { "yss",       desc = "Add surround line",                 mode = "n" },
      { "yS",        desc = "Add surround with new lines",       mode = "n" },
      { "ySS",       desc = "Add surround line with new lines",  mode = "n" },
      { "ds",        desc = "Delete surround",                   mode = "n" },
      { "cs",        desc = "Change surround",                   mode = "n" },
      { "cS",        desc = "Change surround with new lines",    mode = "n" },
      { "S",         desc = "Surround selection",                mode = "v" },
      { "gS",        desc = "Surround selection with new lines", mode = "v" },
    })
  end,
}

-- dressing.lua
local plugin_dressing = {
  "stevearc/dressing.nvim",
  opts = {},
  event = "VeryLazy",
}

-- autopairs.lua
local plugin_autopairs = {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = true,
}

-- indent.lua
-- local plugin_indent = {
--   "lukas-reineke/indent-blankline.nvim",
--   main = "ibl",
--   opts = {
--     indent = { char = "│" },
--     scope = { enabled = false },
--   },
-- }

-- telescope.lua
local plugin_telescope = {
  "nvim-telescope/telescope.nvim",
  branch = "master",
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
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local themes = require("telescope.themes")
    telescope.setup({
      defaults = {
        borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        initial_mode = "normal",
        mappings = {
          i = {
            ["<Esc>"] = actions.close,
            ["<C-Space>"] = function()
              vim.cmd("stopinsert")
            end,
          },
          n = {
            ["<Esc>"] = actions.close,
            ["<C-Space>"] = function()
              vim.cmd("startinsert")
            end,
          },
        },
        layout_strategy = "flex",
        layout_config = {
          prompt_position = "bottom",
          height = 0.85,
          width = 0.85,
          horizontal = {
            preview_width = 0.5,
          },
          vertical = {
            preview_height = 0.5,
          },
        },
        sorting_strategy = "descending",
      },
      pickers = {
        live_grep = {
          prompt_title = "Search",
          results_title = "Results",
          preview_title = "Preview",
          mappings = {
            i = {
              ["<C-Space>"] = function()
                vim.cmd("stopinsert")
              end,
              ["<Esc>"] = actions.close,
            },
            n = {
              ["<C-Space>"] = function()
                vim.cmd("startinsert")
              end,
              ["<Esc>"] = actions.close,
            },
          },
        },
        find_files = {
          preview_title = "Preview",
          prompt_title = "Search Files",
        },
      },
      extensions = {
        ["ui-select"] = themes.get_dropdown(),
        file_browser = {
          use_ui_input = false,
        },
      },
    })

    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")
    telescope.load_extension("file_browser")

    local builtin = require("telescope.builtin")
    local map = vim.keymap.set

    map("n", "<leader>sf", function()
      builtin.find_files({
        hidden = true,
        no_ignore = true,
        initial_mode = "normal",
        prompt_title = "Find Files",
      })
    end, { desc = "Search files" })
    map("n", "<leader>sb", function()
      builtin.live_grep({
        grep_open_files = true,
        initial_mode = "normal",
        prompt_title = "Search Buffers",
      })
    end, { desc = "Search buffers" })
    map("n", "<leader>sa", function()
      builtin.live_grep({
        cwd = vim.loop.cwd(),
        initial_mode = "normal",
        prompt_title = "Search All Files",
        preview_title = "Preview",
        additional_args = function()
          return {
            "--hidden",
            "--glob", "!.git/*",
            "--glob", "!node_modules/*",
            "--glob", "!dist/*",
            "--glob", "!build/*",
            "--glob", "!target/*",
            "--glob", "!.venv/*",
          }
        end,
      })
    end, { desc = "Search all files" })
    map("n", "<leader><leader>", builtin.buffers, { desc = "Current buffers" })
    map("n", "\\", function()
      telescope.extensions.file_browser.file_browser({
        path = vim.loop.cwd(),
        hidden = true,
        grouped = true,
        respect_gitignore = false,
        previewer = true,
        display_stat = false,
        initial_mode = "normal",
        sorting_strategy = "descending",
      })
    end, { desc = "File browser" })
    map("n", "grr", function()
      require("telescope.builtin").lsp_references({
        initial_mode = "normal",
        show_line = true,
        include_declaration = false,
        previewer = true,
        layout_strategy = "flex",
        sorting_strategy = "descending",
      })
    end, { desc = "LSP references" })

    ----------------------------------------------------------------
    -- enable line numbers in all previews
    ----------------------------------------------------------------
    vim.api.nvim_create_autocmd("User", {
      pattern = "TelescopePreviewerLoaded",
      callback = function()
        vim.wo.number = true
        vim.wo.relativenumber = false
      end,
    })
  end,
}

-- treesitter.lua
local plugin_treesitter = {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()

    require("nvim-treesitter").install({
      "bash",
      "c",
      "lua",
      "python",
    })

    vim.treesitter.language.register("bash", "sh")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sh", "bash" },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}

-- lsp.lua
local plugin_lsp = {
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
        border = "single",
      },
    })

    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "clangd", "bashls", "jdtls", "rust_analyzer", "ruff" },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local cfg = vim.lsp.config

    vim.o.winborder = "single"

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
      cmd_env = {
        SHELLCHECK_PATH = "",
        BACKGROUND_ANALYSIS_MAX_FILES = "0",
      },
      capabilities = capabilities,
      settings = {
        bashIde = {
          shellcheckPath = "",
          backgroundAnalysisMaxFiles = 0,
        },
      },
    })
    vim.lsp.enable("bashls")

    cfg("rust_analyzer", {
      cmd = { "rust-analyzer" },
      filetypes = { "rust" },
      root_markers = { "Cargo.toml", "rust-project.json", ".git" },
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
          },
          check = {
            command = "clippy",
          },
        },
      },
    })
    vim.lsp.enable("rust_analyzer")

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

-- lint.lua
local plugin_lint = {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      sh = { "shellcheck" },
    }

    local group = vim.api.nvim_create_augroup("shellcheck-on-save", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      desc = "Run ShellCheck after saving a shell script",
      group = group,
      callback = function(args)
        if vim.bo[args.buf].filetype == "sh" then
          lint.try_lint("shellcheck")
        end
      end,
    })

    vim.api.nvim_create_user_command("ShellCheck", function()
      lint.try_lint("shellcheck")
    end, { desc = "Run ShellCheck on the current buffer" })
  end,
}

-- conform.lua
local plugin_conform = {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
    },
    formatters = {
      stylua = { prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" } },
      autopep8 = {
        prepend_args = { "--style", "{based_on_style: pep8, column_limit: 79}" },
      },
    },
    format_on_save = function(bufnr)
      local disable = { c = true, cpp = true, python = true }
      return {
        timeout_ms = 500,
        lsp_format = disable[vim.bo[bufnr].filetype] and "never" or "fallback",
      }
    end,
  },
}

-- cmp.lua
local plugin_cmp = {
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

    cmp.setup({
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
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
}

-- ui.lua
local plugin_ui = {
  -- Colorscheme + global UI control
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "dark",
        transparent = true,
      })
      require("onedark").load()

      -- Disable blending so borders are not alpha-erased
      vim.o.winblend = 0
      vim.o.pumblend = 0

      local function set_ui()
        -- Main editor stays transparent
        vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "MsgArea", { bg = "NONE" })

        -- Floating windows MUST have contrast
        vim.api.nvim_set_hl(0, "NormalFloat", {
          bg = "NONE", -- this is the key fix
        })

        vim.api.nvim_set_hl(0, "FloatBorder", {
          fg = "#5c6370",
          bg = "#1e1e1e",
        })

        -- Unified popup + border theme
        local popup_bg = "NONE"
        local border_fg = "#5c6370"
        local sel_bg = "#2a2a3a"
        local sel_fg = "#ffffff"

        -- Global float foundation (used by many plugins + LSP hovers)
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = popup_bg })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_fg, bg = popup_bg })
        vim.api.nvim_set_hl(0, "FloatTitle", { fg = border_fg, bg = popup_bg })

        -- Built-in popup menu / completion
        vim.api.nvim_set_hl(0, "Pmenu", { bg = popup_bg })
        vim.api.nvim_set_hl(0, "PmenuSel", { bg = sel_bg, fg = sel_fg })
        vim.api.nvim_set_hl(0, "PmenuBorder", { link = "FloatBorder" })

        -- nvim-cmp docs
        vim.api.nvim_set_hl(0, "CmpDoc", { bg = popup_bg })
        vim.api.nvim_set_hl(0, "CmpDocBorder", { link = "FloatBorder" })

        -- Telescope
        vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "TelescopePromptNormal", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "TelescopeTitle", { link = "FloatTitle" })

        -- Lazy.nvim
        vim.api.nvim_set_hl(0, "LazyNormal", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "LazyBorder", { fg = "#5c6370", bg = popup_bg })
        vim.api.nvim_set_hl(0, "LazyBackdrop", { bg = "NONE" })

        -- Mason.nvim
        vim.api.nvim_set_hl(0, "MasonNormal", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "MasonBorder", { link = "FloatBorder" })
        -- Which-key (new + old group names for compatibility)
        vim.api.nvim_set_hl(0, "WhichKeyNormal", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "WhichKeyBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "WhichKeyFloat", { link = "NormalFloat" })
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_ui,
      })

      vim.schedule(set_ui)
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local ok, lualine = pcall(require, "lualine")
      if not ok then
        return
      end

      local cfg = lualine.get_config() or {}
      local sections = cfg.sections or {}

      sections = vim.tbl_extend("force", sections, {

        lualine_a = {
          {
            "mode", color = { gui = "reverse" },
          },
        },

        lualine_b = {},
        lualine_c = {},

        lualine_x = {
          {
            "filename", color = { bg = "#2a2a3a", fg = "#abb2bf" },
          },
        },

        lualine_y = {
          {
            "branch",
            padding = { left = 1, right = 1 },
            color = { fg = "#abb2bf" }
          },
          "diff",
        },

        lualine_z = {
          {
            function()
              return tostring(vim.api.nvim_buf_line_count(0))
            end,
            color = {
              bg = "#abb2bf",
              gui = "reverse"
            },
            padding = { left = 1, right = 1 },
          },
          {
            "location",
            color = {
              bg = "#abb2bf",
              gui = "reverse"
            },
          },
        },
      })

      lualine.setup({
        options = {
          icons_enabled        = false,
          theme                = "auto",
          globalstatus         = true,
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
        },
        sections = sections,
      })
    end,
  },
}

-- smear.lua
local plugin_smear = {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  opts = {
    stiffness = 0.65,
    trailing_stiffness = 0.45,
    stiffness_insert_mode = 0.6,
    trailing_stiffness_insert_mode = 0.5,
    damping = 0.97,
    damping_insert_mode = 0.97,
    distance_stop_animating = 0.5,
    time_interval = 7,
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
    smear_insert_mode = true,
  },
}

-- markdown.lua
local plugin_markdown = {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  lazy = true,
  opts = {
    anti_conceal = { enabled = false },
    enabled = false,
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
  end,
}

-- surround.lua
local plugin_surround = {
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  {
    "gregorias/nvim-surround-wk",
    dependencies = {
      "kylechui/nvim-surround",
      "folke/which-key.nvim",
    },
    event = "VeryLazy",
    config = function()
      require("nvim-surround-wk").setup()
    end,
  },
}

-- undotree.lua
-- local plugin_undotree = {
--   "jiaoshijie/undotree",
--   opts = {
--   },
--   keys = {
--     { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
--   },
-- }

-- cisco.lua
local plugin_cisco = {
  {
    "splitnines/cisco.nvim"
  }
}

-- lazy.nvim bootstrap and plugin registration
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazy_uv = vim.uv or vim.loop
if not lazy_uv.fs_stat(lazypath) then
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
    { "tpope/vim-sleuth" },
    { "folke/neodev.nvim", opts = {} },

    plugin_gitsigns,
    plugin_whichkey,
    plugin_dressing,
    plugin_autopairs,
    -- plugin_indent,
    plugin_telescope,
    plugin_treesitter,
    plugin_lsp,
    plugin_lint,
    plugin_conform,
    plugin_cmp,
    plugin_ui,
    plugin_smear,
    plugin_markdown,
    plugin_surround,
    -- plugin_undotree,
    plugin_cisco,
  },
  -- Keep runtime-generated state out of this one-file config directory.
  lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json",
  ui = {
    border = {
      { "┌", "LazyBorder" },
      { "─", "LazyBorder" },
      { "┐", "LazyBorder" },
      { "│", "LazyBorder" },
      { "┘", "LazyBorder" },
      { "─", "LazyBorder" },
      { "└", "LazyBorder" },
      { "│", "LazyBorder" },
    },
  },
})

-- ============================================================================
-- CSV / TSV utilities
-- ============================================================================
-- CSV / TSV utilities for Neovim

------------------------------------------------------------
-- Detect delimiter
------------------------------------------------------------
local function detect_delim()
  local first = vim.fn.getline(1)
  if first:find("\t") then
    return "\t"
  elseif first:find(";") then
    return ";"
  else
    return ","
  end
end

------------------------------------------------------------
-- Open results in scratch window
------------------------------------------------------------
local function open_in_new_window(lines, title)
  vim.cmd("new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "csv"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.modified = false
  if title then
    vim.api.nvim_buf_set_name(0, "[CSV: " .. title .. "]")
  end
end

------------------------------------------------------------
-- Sort
------------------------------------------------------------
local function csv_sort(col, mode)
  local delim = detect_delim()
  local flagmap = { num = "n", numrev = "nr", alpha = "", alpharev = "r" }
  local sort_flag = flagmap[mode] or ""

  local tmp = vim.fn.tempname()
  local head = vim.fn.tempname()
  local body = vim.fn.tempname()
  local out = vim.fn.tempname()

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  vim.fn.writefile(lines, tmp)

  vim.fn.system(("head -n 1 %s > %s"):format(tmp, head))
  vim.fn.system(("tail -n +2 %s > %s"):format(tmp, body))
  vim.fn.system(("sort -t '%s' -k%d,%d%s %s > %s"):format(delim, col, col, sort_flag, body, out))
  local result = vim.fn.systemlist(("cat %s %s"):format(head, out))

  vim.fn.delete(tmp)
  vim.fn.delete(head)
  vim.fn.delete(body)
  vim.fn.delete(out)

  if vim.v.shell_error ~= 0 or #result == 0 then
    vim.notify("CSV sort failed or empty output", vim.log.levels.ERROR)
    return
  end
  open_in_new_window(result, ("Sort(%d)"):format(col))
end

local function make_sort_cmd(name, mode, desc)
  vim.api.nvim_create_user_command(name, function(opts)
    local n = tonumber(opts.args)
    if not n then
      vim.notify("Usage: :" .. name .. " {column_number}", vim.log.levels.ERROR)
      return
    end
    csv_sort(n, mode)
  end, { nargs = 1, desc = desc })
end

------------------------------------------------------------
-- Column select
------------------------------------------------------------
local function csv_select(cols)
  if cols == "" then
    vim.notify("Usage: :CSVSelect {columns}", vim.log.levels.ERROR)
    return
  end
  local delim = detect_delim()
  local fields = {}
  for c in cols:gmatch("%d+") do
    table.insert(fields, ("$%s"):format(c))
  end
  local expr = table.concat(fields, ", ")
  local awk = ("awk -F'%s' -v OFS='%s' '{print %s}'"):format(delim, delim, expr)
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local out = vim.fn.systemlist({ "sh", "-c", awk }, table.concat(lines, "\n"))
  if vim.v.shell_error ~= 0 or #out == 0 then
    vim.notify("CSVSelect failed", vim.log.levels.ERROR)
    return
  end
  open_in_new_window(out, "Select(" .. cols .. ")")
end

vim.api.nvim_create_user_command("CSVSelect", function(opts)
  csv_select(opts.args)
end, { nargs = 1, desc = "Show only specified columns (e.g. :CSVSelect 1,3,5)" })

------------------------------------------------------------
-- Align columns
------------------------------------------------------------
vim.api.nvim_create_user_command("CSVAlign", function()
  local delim = detect_delim()
  local tmp = vim.fn.tempname()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  vim.fn.writefile(lines, tmp)
  local cmd = ("column -t -s'%s' %s"):format(delim, tmp)
  local out = vim.fn.systemlist(cmd)
  vim.fn.delete(tmp)
  if vim.v.shell_error ~= 0 or #out == 0 then
    vim.notify("CSVAlign failed or empty output", vim.log.levels.ERROR)
    return
  end
  open_in_new_window(out, "Align")
end, { desc = "Align CSV columns" })

------------------------------------------------------------
-- List all column names
------------------------------------------------------------
vim.api.nvim_create_user_command("CSVColumns", function()
  local delim = detect_delim()
  local header = vim.fn.getline(1)

  if not header or header == "" then
    vim.notify("No header line found in this file", vim.log.levels.ERROR)
    return
  end

  local fields = vim.split(header, delim, { plain = true, trimempty = true })

  if #fields == 0 then
    vim.notify("Failed to parse header line", vim.log.levels.ERROR)
    return
  end

  vim.cmd("new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "csv"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, fields)
  vim.bo.modified = false
  vim.api.nvim_buf_set_name(0, "[CSV: Columns]")
end, { desc = "Show column names from the header line" })

------------------------------------------------------------
-- Register sort commands
------------------------------------------------------------
make_sort_cmd("CSVSortNum", "num", "Sort numerically ascending")
make_sort_cmd("CSVSortNumRev", "numrev", "Sort numerically descending")
make_sort_cmd("CSVSortAlpha", "alpha", "Sort alphabetically ascending")
make_sort_cmd("CSVSortAlphaRev", "alpharev", "Sort alphabetically descending")

-- ============================================================================
-- Extra commands and mappings
-- ============================================================================
-- ToggleLint + Hover Fix
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
