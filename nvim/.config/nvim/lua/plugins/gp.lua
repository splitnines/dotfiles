-- .config/nvim/lua/plugins/gp.lua
return {
  "robitx/gp.nvim",
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("gp").setup({
      openai_api_key = vim.env.OPENAI_API_KEY,


      agents = {
        {
          name = "CodeGPT-o3-mini",
          disable = true
        },
        {
          name = "CodeGPT4o-mini",
          disable = true
        },
        {
          name = "CodeGPT4o",
          disable = true
        },
        {
          name = "ChatGPT4o",
          disable = true
        },
        {
          name = "ChatGPT-o3-mini",
          disable = true
        },
        {
          name = "ChatGPT4o-mini",
          disable = true
        },
        {
          name = "Default",
          chat = true,
          command = true,
          model = { model = "gpt-5-mini" },
          system_prompt = "You are a helpful assistant.",
          style = "popup",
        },
        {
          name = "Code",
          chat = true,
          command = true,
          model = { model = "gpt-5-mini" },
          system_prompt = "You are a senior software engineer. Explain, fix, and refactor code.",
          style = "popup",
        },
        {
          name = "Network",
          chat = true,
          command = true,
          model = { model = "gpt-5-mini" },
          system_prompt =
          "You are a senoir network engineer assistant with a vast knowledge of Cisco IOS-XE routers and switches, network RFC and IEEE standards.",
          style = "popup",
        },
        {
          name = "GPT-5.2",
          chat = true,
          command = true,
          model = { model = "gpt-5.2" },
          system_prompt = "You are a helpful assistant.",
          style = "popup",
        },
        {
          name = "Nano",
          chat = true,
          command = true,
          model = { model = "gpt-5-nano" },
          system_prompt = "You are a helpful assistant.",
          style = "popup",
        },
      },
    })
  end,
}
