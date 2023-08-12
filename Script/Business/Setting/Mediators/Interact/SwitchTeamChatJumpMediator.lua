local SuperClass = require("Business/Setting/Mediators/Interact/DefaultCommonMediator")
local SwitchTeamChatJumpMediator = class("SwitchTeamChatJumpMediator", SuperClass)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local PanelTypeStr = SettingEnum.PanelTypeStr
function SwitchTeamChatJumpMediator:OnRegister()
  SuperClass.OnRegister(self)
  local view = self:GetViewComponent()
  local oriData = view.oriData
  view.TextBlock_Desc:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "31"))
  local handler = function(obj, method)
    return function(...)
      method(obj, ...)
    end
  end
  view.Button_Jump.OnClicked:Add(view, handler(self, self.OnClickedJump))
end
function SwitchTeamChatJumpMediator:OnClickedJump(_)
  local SettingManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingManagerProxy)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingJumpPage, {
    panelTypeStr = PanelTypeStr.Operate,
    subPanelStr = SettingEnum.OperateSubPanelTypeStr.Communicate
  })
end
return SwitchTeamChatJumpMediator
