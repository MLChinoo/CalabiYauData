local string = _G.string
function string.safesplit(splitstr, sep)
  splitstr = tostring(splitstr)
  sep = tostring(sep)
  if "" == sep then
    return false
  end
  local pos, arr = 0, {}
  for st, sp in function()
    return string.find(splitstr, sep, pos, true)
  end, nil, nil, nil do
    table.insert(arr, string.sub(splitstr, pos, st - 1))
    pos = sp + 1
  end
  table.insert(arr, string.sub(splitstr, pos))
  return arr
end
function string.split(splitstr, sep)
  if splitstr and #splitstr > 0 then
    local b, ret = pcall(string.safesplit, splitstr, sep)
    if b then
      return ret
    else
      printerror("splitstr:", splitstr, "| sep:", sep, "| errmsg:", ret)
      return {}
    end
  end
  return {}
end
function string.splitSecondary(splitstr, first, secondary)
  if splitstr and #splitstr > 0 then
    local b, retOne = pcall(string.safesplit, splitstr, first)
    local res = {}
    if b then
      for _, strOne in ipairs(retOne) do
        local c, retTwo = pcall(string.safesplit, strOne, secondary)
        for _, strTwo in ipairs(retTwo) do
          table.insert(res, strTwo)
        end
        if 0 == #retTwo then
          table.insert(res, retOne)
        end
      end
      return res
    else
      printerror("splitstr:", splitstr, "| sep:", first, "| errmsg:", retOne)
      return {}
    end
  end
  return {}
end
string.oriformat = string.format
function string.format(s, ...)
  local list = {}
  local len = select("#", ...)
  for i = 1, len do
    local v = select(i, ...)
    if nil == v or type(v) == "boolean" then
      table.insert(list, tostring(v))
    else
      table.insert(list, v)
    end
  end
  return string.oriformat(s, table.unpack(list))
end
function string.startswith(s, starts)
  if #starts > #s then
    return false
  end
  for i = 1, #starts do
    if string.byte(s, i) ~= string.byte(starts, i) then
      return false
    end
  end
  return true
end
function string.endswith(s, ends)
  local lenS = #s
  local lenEnds = #ends
  if lenS < lenEnds then
    return false
  end
  local offset = lenS - lenEnds
  for i = 1, lenEnds do
    if string.byte(s, offset + i) ~= string.byte(ends, i) then
      return false
    end
  end
  return true
end
function string.replace(s, pat, repl, n)
  local list = {
    "(",
    ")",
    ".",
    "+",
    "-",
    "*",
    "?",
    "[",
    "^",
    "$"
  }
  for k, v in ipairs(list) do
    pat = string.gsub(pat, "%" .. v, "%%" .. v)
  end
  return string.gsub(s, pat, repl, n)
end
function string.eval(s, t)
  local f = loadstring(string.format("do return %s end", s))
  setfenv(f, t)
  return f()
end
function string.gettitle(str, size, sPattern)
  local sPattern = sPattern or "……"
  local t = string.getutftable(str)
  local result = {}
  local cnt = 0
  for k, v in pairs(t) do
    if string.byte(v) > 192 then
      cnt = cnt + 2
    else
      cnt = cnt + 1
    end
    if size >= cnt then
      table.insert(result, v)
    else
      table.insert(result, sPattern)
      break
    end
  end
  return table.concat(result, "")
end
function string.GetRandomString(iLen, onlynum)
  local random = function(n, m)
    math.randomseed(os.clock() * math.random(1000000, 90000000) + math.random(1000000, 90000000))
    return math.random(n, m)
  end
  local randomString = function(len)
    local bc = "QWERTYUIOPASDFGHJKLZXCVBNM"
    local sc = "qwertyuiopasdfghjklzxcvbnm"
    local no = "0123456789"
    local tmplete = onlynum and no or no .. sc .. bc
    local maxLen = #tmplete
    local srt = {}
    for i = 1, len do
      local index = random(1, maxLen)
      srt[i] = string.sub(tmplete, index, index)
    end
    return table.concat(srt, "")
  end
  return randomString(iLen)
end
function string.WildcardReplace(infoStr, id, func, wildcard)
  wildcard = wildcard or "A%d+A"
  if nil == id and nil == func then
    LogDebug("[string]", string.format("//Error: 通配符函数传入的参数有误 id = %s , func = %s ", id, func))
    return "null"
  end
  if nil ~= id and nil == func then
    function func(word)
      return CConfigUtils.GetLevelValueById(id, word)
    end
  end
  local replaceTable = {}
  for word in string.gmatch(infoStr, wildcard) do
    replaceTable[#replaceTable + 1] = {
      word,
      func(word)
    }
  end
  for _, T in ipairs(replaceTable) do
    if nil == T[2] then
      LogDebug("[string]", string.format("//Error: 找不到对应通配符的值 -->> %s (%s) id = %d ", infoStr, T[1], id))
      return "null"
    end
    infoStr = string.gsub(infoStr, T[1], T[2])
  end
  return infoStr
end
function string.StringWrapSplit(OriginalStr, color)
  local strColor = ""
  local firstLine = true
  local tempStr = ""
  local strSplit = string.split(OriginalStr, "\n")
  if table.count(strSplit) > 1 then
    for _, str in ipairs(strSplit) do
      if firstLine then
        if color then
          tempStr = string.format("<span color=\"#%s\">%s</>", color, str)
        else
          tempStr = string.format("%s", str)
        end
        firstLine = false
      elseif color then
        tempStr = string.format([[

<span color="#%s">%s</>]], color, str)
      else
        tempStr = string.format([[

%s]], str)
      end
      strColor = strColor .. tempStr
    end
  elseif 1 == table.count(strSplit) then
    if color then
      strColor = string.format("<span color=\"#%s\">%s</>", color, OriginalStr)
    else
      strColor = string.format("%s", OriginalStr)
    end
  end
  return strColor
end
function string.RemoveParenthesis(OriginalStr)
  OriginalStr = string.gsub(OriginalStr, "%[%[", "<")
  OriginalStr = string.gsub(OriginalStr, "%]%]", ">")
  OriginalStr = string.gsub(OriginalStr, "<.->", "")
  return OriginalStr
end
function string.CovertBytesToString(t)
  local bytearr = {}
  for k, v in pairs(t) do
    local utf8byte = v < 0 and 255 + v + 1 or v
    local cc = string.char(utf8byte)
    table.insert(bytearr, cc)
  end
  return tostring(table.concat(bytearr))
end
function string.ByteToMB(num)
  local d = 1048576.0
  local l = num * 100
  if d > l then
    return 0.01
  end
  local mb = num / d
  return mb - mb % 0.01
end
function string.trim(url)
  return string.gsub(url, "%s+", "")
end
return string
