local KaNavigationPanel = class("KaNavigationPanel", PureMVC.ViewComponentPanel)
local KaNavigationMediator = require("Business/KaPhone/Mediators/KaNavigationMediator")
local Valid
function KaNavigationPanel:GetIsActive()
  return self.IsActive
end
function KaNavigationPanel:SetIsActive(IsActive)
  self.IsActive = IsActive
end
function KaNavigationPanel:Update(NavData)
  local InitItem = function(RoleId, ItemData)
    if self.ButtonMap and self.ButtonMap[RoleId] then
      self.ButtonMap[RoleId]:InitItem(ItemData, RoleId == self.RoleId)
      self.ButtonMap[RoleId].actionOnClick:Add(self.OnClickButton, self)
    end
  end
  if NavData then
    if NavData.Current then
      local CurrentData = NavData.Current
      self.RoleId = CurrentData.RoleId
      Valid = self.Name and self.Name:SetText(CurrentData.Name)
      Valid = self.RightPanel and self.RightPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      Valid = self.SmallName and self.SmallName:SetText(CurrentData.Name)
      Valid = self.Address and self.Address:SetText(CurrentData.Address)
      Valid = self.SmallAddress and self.SmallAddress:SetText(CurrentData.Address)
      Valid = self.LoveLevel and self.LoveLevel:SetText(CurrentData.LoveLevel)
      Valid = CurrentData.Avatar and self.Avatar and self:SetImageByTexture2D(self.Avatar, CurrentData.Avatar)
      Valid = CurrentData.Avatar and self.SmallAvatar and self:SetImageByTexture2D(self.SmallAvatar, CurrentData.Avatar)
      InitItem(CurrentData.RoleId, CurrentData)
    end
    if NavData.Others then
      for key, value in pairs(NavData.Others or {}) do
        InitItem(value.RoleId, value)
      end
    end
    self.LastClickButton = nil
  end
end
function KaNavigationPanel:OnClickButton(Button)
  if self.LastClickButton then
    if self.LastClickButton == Button then
      return nil
    end
    self.LastClickButton:ResetButtonState()
  end
  self.LastClickButton = Button
  local CurrentData = Button and Button.Data
  if CurrentData then
    Valid = CurrentData.Avatar and self.Avatar and self:SetImageByTexture2D(self.Avatar, CurrentData.Avatar)
    Valid = self.Name and self.Name:SetText(CurrentData.Name)
    Valid = self.Address and self.Address:SetText(CurrentData.Address)
    Valid = self.LoveLevel and self.LoveLevel:SetText(CurrentData.LoveLevel)
    Valid = self.RightPanel and self.RightPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if CurrentData.RoleId == self.RoleId then
      Valid = self.Button_NaviTo and self.Button_NaviTo:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      Valid = self.Button_NaviTo and self.Button_NaviTo:SetVisibility(UE.ESlateVisibility.Visible)
    end
    if GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetIsFirstEnterRoom(CurrentData.RoleId) then
      Valid = self.WidgetSwitcher_BtnNaviTo and self.WidgetSwitcher_BtnNaviTo:SetActiveWidgetIndex(1)
    else
      Valid = self.WidgetSwitcher_BtnNaviTo and self.WidgetSwitcher_BtnNaviTo:SetActiveWidgetIndex(0)
    end
    if self.Kaphone_Into then
      self:PlayAnimation(self.Kaphone_Into, 0)
    end
  end
end
function KaNavigationPanel:OnClickNaviTo(Button)
  local InMatchTextContent = ConfigMgr:FromStringTable(StringTablePath.ST_KaPhone, "JumpPageInMatchTips")
  if GameFacade:RetrieveProxy(ProxyNames.RoomProxy):GetIsInMatch() then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, InMatchTextContent)
    return nil
  end
  local RoleId = self.LastClickButton and self.LastClickButton.Data and self.LastClickButton.Data.RoleId
  if RoleId == self.RoleId then
    return nil
  end
  local Body = {Page = self, RoleId = RoleId}
  if GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetIsFirstEnterRoom(RoleId) then
    Valid = self.LastClickButton and self.LastClickButton:PlayUnlockPS()
    ViewMgr:OpenPage(self, UIPageNameDefine.KaNavigationJumpPopUpPage, nil, Body)
  else
    GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):ReqUpdateRole(Body)
    GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
      target = UIPageNameDefine.KaPhonePage
    }, true)
  end
end
function KaNavigationPanel:OnClickReturn()
  if self.LastClickButton then
    self.LastClickButton:ResetButtonState()
    if self.Kaphone_Into then
      self:PlayAnimationReverse(self.Kaphone_Into)
    end
  end
  self.LastClickButton = nil
end
function KaNavigationPanel:ListNeededMediators()
  return {KaNavigationMediator}
end
function KaNavigationPanel:Construct()
  KaNavigationPanel.super.Construct(self)
  self.ButtonMap = {}
  self.LastClickButton = nil
  local ButtonList = self.CanvasPanel_Roles and self.CanvasPanel_Roles:GetAllChildren()
  if ButtonList then
    for i = 1, ButtonList:Length() do
      local Button = ButtonList:Get(i)
      self.ButtonMap[Button.ShowRoleId] = Button
    end
  end
  Valid = self.Button_NaviTo and self.Button_NaviTo.OnClicked:Add(self, self.OnClickNaviTo)
  Valid = self.Button_Return and self.Button_Return.OnClicked:Add(self, self.OnClickReturn)
end
function KaNavigationPanel:Destruct()
  for i, v in pairs(self.ButtonMap) do
    Valid = v and v.actionOnClick:Remove(self.OnClickButton, self)
  end
  Valid = self.Button_NaviTo and self.Button_NaviTo.OnClicked:Remove(self, self.OnClickNaviTo)
  Valid = self.Button_Return and self.Button_Return.OnClicked:Remove(self, self.OnClickReturn)
  self.ButtonMap = {}
  self.LastClickButton = nil
  KaNavigationPanel.super.Destruct(self)
end
return KaNavigationPanel
