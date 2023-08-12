local table = _G.table
function table.print(t)
  if _G.NO_LOGGING then
    return
  end
  local callerData = debug.getinfo(2, "n")
  print("[lua]table.print from ", callerData.name, callerData.namewhat)
  local print_cache = {}
  local function sub_print_r(t, indent)
    if print_cache[tostring(t)] then
      print(indent .. "*" .. tostring(t))
    else
      print_cache[tostring(t)] = true
      if type(t) == "table" then
        for pos, val in pairs(t) do
          if type(val) == "table" then
            print(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {")
            sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
            print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
          elseif type(val) == "string" then
            print(indent .. "[" .. pos .. "] => \"" .. val .. "\"")
          else
            print(indent .. "[" .. pos .. "] => " .. tostring(val))
          end
        end
      else
        print(indent .. tostring(t))
      end
    end
  end
  if type(t) == "table" then
    print(tostring(t) .. " {")
    sub_print_r(t, "  ")
    print("}")
  else
    sub_print_r(t, "  ")
  end
  print()
end
function table.count(t)
  local count = 0
  for k, v in pairs(t) do
    count = count + 1
  end
  return count
end
function table.index(t, element)
  for k, value in pairs(t or {}) do
    if value == element then
      return k
    end
  end
end
function table.keys(t)
  local keys = {}
  for k, v in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end
function table.values(t)
  local values = {}
  for k, v in pairs(t) do
    table.insert(values, v)
  end
  return values
end
function table.extend(t1, t2)
  for k, v in ipairs(t2) do
    table.insert(t1, v)
  end
  return t1
end
function table.equal(t1, t2)
  if t1 == t2 then
    return true
  end
  if type(t1) == "table" and type(t2) == "table" then
    if t1.GetInstanceID and t2.GetInstanceID then
      return t1:GetInstanceID() == t2:GetInstanceID()
    end
    if table.count(t1) ~= table.count(t2) then
      return false
    end
    for k, v in pairs(t1) do
      if not table.equal(v, t2[k]) then
        return false
      end
    end
    return true
  end
  return false
end
function table.copy(src, dst)
  local tableDict = {}
  local function process(src, dst)
    local value = function(o)
      if type(o) == "table" then
        if tableDict[o] then
          return {}
        end
        tableDict[o] = true
        local tbl = {}
        for k, v in pairs(o) do
          tbl[k] = process(v)
        end
        return tbl
      else
        return o
      end
    end
    if nil == src then
      printerror("table.copy src is nil")
      return dst
    end
    if dst then
      for k, v in pairs(value(src)) do
        dst[k] = v
      end
      return dst
    else
      return value(src)
    end
  end
  return process(src, dst)
end
function table.copyproto(src)
  local dst = table.copy(src)
  dst = setmetatable(dst, {
    __index = function(t, k)
      local v = rawget(t, k)
      if not v then
        return src[k]
      end
    end
  })
  return dst
end
function table.copyfullproto(src, dst)
  local tableDict = {}
  local function process(src, dst)
    local value = function(o)
      if type(o) == "table" then
        if tableDict[o] then
          return {}
        end
        tableDict[o] = true
        local tbl = {}
        local mt = getmetatable(o)
        if mt and mt.__index then
          tbl = setmetatable(tbl, {
            __index = mt.__index
          })
        end
        for k, v in pairs(o) do
          tbl[k] = process(v)
        end
        return tbl
      else
        return o
      end
    end
    if nil == src then
      printerror("table.copy src is nil")
      return dst
    end
    if dst then
      for k, v in pairs(value(src)) do
        dst[k] = v
      end
      return dst
    else
      return value(src)
    end
  end
  return process(src, dst)
end
function table.show(t, name, save, savename, log2console, maxlayer, strfix)
  local table_tostring = function(t, maxlayer, name)
    local tableDict = {}
    local layer = 0
    maxlayer = maxlayer or 999
    local cmp = function(t1, t2)
      if type(t1) == "number" and type(t1) == type(t2) then
        return t1 < t2
      end
      return tostring(t1) < tostring(t2)
    end
    local function table_r(t, name, indent, full, layer)
      local id = not full and name or type(name) ~= "number" and tostring(name) or "[" .. name .. "]"
      local tag = indent .. id .. " = "
      if string.len(tag) > 10000 then
        error("############### log long 1000")
        return table.concat(out, "\n")
      end
      local out = {}
      if type(t) == "table" and layer < maxlayer then
        if nil ~= tableDict[t] then
          table.insert(out, tag .. "{} -- " .. tableDict[t] .. " (self reference)")
        else
          tableDict[t] = full and full .. "." .. id or id
          if next(t) then
            table.insert(out, tag .. "{")
            local keys = {}
            for key, value in pairs(t) do
              table.insert(keys, key)
            end
            table.sort(keys, cmp)
            for i, key in ipairs(keys) do
              local value = t[key]
              table.insert(out, table_r(value, key, indent .. "    ", tableDict[t], layer + 1))
            end
            table.insert(out, indent .. "},")
          else
            table.insert(out, tag .. "{},")
          end
        end
      else
        local val = type(t) ~= "number" and type(t) ~= "boolean" and "\"" .. tostring(t) .. "\"" or tostring(t)
        table.insert(out, tag .. val .. ",")
      end
      return table.concat(out, "\n")
    end
    return table_r(t, name or "Error:请打印调用来源,方便他人阅读.Table", "", "", layer)
  end
  local s = table_tostring(t, maxlayer, name)
  s = string.sub(s, 1, -2)
  if save then
    local filename = savename or "debugtable.lua"
    local path = UE.UBlueprintPathsLibrary.ProjectSavedDir()
    local fullname = path .. filename
    local file = io.open(fullname, "a+")
    if file then
      print(string.format("已保存数据到指定文件: %s: %s -> %s", name, s, file))
      file:write("\n" .. s)
      file:close()
    else
      print("文件写入失败")
    end
  end
  if false ~= log2console then
    if false ~= strfix then
      print("===== 以下是 table.show 输出数据 =====\n" .. s .. "\n----- 以上是 table.show 输出数据 -----")
    else
      print(s)
    end
  end
end
function table.clone(object)
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local newObject = {}
    lookup_table[object] = newObject
    for key, value in pairs(object) do
      newObject[_copy(key)] = _copy(value)
    end
    return setmetatable(newObject, getmetatable(object))
  end
  return _copy(object)
end
function table.containsValue(t, Value)
  if nil == t then
    LogError("table.containsValue", "param talble is nil!")
    return false
  end
  for key, value in pairs(t) do
    if tostring(value) == tostring(Value) then
      return true
    end
  end
  return false
end
function table.binarySearch(t, Value, tValFunc)
  local low = 1
  local high = #t
  local mid
  while low <= high do
    mid = math.ceil((low + high) / 2)
    local tVal = tValFunc and tValFunc(t[mid]) or t[mid]
    if tVal == Value then
      return mid
    elseif Value > tVal then
      low = mid + 1
    else
      high = mid - 1
    end
  end
  return mid
end
return table
