return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      sh = { "shellcheck" },
    }

    local group = vim.api.nvim_create_augroup("shellcheck-on-save", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      desc = "Run ShellCheck after saving a shell script",
      group = group,
      callback = function(args)
        if vim.bo[args.buf].filetype == "sh" then
          lint.try_lint("shellcheck")
        end
      end,
    })

    vim.api.nvim_create_user_command("ShellCheck", function()
      lint.try_lint("shellcheck")
    end, { desc = "Run ShellCheck on the current buffer" })
  end,
}
