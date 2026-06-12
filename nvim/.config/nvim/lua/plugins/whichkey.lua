--  ~/dotfiles/nvim/.config/nvim/lua/plugins/whichkey.lua
return {
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
        border = "rounded",
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
