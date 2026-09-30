-- ~/dotfiles/nvim/.config/nvim/lua/plugins/undotree.lua
return {
  "jiaoshijie/undotree",
  opts = {
  },
  keys = {
    { "<leader>u", "<cmd>lua require('undotree').toggle()<cr>" },
  },
}
