-- ~/dotfiles/nvim/.config/nvim/lua/plugins/smear.lua
return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  opts = {
    stiffness = 0.8,
    trailing_stiffness = 0.6,
    stiffness_insert_mode = 0.7,
    trailing_stiffness_insert_mode = 0.7,
    damping = 0.95,
    damping_insert_mode = 0.95,
    distance_stop_animating = 0.5,
    time_interval = 7,
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
    smear_insert_mode = true,
  },
}
