local SettingPageApplyChangeMediator = class("SettingPageApplyChangeMediator", PureMVC.Mediator)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local PanelTypeStr = SettingEnum.PanelTypeStr
local TabStyle = SettingEnum.TabStyle
local handler = function(obj, method)
  return function(...)
    method(obj, ...)
  end
end
function SettingPageApplyChangeMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingValueChangeNtf,
    NotificationDefines.Setting.SettingSwitchPageNtf,
    NotificationDefines.Setting.SetSettingDefaultButtonNtf
  }
end
function SettingPageApplyChangeMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingValueChangeNtf then
    self:ChangeSettingValue(body)
  elseif name == NotificationDefines.Setting.SettingSwitchPageNtf then
    self:ChangeSwitchPage()
  elseif name == NotificationDefines.Setting.SetSettingDefaultButtonNtf and body.btn then
    self:SetDefaultButton(body.btn)
  end
end
function SettingPageApplyChangeMediator:OnRegister()
  self.super:OnRegister()
  local view = self:GetViewComponent()
  view:BindDefaultFunc(handler(self, self.OnClickedDefault))
  view:BindApplyFunc(handler(self, self.OnClickedApply))
  view:BindCloseFunc(handler(self, self.OnClickedClose))
  if view.Button_42 then
    view.Button_42.OnClicked:Add(view, handler(self, self.OnClickedTest))
  end
  self:RefreshView()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
end
function SettingPageApplyChangeMediator:OnRemove()
  self.super:OnRemove()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
end
function SettingPageApplyChangeMediator:OnClickedDefault(_)
  local SettingManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingManagerProxy)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local panelStr = SettingManagerProxy:GetCurPanelStr()
  SettingSaveDataProxy:ApplyTemplateDataToDefaultDataByPanelStr(panelStr)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingDefaultApplyNtf)
  self:RefreshView()
  if panelStr == SettingEnum.PanelTypeStr.Operate then
    local SettingKeyMapManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingKeyMapManagerProxy)
    SettingKeyMapManagerProxy:ApplyDefaultConfig()
  end
end
function SettingPageApplyChangeMediator:OnClickedApply(_)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  SettingSaveDataProxy:ApplyTemplateDataChanged()
  SettingSaveDataProxy:ClearTemplateData()
  self:RefreshView()
end
function SettingPageApplyChangeMediator:OnClickedClose(_)
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    if SettingSaveDataProxy:CheckTemplateDataChanged() then
      self:OnSaveSetting(true)
    else
      self:OnSaveSetting(false)
    end
  elseif SettingSaveDataProxy:CheckTemplateDataChanged() then
    local pageData = {
      contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "3"),
      confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "4"),
      returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "5"),
      source = self,
      cb = self.OnSaveSetting
    }
    ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.MsgDialogPage, false, pageData)
  else
    self:OnSaveSetting(false)
  end
end
function SettingPageApplyChangeMediator:OnSaveSetting(bSave)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  if bSave then
    SettingSaveDataProxy:ApplyTemplateDataChanged()
  else
    SettingSaveDataProxy:RevokeCurrentData()
  end
  ViewMgr:ClosePage(self:GetViewComponent(), UIPageNameDefine.SettingPagePC)
end
function SettingPageApplyChangeMediator:RefreshView()
  local SettingManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingManagerProxy)
  local curPanelType = SettingManagerProxy:GetCurPanelTypeStr()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  self:GetViewComponent():RefreshButtonLayoutByPanelType(curPanelType)
  if curPanelType ~= SettingEnum.PanelTypeStr.Combat then
    local curPanelStr = SettingManagerProxy:GetCurPanelStr()
    if SettingSaveDataProxy:CheckCurrentIsDefaultByPanelStr(curPanelStr) then
      self:GetViewComponent():SetDefaultBtnEnabled(false)
    else
      self:GetViewComponent():SetDefaultBtnEnabled(true)
    end
    if SettingSaveDataProxy:CheckTemplateDataChanged() then
      self:GetViewComponent():SetApplyBtnEnabled(true)
    else
      self:GetViewComponent():SetApplyBtnEnabled(false)
    end
  end
end
function SettingPageApplyChangeMediator:ChangeSettingValue(body)
  self:RefreshView()
end
function SettingPageApplyChangeMediator:ChangeSwitchPage(body)
  self:RefreshView()
  GameFacade:SendNotification(NotificationDefines.Setting.SettingShowTipNtf, {show = false})
end
function SettingPageApplyChangeMediator:SetDefaultButton(defaultBtn)
  self:GetViewComponent():BindDefaultFunc(handler(self, self.OnClickedDefault), defaultBtn)
  self:GetViewComponent():SetDefaultButtonEx(defaultBtn)
end
function SettingPageApplyChangeMediator:OnClickedTest()
  print("GameFacade", GameFacade)
  print(GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy))
end
return SettingPageApplyChangeMediator
