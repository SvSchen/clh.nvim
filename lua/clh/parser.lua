local function parseRunData(title, data, run)
  local class = data and data.class
  return class and title and { where = class, what = "Main", kind = title, run = run }
end

local function parseTestData(title, data, run)
  return data and title and { where = data[1], what = "All", kind = title, run = run }
end

local function parseTestCaseData(title, data, run)
  local suites = data and data.suites
  local whereWhat = suites and { suites[1].className, data.suites[1].tests[1] }
  return whereWhat and title and { where = whereWhat[1], what = whereWhat[2], kind = title, run = run }
end

local function runLensFunction(clientId, cmd)
  return function()
    local client = cmd and clientId and vim.lsp.get_client_by_id(clientId)
    local _ = client and client:exec_cmd(cmd)
    return clientId, cmd
  end
end
local function lensDesc(clientId, lens)
  local command = lens and lens.command
  local title = command and command.title
  local data = command and command.arguments and command.arguments[1].data
  local runDesc = data and title == "run" and parseRunData(title, data, runLensFunction(clientId, command))
  local testDesc = data and title == "test" and parseTestData(title, data, runLensFunction(clientId, command))
  local testCaseDesc = data and title == "test case" and parseTestCaseData(title, data, runLensFunction(clientId, command))
  return runDesc or testDesc or testCaseDesc
end

return {
  lensDesc = lensDesc,
}
