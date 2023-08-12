local SettingConfigSolveMap = {}
function SettingConfigSolveMap.moveDistance(content)
  return tonumber(content)
end
function SettingConfigSolveMap.scaleRange(content)
  local tempTbl = string.split(content, ",")
  local retTbl = {
    max = tonumber(tempTbl[1]) * 100,
    min = tonumber(tempTbl[2]) * 100,
    step = tonumber(tempTbl[3]) * 100,
    default = tonumber(tempTbl[4]) * 100
  }
  return retTbl
end
function SettingConfigSolveMap.opacityRange(content)
  local tempTbl = string.split(content, ",")
  local retTbl = {
    max = tonumber(tempTbl[1]) * 100,
    min = tonumber(tempTbl[2]) * 100,
    step = tonumber(tempTbl[3]) * 100,
    default = tonumber(tempTbl[4]) * 100
  }
  return retTbl
end
function SettingConfigSolveMap.runLengthRange(content)
  local tempTbl = string.split(content, ",")
  local retTbl = {
    min = tonumber(tempTbl[1]),
    max = tonumber(tempTbl[2])
  }
  return retTbl
end
return SettingConfigSolveMap
