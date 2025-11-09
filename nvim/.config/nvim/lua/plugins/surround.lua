-- ~/dotfiles/nvim/.config/nvim/lua/plugins/surround.lua
return {
  "kylechui/nvim-surround",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      keymaps = {
        insert = false, -- disable insert mode
        insert_line = false, -- disable insert-line mode

        -- Normal mode
        normal = "<leader>ra", -- Add surrounding
        normal_cur = "<leader>rA", -- Add surrounding around current word
        normal_line = "<leader>rl", -- Add surrounding around current line
        normal_cur_line = "<leader>rL", -- Add surrounding around cursor line
        delete = "<leader>rd", -- Delete surrounding
        change = "<leader>rc", -- Change surrounding
        change_line = false, -- disable change-line mapping
      },
    })
  end,
}
