-- ~/.config/nvim/lua/local_colors.lua
-- Local UI overrides for this computer

vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#101010" })
vim.api.nvim_set_hl(0, "Normal", { fg = "#eeeeee", bg = "#0c0c18" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#121222" })

local border_color = "#aaaaaa"
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = border_color, bg = "#1a1a2a" })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = border_color, bg = "#1a1a2a" })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = border_color, bg = "#1a1a2a" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_color, bg = "#1a1a2a" })
