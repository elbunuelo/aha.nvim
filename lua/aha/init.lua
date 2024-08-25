local M = {}

local link_utils = require('aha.link')

function M.setup()
  if not link_utils.AHA_BASE_URL then
    return
  end

  vim.keymap.set("n", "<Leader>!l", function()
    -- Try WORD under cursor first:
    local replacing = true
    local reference_num = vim.fn.expand('<cWORD>')
    local link_url = link_utils.get_link(reference_num)

    -- If the WORD didn't pan out, then prompt the user
    if not link_url then
      reference_num = vim.fn.input("Reference Number: ")
      link_url = link_utils.get_link(reference_num)
      replacing = false
    end

    -- Still nothing, just quit
    if not link_url then return end

    local pos = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()
    local markdown_link = '[' .. reference_num .. '](' .. link_url .. ')'
    if replacing then
      vim.cmd('normal! ciW' .. markdown_link)
    else
      local nline = line:sub(0, pos) .. markdown_link .. line:sub(pos + 1)
      vim.api.nvim_set_current_line(nline)
    end
  end, { desc = 'Insert markdown link' })
end

return M
