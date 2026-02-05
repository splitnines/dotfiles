-- ~/dotfiles/nvim/.config/nvim/lua/plugins/telescope.lua
return {
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
  config = function(_)
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local themes = require("telescope.themes")
    telescope.setup({
      defaults = {
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
      extensions = { ["ui-select"] = themes.get_dropdown() },
    })

    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")
    telescope.load_extension("file_browser")

    local builtin = require("telescope.builtin")
    local map = vim.keymap.set

    map("n", "<leader>sf", builtin.find_files, { desc = "Search files" })
    map("n", "<leader>sb", function()
      require("telescope.builtin").live_grep({
        prompt_title = "Search Buffers",
      })
    end, { desc = "Search buffers" })
    map("n", "<leader>sa", function()
      require("telescope.builtin").live_grep({
        cwd = vim.loop.cwd(),
        hidden = true,
        prompt_title = "Search All Files",
        preview_title = "Preview",
        additional_args = function(_)
          return {
            "--no-ignore",
            "--hidden",
            "--glob",
            "!.git/*",
          }
        end,
      })
    end, { desc = "Search all files" })

    -- map("n", "<leader>q", builtin.diagnostics, { desc = "Search diagnostics" })
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
