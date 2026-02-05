--  ~/dotfiles/nvim/.config/nvim/lua/plugins/whichkey.lua
return {
  "folke/which-key.nvim",
  event = "VimEnter",
  config = function()
    local wk = require("which-key")
    wk.setup({
      plugins = { spelling = true },
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
      { "<leader>",  group = "Leader",  mode = { "n", "v" } },
      { "<leader>w", group = "Windows", mode = { "n" } },
      -- { "<leader>c", group = "AI",      mode = { "n", "x" } },
      { "<leader>m", group = "Misc" },
      { "<leader>s", group = "Search" },
      { "<leader>t", group = "Toggle" },
    })
  end,
}
