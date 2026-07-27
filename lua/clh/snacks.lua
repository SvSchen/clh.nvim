local function selectCodeLens()
  return require("snacks.picker").pick({
    source = "codeLensesHistory",
    title = "Code Lenses History",
    confirm = "runCodeLens",
    actions = {
      runCodeLens = function(picker, item)
        picker:close()
        item.run()
      end,
      openCodeLens = function(picker, item)
        picker:close()
        vim.api.nvim_set_current_buf(item.bufNo)
      end,
    },
    win = {
      input = {
        keys = {
          ["<M-CR>"] = { "openCodeLens", mode = { "n", "i" } },
        },
      },
    },
    items = require("clh").historyEntries(),
    format = function(item, picker)
      local ret = {}
      ret[#ret + 1] = { item.kind, "LspKindKeyWord" }
      ret[#ret + 1] = { " " }
      ret[#ret + 1] = { item.what, "String" }
      ret[#ret + 1] = { " " }
      ret[#ret + 1] = { item.where, "Type" }
      return ret
    end,
    hunk_header = false,
    layout = {
      preview = false,
    },
  })
end

return {
  selectCodeLens = selectCodeLens,
}
