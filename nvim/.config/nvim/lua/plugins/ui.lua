-- ~/dotfiles/nvim/.config/nvim/lua/plugins/ui.lua
return {

  ---------------------------------------------------------------------------
  -- Colorscheme + global UI control
  ---------------------------------------------------------------------------
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
          bg = "#1e1e1e", -- this is the key fix
        })

        vim.api.nvim_set_hl(0, "FloatBorder", {
          fg = "#5c6370",
          bg = "#1e1e1e",
        })

        -- Telescope
        vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "NormalFloat" })
        vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })

        -- Completion / popups
        vim.api.nvim_set_hl(0, "Pmenu", { bg = "#1e1e1e" })
        vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#2a2a3a", fg = "#ffffff" })
        vim.api.nvim_set_hl(0, "PmenuBorder", { link = "FloatBorder" })
        vim.api.nvim_set_hl(0, "CmpDoc", { bg = "#1e1e1e" })
        vim.api.nvim_set_hl(0, "CmpDocBorder", { link = "FloatBorder" })

        -- Search
        vim.api.nvim_set_hl(0, "Search", { fg = "#000000", bg = "#E197EF" })
        vim.api.nvim_set_hl(0, "IncSearch", { fg = "#000000", bg = "#E197EF" })
      end

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_ui,
      })

      vim.schedule(set_ui)
    end,
  },

  ---------------------------------------------------------------------------
  -- Lazy.nvim
  ---------------------------------------------------------------------------
  {
    "folke/lazy.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },

  ---------------------------------------------------------------------------
  -- Mason.nvim
  ---------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
    },
  },

  ---------------------------------------------------------------------------
  -- Which-key.nvim
  ---------------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      window = {
        border = "rounded",
        winblend = 0,
      },
    },
  },

  ---------------------------------------------------------------------------
  -- Telescope
  ---------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        border = true,
      },
    },
  },

  ---------------------------------------------------------------------------
  -- Statusline
  ---------------------------------------------------------------------------
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   dependencies = { "nvim-tree/nvim-web-devicons" },
  --   config = function()
  --     require("lualine").setup({
  --       options = {
  --         icons_enabled = true,
  --         theme = "auto",
  --         globalstatus = true,
  --       },
  --     })
  --   end,
  -- },
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
        lualine_y = {
          function()
            return string.format("%d", vim.api.nvim_buf_line_count(0))
          end,
        },
      })

      lualine.setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          globalstatus = true,
        },
        sections = sections,
      })
    end,
  }
}
