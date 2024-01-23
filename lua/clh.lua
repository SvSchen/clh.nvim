local config = require("clh.config")
local history = require("clh.history")
local parser = require("clh.parser")

local function findLens(bufNo, lineNo)
  local lenses = vim.lsp.codelens.get(bufNo)
  for _, lens in pairs(lenses) do
    if lens.range.start.line == lineNo - 1 then
      return lens
    end
  end
end

local function equals(lensDesc, lensDesc1)
  local keys = lensDesc and vim.tbl_keys(lensDesc)
  return keys
      and lensDesc1
      and vim.fn.reduce(keys, function(acc, k)
        return lensDesc[k] == lensDesc1[k] and acc
      end, true)
    or false
end

local function findLineNo(bufNo, lensDesc)
  local lenses = vim.lsp.codelens.get(bufNo)
  for _, lens in pairs(lenses) do
    local lensDesc1 = parser.lensDesc(lens)
    if equals(lensDesc, lensDesc1) then
      return lens.range.start.line + 1
    end
  end
end

local function registerCodeLens()
  local lineNo = vim.api.nvim_win_get_cursor(0)[1]
  local bufNo = vim.api.nvim_get_current_buf()
  local lens = findLens(bufNo, lineNo)
  local lensDesc = parser.lensDesc(lens)
  local lensEntry = history.entry(bufNo, lineNo, lensDesc)
  local maxLength = config.config().history.maxLength or config.default.history.maxLength
  return history.add(lensEntry) and history.take(maxLength) and true or false
end

local function registerAndRunCodeLens()
  local registered = registerCodeLens()
  vim.lsp.codelens.run()
  return registered
end

return {
  registerCodeLens = registerCodeLens,
  registerAndRunCodeLens = registerAndRunCodeLens,
  sortedHistoryEntries = history.asSortedList,
  removeCodeLens = history.removeByKey,
  findLineNo = findLineNo,
  setup = config.setup,
}
