local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("clh requires nvim-telescope/telescope.nvim")
end

local clh = require("clh")
local config = require("clh.config")
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")

local function runCodelens(...)
  local entry = require("telescope.actions.state").get_selected_entry()
  require("telescope.actions").close(...)
  local bufNo = entry.bufNo
  local lineNo = clh.findLineNo(bufNo, entry.value)
  local winid = vim.api.nvim_open_win(bufNo, true, { relative = "win", row = 3, col = 3, width = 12, height = 3 })
  local _ = lineNo and vim.cmd("norm! " .. lineNo .. "G")
  clh.removeCodeLens(entry.value.key)
  clh.registerAndRunCodeLens()
  vim.api.nvim_win_close(winid, true)
end

local function displayEntry(historyEntry)
  return {
    kind = historyEntry.desc.kind,
    where = historyEntry.desc.where,
    what = historyEntry.desc.what,
  }
end

local function lensesHistoryEntryMaker(maxEntryColumnLength)
  local function makeDisplay(entry)
    local displayer = entry_display.create({
      separator = " : ",
      items = {
        { width = maxEntryColumnLength[1] },
        { width = maxEntryColumnLength[2] },
        { width = maxEntryColumnLength[3] },
        { remaining = true },
      },
    })
    return displayer({
      { entry.value.kind, "LspKindKeyword" },
      { entry.value.where, "Type" },
      { entry.value.what, "String" },
      { entry.key, "Number" },
    })
  end
  return function(entry)
    local dEntry = displayEntry(entry)
    return {
      ordinal = dEntry.where,
      value = dEntry,
      display = makeDisplay,
      bufNo = entry.bufNo,
      key = require("clh.history").key(entry),
    }
  end
end

local function maxDisplayEntryColumnLength(displayEntryLengths)
  local max = { 0, 0, 0 }
  local function updateMax(i, v)
    if max[i] < v then
      max[i] = v
    end
  end

  for _, row in pairs(displayEntryLengths) do
    updateMax(1, row.kind)
    updateMax(2, row.where)
    updateMax(3, row.what)
  end
  return max
end

local function displayEntryLength(dEntry)
  return vim.tbl_map(function(v)
    return v:len()
  end, dEntry)
end

local function selectCodeLens()
  local sortedDisplayEntries = vim.tbl_map(displayEntry, clh.sortedHistoryEntries())
  pickers
    .new({}, {
      prompt_title = "Code Lenses History",
      layout_strategy = "center",
      layout_config = {
        width = function(_, max_columns, _)
          local confWidth = config.config().ui.width or config.default.ui.width
          return math.floor(max_columns * math.min(confWidth, 1))
        end,
        height = function(_, _, max_lines)
          local confHeight = config.config().ui.height or config.default.ui.height
          return math.floor(max_lines * math.min(confHeight, 1))
        end,
      },
      finder = finders.new_table({
        results = clh.sortedHistoryEntries(),
        entry_maker = lensesHistoryEntryMaker(maxDisplayEntryColumnLength(vim.tbl_map(displayEntryLength, sortedDisplayEntries))),
      }),
      attach_mappings = function(_, map)
        map("i", "<CR>", runCodelens)
        map("n", "<CR>", runCodelens)
        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  exports = {
    selectCodeLens = selectCodeLens,
  },
})
