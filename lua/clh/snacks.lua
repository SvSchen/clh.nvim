local function dapReplWindow()
  local function findReplBn()
    local dapReplBufs = vim.tbl_filter(function(bn)
      return vim.bo[bn].filetype == "dap-repl"
    end, vim.api.nvim_list_bufs())
    return dapReplBufs[1]
  end
  local function show(bn)
    if bn then
      vim.bo[bn].syntax = "scala"
    end
    -- require("snacks").terminal.colorize(bn)
    -- local _ = bn and require("baleia").setup({}).automatically(bn)
    return (
      bn
      and require("snacks").win({
        buf = bn,
        border = vim.o.winborder,
        title = "dap-repl(" .. bn .. ")",
        keys = {
          ["<Esc>"] = function(self)
            self:close()
          end,
        },
        on_win = function(self)
          self:on("WinLeave", function()
            self:close()
          end, { buf = true })
        end,
      })
      and true
    ) or false
  end
  local function openRepl()
    local repl = require("dap.repl")
    repl.toggle()
    repl.toggle()
    return true
  end
  return show(findReplBn()) or (openRepl() and show(findReplBn())) or vim.notify("no repl found")
end

local function selectCodeLens()
  return require("snacks.picker").pick({
    source = "codeLensesHistory",
    title = "Code Lenses History",
    confirm = "runCodeLens",
    actions = {
      runCodeLens = function(picker, item)
        picker:close()
        item.run()
        item["time"] = os.time()
        dapReplWindow()
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
  dapReplWindow = dapReplWindow,
}
