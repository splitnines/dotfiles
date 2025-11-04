-- ~/dotfiles/nvim/.config/nvim/lua/plugins/todo-comments.lua
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPost", "BufNewFile" },
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
    vim.keymap.set("n", "]t", function()
      require("todo-comments").jump_next()
    end, { desc = "Next TODO/NOTE" })
    vim.keymap.set("n", "[t", function()
      require("todo-comments").jump_prev()
    end, { desc = "Prev TODO/NOTE" })
  end,
}
