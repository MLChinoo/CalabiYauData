local ObjectUtil = {}
local UObjectClass = UE4.UClass.Load("/Script/PMGame.PMLuaBaseObject")
local LuaBindingPath = "base/luabindings/BaseUObject"
local globalIndex = 0
function ObjectUtil:CreateLuaUObject(OuterUObject, Name)
  globalIndex = globalIndex + 1
  return NewObject(UObjectClass, OuterUObject, Name or "BaseUObject" .. globalIndex, LuaBindingPath)
end
function ObjectUtil:CreateLuaUObjectExt(OuterUObject, ClassType, LuaModule, Name)
  globalIndex = globalIndex + 1
  return NewObject(ClassType, OuterUObject, Name or "BaseUObject" .. globalIndex, LuaModule)
end
function ObjectUtil:LoadUIBPClass(WidgetName)
  local DataRows = ConfigMgr:GetUITableRows()
  local WidgetDataRow = DataRows.GetRow(DataRows, WidgetName)
  local PagePath = UE4.UKismetSystemLibrary.BreakSoftClassPath(WidgetDataRow.ViewClass)
  LogDebug("ObjectUtil", "Page Path: " .. PagePath)
  if "" ~= PagePath then
    local PageClass = UE4.UClass.Load(PagePath)
    if PageClass:IsValid() then
      return PageClass
    end
  end
  LogDebug("ObjectUtil", "Page path or class is not exist")
  return nil
end
function ObjectUtil:LoadClass(SoftObjectRef)
  local ClassPath = UE4.UKismetSystemLibrary.Conv_SoftClassReferenceToString(SoftObjectRef)
  LogDebug("ObjectUtil", "Class path: " .. ClassPath)
  if "" ~= ClassPath then
    local ClassToLoad = UE4.UClass.Load(ClassPath)
    if ClassToLoad and ClassToLoad:IsValid() then
      return ClassToLoad
    end
  end
  LogDebug("ObjectUtil", "Class path or class is not exist")
  return nil
end
function ObjectUtil:SetTextColor(textBlock, r, g, b, a)
  if nil == textBlock then
    return
  end
  local red = r or 1
  local green = g or 1
  local blue = b or 1
  local alpha = a or 1
  local color = UE4.FSlateColor()
  color.SpecifiedColor = UE4.UKismetMathLibrary.MakeColor(red, green, blue, alpha)
  textBlock:SetColorAndOpacity(color)
end
function ObjectUtil:GetTextFromFormat(formatString, stringMap)
  for key, value in pairs(stringMap) do
    local replaceChar = "{" .. tostring(key) .. "}"
    formatString = string.replace(formatString, replaceChar, value)
  end
  return formatString
end
return ObjectUtil
