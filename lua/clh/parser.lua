local function parseRunData(title, data)
  local class = data and data.class
  return class and title and { where = class, what = "Main", kind = title }
end

local function parseTestData(title, data)
  return data and title and { where = data[1], what = "All", kind = title }
end

local function parseTestCaseData(title, data)
  local suites = data and data.suites
  local whereWhat = suites and { suites[1].className, data.suites[1].tests[1] }
  return whereWhat and title and { where = whereWhat[1], what = whereWhat[2], kind = title }
end

local function lensDesc(lens)
  local command = lens and lens.command
  local title = command and command.title
  local data = command and command.arguments[1].data
  local runDesc = data and title == "run" and parseRunData(title, data)
  local testDesc = data and title == "test" and parseTestData(title, data)
  local testCaseDesc = data and title == "test case" and parseTestCaseData(title, data)
  return runDesc or testDesc or testCaseDesc
end

return {
  lensDesc = lensDesc,
}
