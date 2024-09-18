require('aha').setup()


local http = require 'aha.http'
local pandoc = require 'aha.pandoc'
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local show_window = function(options)
  local popup = Popup({
    enter = true,
    focusable = false,
    relative = "editor",
    border = {
      padding = {
        top = 2,
        bottom = 2,
        left = 3,
        right = 3,
      },
      style = "rounded",
      text = {
        top = options.title,
        top_align = "center",
        bottom = options.reference,
        bottom_align = "right",
      },
    },
    position = "50%",
    size = {
      width = "80",
      height = "60%",
    },
  })

  -- mount/open the component
  popup:mount()

  -- unmount component when cursor leaves buffer
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  lines = {}
  for s in options.body:gmatch("[^\r\n]+") do
    if (s ~= ".. container:: table-wrapper") then
      table.insert(lines, s)
    end
  end

  -- set content
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, lines)
  vim.api.nvim_buf_set_option(popup.bufnr, 'modifiable', false)
end

local fetch = function()
  http.get({
    url = 'https://big.aha.io/api/v1/features/CREATE-1957',
    onSuccess = function(response)
      local body_html = response['feature']['description']['body']
      local title = response['feature']['name']
      local reference = response['feature']['reference_num']
      local callback = function(body)
        show_window({ title = title, body = body, reference = reference })
      end

      pandoc.html_to_rst(body_html, callback)
    end,
    onError = function(error)
      print('Error!')
    end,
    headers = {
      ['Authorization'] = 'Bearer ' .. os.getenv("AHA_API_KEY"),
      ['User-Agent'] = 'aha.nvim nariasgonzalez@aha.io '
    }
  })
end

vim.keymap.set('n', '<leader>!f', fetch, { noremap = true, silent = false })
