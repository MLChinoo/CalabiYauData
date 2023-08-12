local FunctionUtil = {}
local SECONDSFORDAY, SECONDSFORHOUR, SECONDSFORMINUTE = 86400, 3600, 60
local DaysText, DaysHoursText, HoursText, HoursMinutesText, HoursMinutesSecondsText, MinutesText, SecondsText
function FunctionUtil:FormatTime(UnixTimestamp)
  local TempDays = math.modf(UnixTimestamp / SECONDSFORDAY)
  local TempHours = math.modf(UnixTimestamp / SECONDSFORHOUR)
  local TempMinutes = math.modf(UnixTimestamp / SECONDSFORMINUTE)
  local TempHour = math.modf(UnixTimestamp / SECONDSFORHOUR) - TempDays * 24
  local TempMinute = math.modf(UnixTimestamp / SECONDSFORMINUTE) - TempHours * 60
  local TempSecond = math.modf((UnixTimestamp - TempMinutes * 60) / 1)
  TempDays = TempDays < 0 and 0 or TempDays
  TempHours = TempHours < 0 and 0 or TempHours
  TempMinutes = TempMinutes < 0 and 0 or TempMinutes
  TempHour = TempHour < 0 and 0 or TempHour
  TempMinute = TempMinute < 0 and 0 or TempMinute
  TempSecond = TempSecond < 0 and 0 or TempSecond
  DaysText = DaysText or ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_DaysHours")
  HoursText = HoursText or ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Hours")
  MinutesText = MinutesText or ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Minutes")
  SecondsText = SecondsText or ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Seconds")
  DaysHoursText = DaysHoursText or ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_DaysHours1")
  HoursMinutesText = HoursMinutesText or ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Hours1")
  HoursMinutesSecondsText = HoursMinutesSecondsText or ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Hours2")
  local InPMGameUtil_Format_Days = ObjectUtil:GetTextFromFormat(DaysText, {Days = TempDays})
  local InPMGameUtil_Format_DaysHours = ObjectUtil:GetTextFromFormat(DaysHoursText, {Days = TempDays, Hours = TempHour})
  local InPMGameUtil_Format_Hours = ObjectUtil:GetTextFromFormat(HoursText, {Hours = TempHour})
  local InPMGameUtil_Format_HoursMinutes = ObjectUtil:GetTextFromFormat(HoursMinutesText, {Hours = TempHour, Minutes = TempMinute})
  local InPMGameUtil_Format_HoursMinutesSeconds = ObjectUtil:GetTextFromFormat(HoursMinutesSecondsText, {
    Hours = TempHour,
    Minutes = TempMinute,
    Seconds = TempSecond
  })
  local InPMGameUtil_Format_Minutes = ObjectUtil:GetTextFromFormat(MinutesText, {Minutes = TempMinutes})
  local InPMGameUtil_Format_Seconds = ObjectUtil:GetTextFromFormat(SecondsText, {Seconds = TempSecond})
  local InPMGameUtil_Format_ExpectUnit = 0
  if TempDays > 0 then
    InPMGameUtil_Format_ExpectUnit = InPMGameUtil_Format_Days
  elseif TempHours >= 1 and TempHours < 24 then
    InPMGameUtil_Format_ExpectUnit = InPMGameUtil_Format_Hours
  elseif TempMinutes >= 1 and TempMinutes < 60 then
    InPMGameUtil_Format_ExpectUnit = InPMGameUtil_Format_Minutes
  elseif TempMinutes < 1 then
    InPMGameUtil_Format_ExpectUnit = InPMGameUtil_Format_Seconds
  end
  return {
    Day = TempDays,
    Hour = TempHour,
    Hours = TempHours,
    Minute = TempMinute,
    Second = TempSecond,
    PMGameUtil_Format_Days = InPMGameUtil_Format_Days,
    PMGameUtil_Format_DaysHours = InPMGameUtil_Format_DaysHours,
    PMGameUtil_Format_Hours = InPMGameUtil_Format_Hours,
    PMGameUtil_Format_HoursMinutes = InPMGameUtil_Format_HoursMinutes,
    PMGameUtil_Format_HoursMinutesSeconds = InPMGameUtil_Format_HoursMinutesSeconds,
    PMGameUtil_Format_ExpectUnit = InPMGameUtil_Format_ExpectUnit
  }
end
local TimeSpan
function FunctionUtil:getTimeZoneOffset()
  local nowLocalStamp = os.time()
  local offsetTime = nowLocalStamp - os.time(os.date("!*t", nowLocalStamp))
  return offsetTime
end
function FunctionUtil:getByteCount(str)
  if not str then
    return 0
  end
  local realByteCount = #str
  local length = 0
  local curBytePos = 1
  while true do
    local step = 1
    local byteVal = string.byte(str, curBytePos)
    byteVal = byteVal or 1
    if byteVal > 239 then
      step = 4
    elseif byteVal > 223 then
      step = 3
    elseif byteVal > 191 then
      step = 2
    else
      step = 1
    end
    curBytePos = curBytePos + step
    length = length + 1
    if realByteCount < curBytePos then
      break
    end
  end
  return length
end
function FunctionUtil:getSubStringByCount(str, startIndex, endIndex)
  if not str then
    return ""
  end
  local realByteCount = #str
  if endIndex >= realByteCount then
    return str
  end
  local length = 0
  local curBytePos = 1
  local newStr = ""
  while true do
    local step = 1
    local byteVal = string.byte(str, curBytePos)
    if byteVal > 239 then
      step = 4
    elseif byteVal > 223 then
      step = 3
    elseif byteVal > 191 then
      step = 2
    else
      step = 1
    end
    curBytePos = curBytePos + step
    length = length + 1
    if length == startIndex then
      startIndex = curBytePos - step
    end
    if length == endIndex then
      newStr = string.sub(str, startIndex, curBytePos - 1)
      break
    end
    if realByteCount < curBytePos then
      break
    end
  end
  return newStr
end
function FunctionUtil:Split(str, reps)
  local resultStrList = {}
  string.gsub(str, "[^" .. reps .. "]+", function(w)
    table.insert(resultStrList, w)
  end)
  return resultStrList
end
function FunctionUtil:urlEncode(s)
  s = string.gsub(s, "([^%w%.%- ])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  return string.gsub(s, " ", "+")
end
function FunctionUtil:urlDecode(s)
  s = string.gsub(s, "%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end)
  return s
end
function FunctionUtil:have_illegal_char(nick)
  local k = 1
  while not (k > #nick) do
    local c = string.byte(nick, k)
    if not c then
      break
    end
    local is_ascii = c >= 0 and c <= 127
    local is_number = c >= 48 and c <= 57
    local is_letter = c >= 65 and c <= 90 or c >= 97 and c <= 122
    local is_allow = 45 == c
    if is_ascii and not is_number and not is_letter and not is_allow then
      return true
    end
    k = k + 1
  end
  return false
end
function FunctionUtil:randomTable(_table, _num)
  local _result = {}
  local _index = 1
  local _num = _num or #_table
  while 0 ~= #_table do
    local ran = math.random(1, #_table)
    if nil ~= _table[ran] then
      _result[_index] = _table[ran]
      table.remove(_table, ran)
      _index = _index + 1
      if _num < _index then
        break
      end
    end
  end
  return _result
end
function FunctionUtil:RemoveByValue(_table, value)
  for k, v in pairs(_table) do
    if v == value then
      table.remove(_table, k)
      return true
    end
  end
  return false
end
return FunctionUtil
