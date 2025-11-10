-- ~/dotfiles/nvim/.config/nvim/lua/plugins/todo-comments.lua
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy",
  opts = {
    keywords = {
      NOTE = { icon = "📝", color = "hint", alt = { "INFO" } },
      TODO = { icon = "", color = "info" },
      FIX = { icon = "", color = "error", alt = { "BUG", "FIXME" } },
    },
    comments_only = true,
  },
  config = function(_, opts)
    require("todo-comments").setup(opts)
    local todo = require("todo-comments")
    vim.keymap.set("n", "]t", todo.jump_next, { desc = "Next TODO/NOTE" })
    vim.keymap.set("n", "[t", todo.jump_prev, { desc = "Prev TODO/NOTE" })
  end,
}
