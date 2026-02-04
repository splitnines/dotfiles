-- .config/nvim/lua/plugins/gp.lua
return {
  "robitx/gp.nvim",
  lazy = false,
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("gp").setup({
      providers = {
        azure = {
          endpoint = "https://chat-ai.cisco.com",
          api_version = "2024-08-01-preview",

          -- This is the Cisco OAuth token
          api_key = os.getenv("CISCO_OAUTH_TOKEN"),

          -- Explicit headers (gp.nvim will still send api-key)
          headers = {
            ["Accept"] = "*/*",
          },
        },
      },
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
          name = "ChatGPT",
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
          name = "Linux",
          chat = true,
          command = true,
          model = { model = "gpt-5-mini" },
          system_prompt =
          "You are a linux expert assigned to help with all things related to linux servers, desktops, applications and scripting.",
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
        {
          name = "CiscoAzureChat",
          chat = true,
          provider = "azure",
          model = {
            -- Must match what Cisco expects; this is NOT validated by Azure
            model = "gpt-4o", -- or whatever api_params["model"] was
          },
          system_prompt = "You are a helpful assistant",

          -- Mirrors: user=f'{{"appkey": "{api_key}"}}'
          user = string.format(
            '{"appkey":"%s"}',
            os.getenv("OPENAI_API_KEY")
          ),
        },
      },
    })
  end,
}
