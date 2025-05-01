local function testDesc(bufNo)
  local uri = vim.uri_from_bufnr(bufNo)
  local testExplorer = require("metals.test_explorer")
  local ret = nil
  for _, suite in pairs(testExplorer.state) do
    for _, test in pairs(suite.suites) do
      if test.location.uri == uri then
        ret = {
          suiteUri = suite.uri,
          suiteName = test.targetName,
          fullName = test.fullyQualifiedClassName,
          name = test.className,
          uri = test.location.uri,
          lineNo = test.location.range.start.line,
        }
      end
    end
  end
  return ret
end

local function dapArguments(targetUri, className, tests)
  return {
    type = "scala",
    request = "launch",
    name = "Run Test",
    metals = {
      target = { uri = targetUri },
      requestData = {
        suites = {
          {
            className = className,
            tests = tests,
          },
        },
        jvmOptions = {},
        environmentVariables = {},
      },
    },
  }
end

return {
  testDesc = testDesc,
  dapArguments = dapArguments,
}
