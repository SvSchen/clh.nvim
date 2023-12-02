local parseDesc = require("clh.parser").parseDesc
local config = require("clh.config")
local history = require("clh.history")

local function codeLensAt(bufNo, lineNo)
  local lenses = vim.lsp.codelens.get(bufNo)
  for _, lens in pairs(lenses) do
    if lens.range.start.line == lineNo - 1 then
      return lens
    end
  end
end

local function registerCodeLens()
  local lineNo = vim.api.nvim_win_get_cursor(0)[1]
  local bufNo = vim.api.nvim_get_current_buf()
  local lens = codeLensAt(bufNo, lineNo)
  local lensDesc = parseDesc(lens)
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
  setup = config.setup,
}
