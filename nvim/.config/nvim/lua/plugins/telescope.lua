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
        mappings = {
          i = {
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
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
      },
      extensions = { ["ui-select"] = themes.get_dropdown() },
    })

    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")
    telescope.load_extension("file_browser")

    local builtin = require("telescope.builtin")
    local map = vim.keymap.set

    map("n", "<leader>sf", builtin.find_files, { desc = "[s]earch [f]iles" })
    map("n", "<leader>sg", function()
      require("telescope.builtin").live_grep({
        grep_open_files = true, -- search only in open buffers
        prompt_title = "Grep Buffers",
      })
    end, { desc = "[s]earch [g]rep in open buffers" })
    map("n", "<leader>sG", function()
      require("telescope.builtin").live_grep({
        cwd = vim.loop.cwd(),
        hidden = true,
        prompt_title = "Grep All Files",
        additional_args = function(_)
          return {
            "--no-ignore",
            "--hidden",
            "--glob",
            "!.git/*",
          }
        end,
      })
    end, { desc = "[s]earch by [G]rep all files" })

    map("n", "<leader>sd", builtin.diagnostics, { desc = "[s]earch [d]iagnostics" })
    map("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Buffers" })
    map("n", "\\", function()
      telescope.extensions.file_browser.file_browser({
        path = vim.loop.cwd(),
        hidden = true,
        grouped = true,
        respect_gitignore = false,
        previewer = true,
        display_stat = false,
        initial_mode = "insert",
        -- layout_config = { height = 0.7 },
        sorting_strategy = "descending",
      })
    end, { desc = "Telescope File Browser" })

    map("n", "grr", function()
      require("telescope.builtin").lsp_references({
        show_line = true,
        include_declaration = false,
        previewer = true,
        layout_strategy = "flex",
        sorting_strategy = "descending",
      })
    end, { desc = "LSP [r]eferences" })

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
