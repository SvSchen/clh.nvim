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
  local lineNo = clh.currentLineNo(entry.value)
  local bufNo = entry.value.bufNo
  local winid = vim.api.nvim_open_win(bufNo, true, { relative = "win", row = 3, col = 3, width = 12, height = 3 })
  local _ = lineNo and vim.cmd("norm! " .. lineNo .. "G")
  clh.removeCodeLens(entry.value)
  clh.registerAndRunCodeLens()
  vim.api.nvim_win_close(winid, true)
end

local function lensesHistoryEntryMaker()
  local function makeDisplay(entry)
    local displayer = entry_display.create({
      separator = " : ",
      items = {
        { remaining = true },
        { remaining = true },
        { remaining = true },
        { remaining = true },
      },
    })
    return displayer({
      { entry.tag, "Number" },
      { entry.value.desc.kind, "LspKindKeyword" },
      { entry.value.desc.where, "Type" },
      { entry.value.desc.what, "String" },
    })
  end
  return function(entry)
    return {
      tag = entry.bufNo .. ":" .. entry.lineNo,
      ordinal = entry.desc.where,
      value = entry,
      display = makeDisplay,
    }
  end
end

local function selectCodeLens()
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
        entry_maker = lensesHistoryEntryMaker(),
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
