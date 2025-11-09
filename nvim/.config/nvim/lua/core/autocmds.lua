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

    -- Keymap for go to definition
    --   local opts = { buffer = 0, silent = true, noremap = true }
    --   vim.keymap.set("n", "gd", function()
    --     local params = vim.lsp.util.make_position_params(0, "utf-16")
    --     local responses = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 1000)
    --     if not responses or vim.tbl_isempty(responses) then
    --       vim.notify("No definition found", vim.log.levels.INFO)
    --       return
    --     end
    --
    --     local result
    --     for _, resp in pairs(responses) do
    --       if resp.result and #resp.result > 0 then
    --         result = resp.result
    --         break
    --       end
    --     end
    --     if not result or vim.tbl_isempty(result) then
    --       vim.notify("No definition found", vim.log.levels.INFO)
    --       return
    --     end
    --
    --     local target
    --     for _, item in ipairs(result) do
    --       if not item.uri:match("%.h$") and not item.uri:match("%.hpp$") then
    --         target = item
    --         break
    --       end
    --     end
    --     target = target or result[1]
    --
    --     local uri = target.uri or target.targetUri
    --     local range = target.range or target.targetSelectionRange
    --     local fname = vim.uri_to_fname(uri)
    --     local pos = { range.start.line + 1, range.start.character }
    --
    --     if vim.bo.modified then
    --       vim.cmd("write")
    --     end
    --     vim.cmd("edit " .. vim.fn.fnameescape(fname))
    --     vim.api.nvim_win_set_cursor(0, pos)
    --   end, opts)
  end,
})
