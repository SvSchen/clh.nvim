local config = require("clh.config")
local explorer = require("clh.explorer")
local history = require("clh.history")
local parser = require("clh.parser")

local function codeLensEntryFromTestExplorer(bufNo)
  local explorerDesc = explorer.testDesc(bufNo)
  return explorerDesc
    and {
      where = explorerDesc.fullName,
      what = "All",
      kind = "test",
      run = function()
        local dapOk, dap = pcall(require, "dap")
        if dapOk then
          dap.run(explorer.dapArguments(explorerDesc.suiteUri, explorerDesc.fullName, {}))
        else
          vim.notify("No dap installed!", vim.log.levels.ERROR)
        end
      end,
    }
end

local function registerCodeLens(clientId, lens)
  local lensDesc = nil
  if lens then
    lensDesc = parser.lensDesc(clientId, lens)
  else
    local metalsOk, conf = pcall(require, "metals.config")
    local bufNo = vim.api.nvim_get_current_buf()
    lensDesc = metalsOk
      and conf.get_config_cache()
      and conf.get_config_cache().settings.metals.testUserInterface == "Test Explorer"
      and codeLensEntryFromTestExplorer(bufNo)
  end
  local maxLength = config.config().history.maxLength or config.default.history.maxLength
  return lensDesc and history.add(lensDesc) and history.take(maxLength) or nil
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
local function runCodeLens()
  local lineNo = vim.api.nvim_win_get_cursor(0)[1] - 1
  local lenses = vim.lsp.codelens.get(0)
  local lensLines = vim.tbl_map(function(lens)
    return lens.range.start.line
  end, lenses)
  if vim.tbl_contains(lensLines, lineNo) then
    vim.lsp.codelens.run()
    return true
  end
  return false
end

return {
  runCodeLens = runCodeLens,
  registerCodeLens = registerCodeLens,
  historyEntries = history.asSortedList,
  removeCodeLens = history.removeByKey,
  setup = config.setup,
  ui = ui,
}
