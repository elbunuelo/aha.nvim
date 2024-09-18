local HTTP = {}
local function get_curl_executable()
  return vim.fn.executable('curl') == 1 and 'curl' or nil
end

local curl = get_curl_executable()
if not curl then
  vim.schedule(function()
    vim.notify("Error: curl is not available", vim.log.levels.ERROR)
  end)
  return
end

function HTTP.get(config)
  local url = config.url
  local on_success = config.onSuccess
  local on_error = config.onError
  local headers = config.headers or {}

  local request_headers = {
    ['User-Agent'] = 'aha.nvim - https://github.com/elbunuelo/aha.nvim',
    ['Content-Type'] = 'application/json',
    ['Accept'] = 'application/json',
  }
  for header, value in pairs(headers) do request_headers[header] = value end

  local args = {
    '-s',
    '-X', 'GET',
  }
  for header, value in pairs(request_headers) do
    header_text = header .. ": " .. value
    table.insert(args, '-H')
    table.insert(args, header_text)
  end
  table.insert(args, url)


  require('plenary.job'):new({
    command = curl,
    args = args,
    on_exit = function(j, return_val)
      if return_val ~= 0 then
        vim.schedule(function()
          vim.notify("Error: API request failed with exit code " .. return_val, vim.log.levels.ERROR)
        end)
        on_error(j:result())
        return
      end

      local result = table.concat(j:result(), "\n")
      local ok, decoded = pcall(vim.json.decode, result)
      if not ok or not decoded then
        vim.schedule(function()
          vim.notify("Error: Failed to parse API response. Raw response:\n" .. result, vim.log.levels.ERROR)
        end)
        return
      end
      vim.schedule(function()
        on_success(decoded)
      end)
    end,
  }):start()
end

return HTTP
