-- ~/dotfiles/nvim/.config/nvim/lua/plugins/ui.lua
return {
  -- Colorscheme
  {
    "joshdick/onedark.vim",
    priority = 1000,
    transparent = true,
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
      -- ===========================
      -- Color Overrides
      -- ===========================
      local function set_default_colors()
        -- vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#0a0a0a" })
        -- vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff", bg = "#0a0a0a" })
        -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#141414" })
        vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff", bg = "NONE", ctermbg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalNC", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "ColorColumn", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
        local border_color = "#c8c8c8"
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = border_color, bg = "#1e1e1e" })
        vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = border_color, bg = "#1e1e1e" })
        vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = border_color, bg = "#1e1e1e" })
        -- vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_color, bg = "#1e1e1e" })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_color, bg = "NONE" })

        -- Search highlights
        vim.api.nvim_set_hl(0, "Search", { fg = "#000000", bg = "#E197EF" })
        vim.api.nvim_set_hl(0, "IncSearch", { fg = "#000000", bg = "#E197EF" })

        -- vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#c8c8c8", bg = "#1e1e1e" })
        -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#141414" })

        -- Darken the nvim-cmp popup background
        vim.api.nvim_set_hl(0, "Pmenu", { bg = "#1e1e2e", fg = "#c0c0c0" })
        vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#2a2a3a", fg = "#ffffff" })
        vim.api.nvim_set_hl(0, "PmenuBorder", { bg = "#1e1e2e", fg = "#3b3b4b" })
        vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#1c1c28" })
        vim.api.nvim_set_hl(0, "CmpDocBorder", { bg = "#1c1c28", fg = "#3b3b4b" })
      end

      local local_colors = vim.fn.stdpath("config") .. "/lua/local_colors.lua"

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          if vim.fn.filereadable(local_colors) == 1 then
            local ok, err = pcall(dofile, local_colors)
            if not ok then
              vim.notify("Error loading local_colors.lua: " .. err, vim.log.levels.ERROR)
              set_default_colors()
            end
          else
            set_default_colors()
          end
        end,
      })

      -- Trigger ColorScheme now so the highlights apply immediately
      vim.api.nvim_exec_autocmds("ColorScheme", {})
    end,
  },
}
