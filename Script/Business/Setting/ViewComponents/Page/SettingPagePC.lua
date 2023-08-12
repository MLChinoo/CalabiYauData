local SettingPageMediator = require("Business/Setting/Mediators/SettingPageMediator")
local SettingPageApplyChangeMediator = require("Business/Setting/Mediators/SettingPageApplyChangeMediator")
local SettingPageDelegateMediator = require("Business/Setting/Mediators/SettingPageDelegateMediator")
local SettingPagePC = class("SettingPagePC", PureMVC.ViewComponentPage)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local TabStyle = SettingEnum.TabStyle
function SettingPagePC:ListNeededMediators()
  return {
    SettingPageMediator,
    SettingPageApplyChangeMediator,
    SettingPageDelegateMediator
  }
end
function SettingPagePC:InitializeLuaEvent()
  SettingHelper.InitCfgPath(self)
end
function SettingPagePC:OnOpen(luaOpenData, nativeOpenData)
  local SettingManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingManagerProxy)
  SettingManagerProxy:InitTemplateDataWithOpen()
end
function SettingPagePC:OnClose()
  GameFacade:SendNotification(NotificationDefines.Setting.SettingCloseNtf)
  local SettingManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingManagerProxy)
  SettingManagerProxy:DestoryTemplateDataWithClose()
end
function SettingPagePC:RemoveEvent()
end
function SettingPagePC:LuaHandleKeyEvent(key, inputEvent)
  if UE4.UPMLuaBridgeBlueprintLibrary.IsOpenPageBlocked(self, UIPageNameDefine.SettingPage) == false then
    if self.Button_Apply.MonitorKeyDown then
      return self.Button_Apply:MonitorKeyDown(key, inputEvent) or self.Button_Default:MonitorKeyDown(key, inputEvent) or self.Button_Quit:MonitorKeyDown(key, inputEvent)
    end
    return false
  else
    return false
  end
end
function SettingPagePC:BindDefaultFunc(func)
  self.Button_Default.OnClickEvent:Add(self, func)
end
function SettingPagePC:BindApplyFunc(func)
  self.Button_Apply.OnClickEvent:Add(self, func)
end
function SettingPagePC:BindCloseFunc(func)
  self.Button_Quit.OnClickEvent:Add(self, func)
end
function SettingPagePC:GetTargetIndex()
  return self.targetIndex or 1
end
function SettingPagePC:SetTargetIndex(targetIndex)
  self.targetIndex = targetIndex
end
function SettingPagePC:RefreshButtonLayoutByPanelType(curPanelType)
  if curPanelType == SettingEnum.PanelTypeStr.Combat or curPanelType == SettingEnum.PanelTypeStr.Account then
    self.SizeBox_Default:SetVisibility(UE4.ESlateVisibility.Hidden)
    self.SizeBox_Apply:SetVisibility(UE4.ESlateVisibility.Hidden)
  else
    self.SizeBox_Default:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.SizeBox_Apply:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SettingPagePC:SetDefaultBtnEnabled(bEnabled)
  self.Button_Default:SetHotKeyIsEnable(bEnabled)
end
function SettingPagePC:SetApplyBtnEnabled(bEnabled)
  self.Button_Apply:SetHotKeyIsEnable(bEnabled)
end
return SettingPagePC
