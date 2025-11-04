-- ~/dotfiles/nvim/.config/nvim/lua/plugins/ui.lua
return {
  -- Colorscheme
  {
    "joshdick/onedark.vim",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("onedark")
      vim.cmd.hi("Comment gui=none")
    end,
  },

  -- Statusline
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
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 2 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = {
            function()
              return vim.api.nvim_buf_line_count(0)
            end,
          },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#E06C75", bold = true })
      vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#61AFEF", italic = true })
      vim.api.nvim_set_hl(0, "DashboardButton", { fg = "#98C379", bold = true })
      vim.api.nvim_set_hl(0, "DashboardButtonShortcut", { fg = "#C678DD" })
      vim.api.nvim_set_hl(0, "DashboardButtonHover", { fg = "#282C34", bg = "#98C379", bold = true })
      dashboard.section.header.val = {
        " '##::: ##:'########::'#######::'##::::'##:'####:'##::::'##: ",
        "  ###:: ##: ##.....::'##.... ##: ##:::: ##:. ##:: ###::'###: ",
        "  ####: ##: ##::::::: ##:::: ##: ##:::: ##:: ##:: ####'####: ",
        "  ## ## ##: ######::: ##:::: ##: ##:::: ##:: ##:: ## ### ##: ",
        "  ##. ####: ##...:::: ##:::: ##:. ##:: ##::: ##:: ##. #: ##: ",
        "  ##:. ###: ##::::::: ##:::: ##::. ## ##:::: ##:: ##:.:: ##: ",
        "  ##::. ##: ########:. #######::::. ###::::'####: ##:::: ##: ",
        "  ..::::..::........:::.......::::::...:::::....::..:::::..:: ",
        "",
        "               ⚡ Welcome to Neovim ⚡               ",
        "",
      }
      local v = vim.version()
      local version_str = string.format("Neovim %d.%d.%d", v.major, v.minor, v.patch)
      dashboard.section.footer.val = string.format(
        "  %s  •  %s  • %s",
        os.date("%A, %B %d %Y  •  %H:%M:%S"),
        os.getenv("USER"),
        version_str
      )
      dashboard.section.footer.opts.hl = "DashboardFooter"
      dashboard.section.buttons.val = {
        dashboard.button("e", "  New File", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "󰱼  Find File", ":Telescope find_files<CR>"),
        dashboard.button("r", "  Recent Files", ":Telescope oldfiles<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
      }
      alpha.setup(dashboard.config)
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#0a0a0a" })
          vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff", bg = "#0a0a0a" })
          vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1a1a1a" })
        end,
      })

      -- Trigger once on startup (so it applies immediately)
      vim.api.nvim_exec_autocmds("ColorScheme", {})
    end,
  },
}
