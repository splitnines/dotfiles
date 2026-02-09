-- ~/dotfiles/nvim/.config/nvim/lua/core/autocmds.lua
-- ===========================
-- Autocmds
-- ===========================

-- FileType-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "python" },
  callback = function()
    vim.opt_local.colorcolumn = "79"
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "tcl" },
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
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

-- ======================================
-- clangd manual attach
-- ======================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    -- Don’t spawn multiple clangd instances
    local active = vim.lsp.get_clients({ name = "clangd" })
    if #active == 0 then
      local root = vim.fs.dirname(vim.fs.find({
        "compile_commands.json",
        "compile_flags.txt",
        ".clangd",
        ".clang-tidy",
        ".git",
      }, { upward = true })[1] or vim.api.nvim_buf_get_name(0))

      -- Prefer Mason's clangd if installed
      local mason_clangd = vim.fn.expand("~/.local/share/nvim/mason/bin/clangd")
      local clangd_path = vim.fn.executable(mason_clangd) == 1 and mason_clangd or "clangd"

      vim.lsp.start({
        name = "clangd",
        cmd = {
          clangd_path,
          "--background-index",
          "--clang-tidy",
          "--suggest-missing-includes",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
        },
        root_dir = root,
      })
    end
  end,
})

-- ====================================
-- Open file links in nvim
-- ====================================
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    vim.keymap.set("n", "gx", function()
      local target = vim.fn.expand("<cfile>")

      -- local file → open in nvim
      if vim.fn.filereadable(target) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(target))
        return
      end

      -- otherwise → external opener
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

-- Testing transparent bg
vim.cmd [[
highlight Normal guibg=none
highlight NonText guibg=none
highlight Normal ctermbg=none
highlight NonText ctermbg=none
]]
