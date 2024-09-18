local Pandoc = {}

local function get_pandoc_executable()
  return vim.fn.executable('pandoc') == 1 and 'pandoc' or nil
end

local pandoc = get_pandoc_executable()
if not pandoc then
  vim.schedule(function()
    vim.notify("Error: pandoc is not available", vim.log.levels.ERROR)
  end)
  return
end

function Pandoc.html_to_rst(html, on_success)
  file = io.open("/tmp/pandoc_to_html", "w")
  file:write(html)
  file:close()
  local args = {
    '-f', 'html',
    '-t', 'rst',
    '/tmp/pandoc_to_html'
  }

  require('plenary.job'):new({
    command = pandoc,
    args = args,
    on_exit = function(j, return_val)
      if return_val ~= 0 then
        vim.schedule(function()
          vim.notify("Error: Pandoc conversion failed with exit code " .. return_val, vim.log.levels.ERROR)
        end)
        on_error(j:result())
        return
      end

      local result = table.concat(j:result(), "\n")
      -- local ok, decoded = pcall(vim.json.decode, result)
      -- if not ok or not decoded then
      --   vim.schedule(function()
      --     vim.notify("Error: Failed to parse API response. Raw response:\n" .. result, vim.log.levels.ERROR)
      --   end)
      --   return
      -- end
      vim.schedule(function()
        on_success(result)
      end)
    end,
  }):start()
end

return Pandoc
