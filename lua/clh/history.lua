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

local function removeByKey(k)
  local function remove1()
    lensesHistory[k] = nil
    return lensesHistory
  end
  return k and remove1()
end

local function equalsDesc(desc, desc1)
  local keys = desc and vim.tbl_keys(desc)
  return keys
      and desc1
      and vim.fn.reduce(keys, function(acc, k)
        return desc[k] == desc1[k] and acc
      end, true)
      or false
end

local function findDuplicates(historyEntry)
  local function dupDesc(lensesHistoryEntry)
    return equalsDesc(historyEntry.desc, lensesHistoryEntry.desc)
  end
  return historyEntry and vim.tbl_filter(dupDesc, lensesHistory)
end

local function deleteDuplicates(historyEntry)
  for _, e in pairs(findDuplicates(historyEntry)) do
    -- bug in vim.tbl_filter does not return the key correct
    removeByKey(key(e))
  end
  return lensesHistory
end

local function add(historyEntry)
  local function add1(k)
    lensesHistory[k] = historyEntry
    return lensesHistory
  end
  local k = historyEntry and key(historyEntry)
  return k and deleteDuplicates(historyEntry) and add1(k)
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
  removeByKey = removeByKey,
  take = take,
  asSortedList = asSortedList,
  equalsDesc = equalsDesc,
}
