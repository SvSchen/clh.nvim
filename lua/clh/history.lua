local lensesHistory = {}

local function meta(bufNo, lineNo)
  return {
    lineNo = lineNo,
    bufNo = bufNo,
    time = os.time(),
  }
end

local function entry(bufNo, lineNo, desc)
  local function entry1()
    local m = meta(bufNo, lineNo)
    m["desc"] = desc
    return m
  end
  return desc and entry1()
end

local function key(historyEntry)
  return historyEntry.bufNo .. ":" .. historyEntry.lineNo
end

local function add(historyEntry)
  local function add1(k)
    lensesHistory[k] = historyEntry
    return lensesHistory
  end
  local k = historyEntry and key(historyEntry)
  return k and add1(k)
end

local function remove(historyEntry)
  local function remove1(k)
    lensesHistory[k] = nil
    return lensesHistory
  end
  local k = historyEntry and key(historyEntry)
  return k and remove1(k)
end

local function length()
  return vim.tbl_count(lensesHistory)
end

local function asList()
  return vim.tbl_values(lensesHistory)
end

local function asSortedList()
  local l = asList()
  table.sort(l, function(a, b)
    return a.time > b.time
  end)
  return l
end

local function take(count)
  local function take1()
    local l = asSortedList()
    for _, k in pairs(vim.tbl_map(key, vim.list_slice(l, count + 1))) do
      lensesHistory[k] = nil
    end
    return lensesHistory
  end
  return count and length() > count and take1() or lensesHistory
end

return {
  entry = entry,
  key = key,
  add = add,
  remove = remove,
  take = take,
  asSortedList = asSortedList,
}
