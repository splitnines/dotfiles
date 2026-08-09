-- ~/dotfiles/nvim/.config/nvim/lua/core/autocmds.lua

-- FileType-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.colorcolumn = "79"
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "sh", "bash" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "tcl", "java" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "xml" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Turn off indent guides for text files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    require("ibl").setup_buffer(0, { enabled = false })
  end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- ====================================
-- Open file links in nvim
-- ====================================
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    vim.keymap.set("n", "gx", function()
      local target = vim.fn.expand("<cfile>")

      if vim.fn.filereadable(target) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(target))
        return
      end

      vim.ui.open(target)
    end, { buffer = args.buf })
  end,
})

-- =====================================
-- python format on save
-- =====================================
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format({
      async = false,
      filter = function(client)
        return client.name == "ruff"
      end,
    })
  end,
})
