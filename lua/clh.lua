local config = require("clh.config")
local explorer = require("clh.explorer")
local history = require("clh.history")
local parser = require("clh.parser")
local snacks = require("clh.snacks")

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
          error("No dap installed!")
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

local function dapReplWindow()
  local snacksWinOk, _ = pcall(require, "snacks.win")
  local dapReplOk, _ = require("dap.repl")
  if snacksWinOk and dapReplOk then
    snacks.dapReplWindow()
  else
    error("clh requires folke/snacks.nvim and mfussenegger/nvim-dap")
  end
end
local function ui()
  local hasSnacksPicker, _ = pcall(require, "snacks.picker")
  local hasTelescope, telescope = pcall(require, "telescope")
  if hasSnacksPicker then
    snacks.selectCodeLens()
  elseif hasTelescope then
    telescope.extensions.clh.selectCodeLens()
  else
    error("clh requires folke/snacks.nvim or nvim-telescope/telescope.nvim (deprecated)")
  end
end
local function runCodeLensPicker()
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

local function registerAndRunCodeLens(item)
  local lens = item and item.lens
  local client = item and item.client
  local _ = lens and client and registerCodeLens(client.id, lens) or error("expected snacks lens item")
  local cmd = lens and item.lens.command
  local _ = cmd and client and client:exec_cmd(cmd)
end

return {
  runCodeLensPicker = runCodeLensPicker,
  registerCodeLens = registerCodeLens,
  registerAndRunCodeLens = registerAndRunCodeLens,
  historyEntries = history.asSortedList,
  removeCodeLens = history.removeByKey,
  setup = config.setup,
  ui = ui,
  dapReplWindow = dapReplWindow,
}
