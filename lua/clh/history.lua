local lensesHistory = {}

local function key(lensDesc)
  return lensDesc.where .. ":" .. lensDesc.what .. ":" .. lensDesc.kind
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
  return keys and desc1 and vim.fn.reduce(keys, function(acc, k)
    return desc[k] == desc1[k] and acc
  end, true) or false
end

local function add(lensDesc)
  local function add1(k)
    lensDesc["time"] = os.time()
    lensesHistory[k] = lensDesc
    return lensesHistory
  end
  local k = lensDesc and key(lensDesc)
  -- return k and deleteDuplicates(lensDesc) and add1(k)
  return k and add1(k)
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
  key = key,
  add = add,
  removeByKey = removeByKey,
  take = take,
  asSortedList = asSortedList,
  equalsDesc = equalsDesc,
}
