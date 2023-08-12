local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local QQBindSteamMediator = class("QQBindSteamMediator", SuperClass)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local PanelTypeStr = SettingEnum.PanelTypeStr
function QQBindSteamMediator:ListNotificationInterests()
  return self:PackNotificationInterests({
    NotificationDefines.Setting.QQUnbindSteamNtf
  })
end
function QQBindSteamMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  SuperClass.HandleNotification(self, notification)
  if name == NotificationDefines.Setting.QQUnbindSteamNtf then
    self:FixedRelationView()
  end
end
function QQBindSteamMediator:FixedRelationView()
  SuperClass.FixedRelationView(self)
  local view = self:GetViewComponent()
  local LoginSubSystem = UE4.UPMLoginSubSystem.GetInstance(self:GetViewComponent())
  view.Button_UnBind:SetIsEnabled(LoginSubSystem.IsBindSteamSucc)
end
function QQBindSteamMediator:OnRegister()
  SuperClass.OnRegister(self)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  local handler = function(obj, method)
    return function(...)
      method(obj, ...)
    end
  end
  view.Button_UnBind.OnClicked:Add(view, handler(self, self.OnClickedUnBind))
end
function QQBindSteamMediator:OnClickedUnBind(_)
  local pageData = {
    contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "33"),
    cb = function(bOK)
      if bOK then
      end
    end
  }
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.MsgDialogPage, false, pageData)
end
return QQBindSteamMediator
