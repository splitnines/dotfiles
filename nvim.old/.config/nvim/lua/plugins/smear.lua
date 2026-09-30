-- ~/dotfiles/nvim/.config/nvim/lua/plugins/smear.lua
return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  opts = {
    stiffness = 0.65,
    trailing_stiffness = 0.45,
    stiffness_insert_mode = 0.6,
    trailing_stiffness_insert_mode = 0.5,
    damping = 0.97,
    damping_insert_mode = 0.97,
    distance_stop_animating = 0.5,
    time_interval = 7,
    smear_between_buffers = true,
    smear_between_neighbor_lines = true,
    smear_insert_mode = true,
  },
}
