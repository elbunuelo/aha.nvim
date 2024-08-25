local M = {}

local record_patterns = {
  features = '^%a+-%d+$',
  requirements = '^%a+-%d+-%d+$',
  epics = '^%a+-E%-%d+$',
  releases = '^%a+-R%-%d+$',
  ideas = '^%a+-I%-%d+$',
  initiatives = '^%a+-S%-%d+$',
  goals = '^%a+-G%-%d+$',
  pages = '^%a+-N%-%d+$',
}

local AHA_BASE_URL = os.getenv('AHA_BASE_URL')
M.AHA_BASE_URL = AHA_BASE_URL

function record_type(reference_num)
  for type, pattern in pairs(record_patterns) do
    if string.match(reference_num, pattern) then
      return type
    end
  end

  return nil
end

function M.get_link(reference_num)
  local type = record_type(reference_num)

  if not type then
    print('Could not find record type for ' .. reference_num)
    return
  end

  return table.concat({ AHA_BASE_URL, type, reference_num }, '/')
end

return M
