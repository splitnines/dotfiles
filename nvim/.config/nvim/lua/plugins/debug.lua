return {
  "mfussenegger/nvim-dap",
  ft = "python",
  dependencies = {
    "mfussenegger/nvim-dap-python",
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    local debugpy_python = vim.fn.stdpath("data")
        .. "/mason/packages/debugpy/venv/bin/python"

    if vim.fn.executable(debugpy_python) ~= 1 then
      vim.notify(
        "Mason debugpy was not found at: " .. debugpy_python,
        vim.log.levels.ERROR
      )
      return
    end

    require("dap-python").setup(debugpy_python)

    dapui.setup({
      controls = {
        enabled = true,
        element = "repl",
      },
      floating = {
        border = "rounded",
      },
    })

    require("nvim-dap-virtual-text").setup({
      commented = true,
    })

    -- Open and close the debugger UI with each session.
    dap.listeners.after.event_initialized.dapui_config = function()
      dapui.open()
    end

    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end

    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- Debugger signs.
    vim.fn.sign_define("DapBreakpoint", {
      text = "●",
      texthl = "DiagnosticError",
    })

    vim.fn.sign_define("DapBreakpointCondition", {
      text = "◆",
      texthl = "DiagnosticWarn",
    })

    vim.fn.sign_define("DapStopped", {
      text = "▶",
      texthl = "DiagnosticInfo",
      -- linehl = "Visual",
    })

    vim.fn.sign_define("DapLogPoint", {
      text = "◆",
      texthl = "DiagnosticInfo",
    })

    local map = vim.keymap.set

    map("n", "<leader>pc", dap.continue, {
      desc = "Debug: start / continue",
    })

    map("n", "<leader>pb", dap.toggle_breakpoint, {
      desc = "Debug: toggle breakpoint",
    })

    map("n", "<leader>pB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, {
      desc = "Debug: conditional breakpoint",
    })

    map("n", "<leader>po", dap.step_over, {
      desc = "Debug: step over",
    })

    map("n", "<leader>pi", dap.step_into, {
      desc = "Debug: step into",
    })

    map("n", "<leader>pO", dap.step_out, {
      desc = "Debug: step out",
    })

    map("n", "<leader>pp", dap.pause, {
      desc = "Debug: pause",
    })

    map("n", "<leader>pr", dap.repl.open, {
      desc = "Debug: open REPL",
    })

    map("n", "<leader>pl", dap.run_last, {
      desc = "Debug: run last session",
    })

    map("n", "<leader>pt", dap.terminate, {
      desc = "Debug: terminate",
    })

    map("n", "<leader>pu", dapui.toggle, {
      desc = "Debug: toggle UI",
    })
  end,
}
