local KaPhonePage = class("KaPhonePage", PureMVC.ViewComponentPage)
local KaPhoneMediator = require("Business/KaPhone/Mediators/KaPhoneMediator")
local Mail, CHAT, NAVIGATION = 0, 1, 2
local Collapsed = UE.ESlateVisibility.Collapsed
local Visible = UE.ESlateVisibility.Visible
local SelfHitTestInvisible = UE.ESlateVisibility.SelfHitTestInvisible
local Valid
function KaPhonePage:ListNeededMediators()
  return {KaPhoneMediator}
end
function KaPhonePage:InitPage()
  Valid = self.KaPhoneButton and self.KaPhoneButton:SetVisibility(Visible)
  self:OnClickMail()
end
function KaPhonePage:LuaHandleKeyEvent(key, inputEvent)
  if self.ItemDisplayKeys then
    return self.ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function KaPhonePage:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.CanvasPanel_Chat and self.CanvasPanel_Chat:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:StopAllAnimations()
  if self.LoadingOpen then
    self:BindToAnimationFinished(self.LoadingOpen, {
      self,
      self.PlayCloseAnim
    })
    self:PlayAnimationForward(self.LoadingOpen)
  end
  self.bFirstChat = true
  self.bFirstMail = true
  self:BindEvent()
  self:InitPage()
  Valid = self.ParticleSystem and self.ParticleSystem:SetVisibility(Collapsed)
  Valid = self.ParticleSystem_1 and self.ParticleSystem_1:SetVisibility(Collapsed)
  self:BindRedDot()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.HideKaPhoneRedDot, true)
end
function KaPhonePage:PlayCloseAnim()
  self:PlayAnimationForward(self.LoadingClose)
  Valid = self.CanvasPanel_Chat and self.CanvasPanel_Chat:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function KaPhonePage:OnClose()
  self.bFirstChat = true
  self.bFirstMail = true
  self:StopAllAnimations()
  self:RemoveEvent()
  self:UnbindRedDot()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.HideKaPhoneRedDot, false)
end
function KaPhonePage:BindEvent()
  if self.KaChatButton then
    self.KaChatButton.OnClicked:Add(self, self.OnClickChat)
    self.KaChatButton.OnHovered:Add(self, self.OnHoveredChat)
    self.KaChatButton.OnUnhovered:Add(self, self.OnUnhoveredChat)
  end
  if self.KaNavigationButton then
    self.KaNavigationButton.OnClicked:Add(self, self.OnClickNavigation)
    self.KaNavigationButton.OnHovered:Add(self, self.OnHoveredNavigation)
    self.KaNavigationButton.OnUnhovered:Add(self, self.OnUnhoveredNavigation)
  end
  if self.KaMailButton then
    self.KaMailButton.OnClicked:Add(self, self.OnClickMail)
    self.KaMailButton.OnHovered:Add(self, self.OnHoveredMail)
    self.KaMailButton.OnUnhovered:Add(self, self.OnUnhoveredMail)
  end
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Add(self.OnClickBackground, self)
  Valid = self.Button_Close and self.Button_Close.OnClicked:Add(self, self.OnClickEventBackground)
end
function KaPhonePage:RemoveEvent()
  if self.KaChatButton then
    self.KaChatButton.OnClicked:Remove(self, self.OnClickChat)
    self.KaChatButton.OnHovered:Remove(self, self.OnHoveredChat)
    self.KaChatButton.OnUnhovered:Remove(self, self.OnUnhoveredChat)
  end
  if self.KaNavigationButton then
    self.KaNavigationButton.OnClicked:Remove(self, self.OnClickNavigation)
    self.KaNavigationButton.OnHovered:Remove(self, self.OnHoveredNavigation)
    self.KaNavigationButton.OnUnhovered:Remove(self, self.OnUnhoveredNavigation)
  end
  if self.KaMailButton then
    self.KaMailButton.OnClicked:Remove(self, self.OnClickMail)
    self.KaMailButton.OnHovered:Remove(self, self.OnHoveredMail)
    self.KaMailButton.OnUnhovered:Remove(self, self.OnUnhoveredMail)
  end
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Remove(self.OnClickBackground, self)
  Valid = self.Button_Close and self.Button_Close.OnClicked:Remove(self, self.OnClickEventBackground)
end
function KaPhonePage:OnClickChat()
  self:ChangeDisableButton(CHAT)
  self.CurPage = CHAT
  Valid = self.KaPhoneScrollBox and self.KaPhoneScrollBox:ScrollWidgetIntoView(self.WBP_KaChatPanel, true)
  Valid = self.KaPhoneSwitcher and self.KaPhoneSwitcher:SetActiveWidgetIndex(CHAT)
  if self.bFirstChat then
    self.bFirstChat = false
    GameFacade:SendNotification(NotificationDefines.UpdateKaChatList)
  end
end
function KaPhonePage:OnClickMail()
  self:ChangeDisableButton(Mail)
  self.CurPage = Mail
  Valid = self.KaPhoneScrollBox and self.KaPhoneScrollBox:ScrollWidgetIntoView(self.WBP_KaMailPanel, true)
  Valid = self.KaPhoneSwitcher and self.KaPhoneSwitcher:SetActiveWidgetIndex(Mail)
  if self.bFirstMail then
    self.bFirstMail = false
    GameFacade:SendNotification(NotificationDefines.UpdateMailList)
  end
end
function KaPhonePage:OnClickNavigation()
  self:ChangeDisableButton(NAVIGATION)
  self.CurPage = NAVIGATION
  Valid = self.KaPhoneScrollBox and self.KaPhoneScrollBox:ScrollWidgetIntoView(self.WBP_KaNavigationPanel, true)
  Valid = self.KaPhoneSwitcher and self.KaPhoneSwitcher:SetActiveWidgetIndex(NAVIGATION)
  GameFacade:SendNotification(NotificationDefines.UpdateKaNavigation)
end
function KaPhonePage:OnHoveredChat()
  if self.CurPage ~= CHAT then
    Valid = self.WidgetSwitcher_ChatButton and self.WidgetSwitcher_ChatButton:SetActiveWidgetIndex(1)
  end
end
function KaPhonePage:OnHoveredMail()
  if self.CurPage ~= Mail then
    Valid = self.WidgetSwitcher_MailButton and self.WidgetSwitcher_MailButton:SetActiveWidgetIndex(1)
  end
end
function KaPhonePage:OnHoveredNavigation()
  if self.CurPage ~= NAVIGATION then
    Valid = self.WidgetSwitcher_NaviButton and self.WidgetSwitcher_NaviButton:SetActiveWidgetIndex(1)
  end
end
function KaPhonePage:OnUnhoveredChat()
  if self.CurPage ~= CHAT then
    Valid = self.WidgetSwitcher_ChatButton and self.WidgetSwitcher_ChatButton:SetActiveWidgetIndex(0)
  end
end
function KaPhonePage:OnUnhoveredMail()
  if self.CurPage ~= Mail then
    Valid = self.WidgetSwitcher_MailButton and self.WidgetSwitcher_MailButton:SetActiveWidgetIndex(0)
  end
end
function KaPhonePage:OnUnhoveredNavigation()
  if self.CurPage ~= NAVIGATION then
    Valid = self.WidgetSwitcher_NaviButton and self.WidgetSwitcher_NaviButton:SetActiveWidgetIndex(0)
  end
end
function KaPhonePage:ChangeDisableButton(Button)
  Valid = self.KaChatButton and self.KaChatButton:SetIsEnabled(Button ~= CHAT)
  Valid = self.WidgetSwitcher_ChatButton and self.WidgetSwitcher_ChatButton:SetActiveWidgetIndex(Button ~= CHAT and 0 or 1)
  Valid = self.WBP_KaChatPanel and self.WBP_KaChatPanel:SetIsActive(Button == CHAT)
  Valid = self.KaMailButton and self.KaMailButton:SetIsEnabled(Button ~= Mail)
  Valid = self.WidgetSwitcher_MailButton and self.WidgetSwitcher_MailButton:SetActiveWidgetIndex(Button ~= Mail and 0 or 1)
  Valid = self.WBP_KaMailPanel and self.WBP_KaMailPanel:SetIsActive(Button == Mail)
  Valid = self.KaNavigationButton and self.KaNavigationButton:SetIsEnabled(Button ~= NAVIGATION)
  Valid = self.WidgetSwitcher_NaviButton and self.WidgetSwitcher_NaviButton:SetActiveWidgetIndex(Button ~= NAVIGATION and 0 or 1)
  Valid = self.WBP_KaNavigationPanel and self.WBP_KaNavigationPanel:SetIsActive(Button == NAVIGATION)
end
function KaPhonePage:OnClickEventBackground()
  GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
    target = UIPageNameDefine.KaPhonePage
  }, true)
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function KaPhonePage:OnClickBackground()
  GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
    target = UIPageNameDefine.KaPhonePage
  }, true)
end
function KaPhonePage:ActiveParticle()
  Valid = self.ParticleSystem and self.ParticleSystem:SetVisibility(SelfHitTestInvisible)
  Valid = self.ParticleSystem and self.ParticleSystem:SetReactivate(true)
end
function KaPhonePage:BindRedDot()
  RedDotTree:Bind(RedDotModuleDef.ModuleName.KaChat, function(cnt)
    self:UpdateRedDotKaChat(cnt)
  end)
  self:UpdateRedDotKaChat(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.KaChat))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.KaMail, function(cnt)
    self:UpdateRedDotKaMail(cnt)
  end)
  self:UpdateRedDotKaMail(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.KaMail))
  RedDotTree:Bind(RedDotModuleDef.ModuleName.KaNavigation, function(cnt)
    self:UpdateRedDotKaNavigation(cnt)
  end)
  self:UpdateRedDotKaNavigation(RedDotTree:GetRedDotCnt(RedDotModuleDef.ModuleName.KaNavigation))
end
function KaPhonePage:UnbindRedDot()
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.KaChat)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.KaMail)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.KaNavigation)
end
function KaPhonePage:UpdateRedDotKaChat(cnt)
  Valid = self.RedDot_KaChat and self.RedDot_KaChat:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function KaPhonePage:UpdateRedDotKaMail(cnt)
  Valid = self.RedDot_KaMail and self.RedDot_KaMail:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function KaPhonePage:UpdateRedDotKaNavigation(cnt)
  Valid = self.RedDot_KaNavigation and self.RedDot_KaNavigation:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
return KaPhonePage
