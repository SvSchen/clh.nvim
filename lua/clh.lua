local config = require("clh.config")
local explorer = require("clh.explorer")
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

local function findLineNo(bufNo, lensDesc)
  local lenses = vim.lsp.codelens.get(bufNo)
  for _, lens in pairs(lenses) do
    local lensDesc1 = parser.lensDesc(lens)
    if history.equalsDesc(lensDesc, lensDesc1) then
      return lens.range.start.line + 1
    end
  end
end

local function codeLensEntryFromBuffer(bufNo)
  local lineNo = vim.api.nvim_win_get_cursor(0)[1]
  local lens = findLens(bufNo, lineNo)
  local lensDesc = parser.lensDesc(lens)
  return lensDesc and history.entry(bufNo, lineNo, lensDesc, vim.lsp.codelens.run)
end

local function codeLensEntryFromTestExplorer(bufNo)
  local explorerDesc = explorer.testDesc(bufNo)
  local lensDesc = explorerDesc and { where = explorerDesc.fullName, what = "All", kind = "test" }
  return explorerDesc
    and lensDesc
    and history.entry(bufNo, explorerDesc.lineNo, lensDesc, function()
      local dapOk, dap = pcall(require, "dap")
      if dapOk then
        dap.run(explorer.dapArguments(explorerDesc.suiteUri, explorerDesc.fullName, {}))
      else
        vim.notify("No dap installed!", vim.log.levels.ERROR)
      end
    end)
end

local function registerCodeLens()
  local metalsOk, conf = pcall(require, "metals.config")
  local bufNo = vim.api.nvim_get_current_buf()
  local lensEntry = nil
  if metalsOk and conf.get_config_cache() and conf.get_config_cache().settings.metals.testUserInterface == "Test Explorer" then
    lensEntry = codeLensEntryFromTestExplorer(bufNo)
  else
    lensEntry = codeLensEntryFromBuffer(bufNo)
  end
  local maxLength = config.config().history.maxLength or config.default.history.maxLength
  return lensEntry and history.add(lensEntry) and history.take(maxLength) and lensEntry.run or nil
end

local function registerAndRunCodeLens()
  local lensRun = registerCodeLens()
  if lensRun then
    lensRun()
    return true
  end
  return false
end
local function ui()
  local hasSnacksPicker, _ = pcall(require, "snacks.picker")
  local hasTelescope, telescope = pcall(require, "telescope")
  if hasSnacksPicker then
    require("clh.snacks").selectCodeLens()
  elseif hasTelescope then
    telescope.extensions.clh.selectCodeLens()
  else
    error("clh requires folke/snacks.nvim or nvim-telescope/telescope.nvim (deprecated)")
  end
end

return {
  registerCodeLens = registerCodeLens,
  registerAndRunCodeLens = registerAndRunCodeLens,
  sortedHistoryEntries = history.asSortedList,
  removeCodeLens = history.removeByKey,
  findLineNo = findLineNo,
  setup = config.setup,
  ui = ui,
}
