local function selectCodeLens()
  return require("snacks.picker").pick({
    source = "codeLensesHistory",
    title = "Code Lenses History",
    confirm = "runCodeLens",
    actions = {
      runCodeLens = function(picker, item)
        picker:close()
        local clh = require("clh")
        local bufNo = item.bufNo
        local lineNo = clh.findLineNo(bufNo, item.desc)
        local winid = vim.api.nvim_open_win(bufNo, true, { relative = "editor", row = 3, col = 3, width = 12, height = 3 })
        local _ = lineNo and vim.cmd("norm! " .. lineNo .. "G")
        clh.registerAndRunCodeLens()
        vim.api.nvim_win_close(winid, true)
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
    items = require("clh").sortedHistoryEntries(),
    format = function(item, picker)
      local ret = {}
      ret[#ret + 1] = { item.desc.kind, "LspKindKeyWord" }
      ret[#ret + 1] = { " " }
      ret[#ret + 1] = { item.desc.where, "Type" }
      ret[#ret + 1] = { " " }
      ret[#ret + 1] = { item.desc.what, "String" }
      ret[#ret + 1] = { " " }
      ret[#ret + 1] = { require("clh.history").key(item), "Number" }
      ret[#ret + 1] = { " " }
      ret[#ret + 1] = { vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item.bufNo), ":t"), "Text" }
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
