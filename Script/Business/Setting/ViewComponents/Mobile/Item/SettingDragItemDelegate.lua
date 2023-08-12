local SettingDragItemDelegate = class("SettingDragItemDelegate", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingDragItemMediator = require("Business/Setting/Mediators/Mobile/SettingDragItemMediator")
function SettingDragItemDelegate:ListNeededMediators()
  if self.parent.abbrevIndex ~= nil then
    return {}
  else
    return {SettingDragItemMediator}
  end
end
function SettingDragItemDelegate:BindDelegate(name, parent)
  self.indexName = name
  local logAttr = {}
  local tbl = require(self.LuaModuleNameBP)
  local ori = tbl
  for i = 1, 100 do
    for k, v in pairs(ori) do
      if nil == self[k] or nil == logAttr[k] then
        self[k] = v
        logAttr[k] = true
      end
    end
    ori = tbl.super
    if nil == ori then
      break
    end
  end
  self:InitView(name, parent)
  self:BindEvent()
  if nil ~= parent.abbrevIndex then
    print("unregisterMediater")
    self:UnregisterMediator()
  end
end
function SettingDragItemDelegate:PostInit()
  self:SetLastChanged()
end
return SettingDragItemDelegate
