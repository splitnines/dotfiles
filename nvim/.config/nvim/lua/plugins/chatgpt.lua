-- ~/dotfiles/nvim/.config/nvim/lua/plugins/chatgpt.lua
return {
  "jackMort/ChatGPT.nvim",
  cond = function()
    local path = vim.fn.stdpath("data") .. "/lazy/ChatGPT.nvim"
    ---@diagnostic disable-next-line: undefined-field
    return (vim.uv or vim.loop).fs_stat(path) ~= nil
  end,
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local ok, chatgpt = pcall(require, "chatgpt")
    if not ok then
      vim.notify("ChatGPT.nvim not found — skipping setup", vim.log.levels.WARN)
      return
    end

    chatgpt.setup({
      api_key_cmd = "echo $OPENAI_API_KEY",
      openai_params = {
        -- model = "gpt-4.1-mini",
        model = "gpt-5-mini",
        -- max_tokens = 4096,
        max_completion_tokens = 4096,
        -- temperature = 0.7,
      },
      chat = {
        border_left_sign = "🤖",
        welcome_message = "Ask me anything about your code!",
        -- render markdown in the window
        window_options = {
          filetype = "markdown",
          conceallevel = 2,
          wrap = true,
        },
      },
    })

    vim.keymap.set("n", "<leader>c", "<cmd>ChatGPT<CR>", { desc = "ChatGPT" })
    vim.keymap.set("v", "<leader>ce", "<cmd>ChatGPTRun explain_code<CR>", { desc = "ChatGPT Explain Code" })
    vim.keymap.set("v", "<leader>cd", "<cmd>ChatGPTRun docstring<CR>", { desc = "ChatGPT Doc String" })
  end,
}
