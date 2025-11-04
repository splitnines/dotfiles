-- ~/dotfiles/nvim/.config/nvim/lua/core/autocmds.lua
-- ===========================
-- Autocmds
-- ===========================

-- FileType-specific Settings
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

-- Turn off vertical lines at indents for text files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    require("ibl").setup_buffer(0, { enabled = false })
  end,
})

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Fix clangd not attaching
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    local active = vim.lsp.get_clients({ name = "clangd" })
    if #active == 0 then
      local root = vim.fs.dirname(vim.fs.find({
        "compile_commands.json",
        "compile_flags.txt",
        ".clangd",
        ".clang-tidy",
        ".git",
      }, { upward = true })[1] or vim.api.nvim_buf_get_name(0))

      vim.lsp.start({
        name = "clangd",
        cmd = { "clangd", "--background-index", "--clang-tidy" },
        root_dir = root,
      })
    end

    local opts = { buffer = 0, silent = true, noremap = true }

    vim.keymap.set("n", "gd", function()
      local params = vim.lsp.util.make_position_params(0, "utf-16")
      local responses = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 1000)
      if not responses or vim.tbl_isempty(responses) then
        vim.notify("No definition found", vim.log.levels.INFO)
        return
      end

      local result
      for _, resp in pairs(responses) do
        if resp.result and #resp.result > 0 then
          result = resp.result
          break
        end
      end
      if not result or vim.tbl_isempty(result) then
        vim.notify("No definition found", vim.log.levels.INFO)
        return
      end

      local target
      for _, item in ipairs(result) do
        if not item.uri:match("%.h$") and not item.uri:match("%.hpp$") then
          target = item
          break
        end
      end
      target = target or result[1]

      local uri = target.uri or target.targetUri
      local range = target.range or target.targetSelectionRange
      local fname = vim.uri_to_fname(uri)
      local pos = { range.start.line + 1, range.start.character }

      if vim.bo.modified then
        vim.cmd("write")
      end
      vim.cmd("edit " .. vim.fn.fnameescape(fname))
      vim.api.nvim_win_set_cursor(0, pos)
    end, opts)
  end,
})
