-- CSV / TSV utilities for Neovim

------------------------------------------------------------
-- Detect delimiter
------------------------------------------------------------
local function detect_delim()
  local first = vim.fn.getline(1)
  if first:find("\t") then
    return "\t"
  elseif first:find(";") then
    return ";"
  else
    return ","
  end
end

------------------------------------------------------------
-- Open results in scratch window
------------------------------------------------------------
local function open_in_new_window(lines, title)
  vim.cmd("new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "csv"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.modified = false
  if title then
    vim.api.nvim_buf_set_name(0, "[CSV: " .. title .. "]")
  end
end

------------------------------------------------------------
-- Sort
------------------------------------------------------------
local function csv_sort(col, mode)
  local delim = detect_delim()
  local flagmap = { num = "n", numrev = "nr", alpha = "", alpharev = "r" }
  local sort_flag = flagmap[mode] or ""

  local tmp = vim.fn.tempname()
  local head = vim.fn.tempname()
  local body = vim.fn.tempname()
  local out = vim.fn.tempname()

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  vim.fn.writefile(lines, tmp)

  vim.fn.system(("head -n 1 %s > %s"):format(tmp, head))
  vim.fn.system(("tail -n +2 %s > %s"):format(tmp, body))
  vim.fn.system(("sort -t '%s' -k%d,%d%s %s > %s"):format(delim, col, col, sort_flag, body, out))
  local result = vim.fn.systemlist(("cat %s %s"):format(head, out))

  vim.fn.delete(tmp)
  vim.fn.delete(head)
  vim.fn.delete(body)
  vim.fn.delete(out)

  if vim.v.shell_error ~= 0 or #result == 0 then
    vim.notify("CSV sort failed or empty output", vim.log.levels.ERROR)
    return
  end
  open_in_new_window(result, ("Sort(%d)"):format(col))
end

local function make_sort_cmd(name, mode, desc)
  vim.api.nvim_create_user_command(name, function(opts)
    local n = tonumber(opts.args)
    if not n then
      vim.notify("Usage: :" .. name .. " {column_number}", vim.log.levels.ERROR)
      return
    end
    csv_sort(n, mode)
  end, { nargs = 1, desc = desc })
end

------------------------------------------------------------
-- Column select
------------------------------------------------------------
local function csv_select(cols)
  if cols == "" then
    vim.notify("Usage: :CSVSelect {columns}", vim.log.levels.ERROR)
    return
  end
  local delim = detect_delim()
  local fields = {}
  for c in cols:gmatch("%d+") do
    table.insert(fields, ("$%s"):format(c))
  end
  local expr = table.concat(fields, ", ")
  local awk = ("awk -F'%s' -v OFS='%s' '{print %s}'"):format(delim, delim, expr)
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local out = vim.fn.systemlist({ "sh", "-c", awk }, table.concat(lines, "\n"))
  if vim.v.shell_error ~= 0 or #out == 0 then
    vim.notify("CSVSelect failed", vim.log.levels.ERROR)
    return
  end
  open_in_new_window(out, "Select(" .. cols .. ")")
end

vim.api.nvim_create_user_command("CSVSelect", function(opts)
  csv_select(opts.args)
end, { nargs = 1, desc = "Show only specified columns (e.g. :CSVSelect 1,3,5)" })

------------------------------------------------------------
-- Align columns
------------------------------------------------------------
vim.api.nvim_create_user_command("CSVAlign", function()
  local delim = detect_delim()
  local tmp = vim.fn.tempname()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  vim.fn.writefile(lines, tmp)
  local cmd = ("column -t -s'%s' %s"):format(delim, tmp)
  local out = vim.fn.systemlist(cmd)
  vim.fn.delete(tmp)
  if vim.v.shell_error ~= 0 or #out == 0 then
    vim.notify("CSVAlign failed or empty output", vim.log.levels.ERROR)
    return
  end
  open_in_new_window(out, "Align")
end, { desc = "Align CSV columns" })

------------------------------------------------------------
-- List all column names
------------------------------------------------------------
vim.api.nvim_create_user_command("CSVColumns", function()
  local delim = detect_delim()
  local header = vim.fn.getline(1)

  if not header or header == "" then
    vim.notify("No header line found in this file", vim.log.levels.ERROR)
    return
  end

  local fields = vim.split(header, delim, { plain = true, trimempty = true })

  if #fields == 0 then
    vim.notify("Failed to parse header line", vim.log.levels.ERROR)
    return
  end

  vim.cmd("new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "csv"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, fields)
  vim.bo.modified = false
  vim.api.nvim_buf_set_name(0, "[CSV: Columns]")
end, { desc = "Show column names from the header line" })

------------------------------------------------------------
-- Register sort commands
------------------------------------------------------------
make_sort_cmd("CSVSortNum", "num", "Sort numerically ascending")
make_sort_cmd("CSVSortNumRev", "numrev", "Sort numerically descending")
make_sort_cmd("CSVSortAlpha", "alpha", "Sort alphabetically ascending")
make_sort_cmd("CSVSortAlphaRev", "alpharev", "Sort alphabetically descending")
