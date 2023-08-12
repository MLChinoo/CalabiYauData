local KaPhonePageMobile = class("KaPhonePageMobile", PureMVC.ViewComponentPage)
local KaPhoneMediator = require("Business/KaPhone/Mediators/KaPhoneMediator")
local CHAT, Mail, NAVIGATION = 0, 1, 2
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function KaPhonePageMobile:ListNeededMediators()
  return {KaPhoneMediator}
end
function KaPhonePageMobile:InitPage()
  self:OnClickMail()
end
function KaPhonePageMobile:LuaHandleKeyEvent(key, inputEvent)
  return false
end
function KaPhonePageMobile:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.AnimOpen and self:PlayAnimationForward(self.AnimOpen, 1, false)
  self:BindEvent()
  self:InitPage()
  if TimerMgr then
    self.CurrentTimer = TimerMgr:AddTimeTask(0, self.RefreshCurrentTime, 0, function()
      self.CurrentTime:SetText(os.date("%H:%M"))
    end)
  end
  self.ParticleSystem:SetVisibility(Collapsed)
  self:BindRedDot()
end
function KaPhonePageMobile:OnClose()
  self.CurrentTimer:EndTask()
  self.CurrentTimer = nil
  self:UnbindRedDot()
  self:RemoveEvent()
end
function KaPhonePageMobile:BindEvent()
  Valid = self.KaChatButton and self.KaChatButton.OnClicked:Add(self, self.OnClickChat)
  Valid = self.KaNavigationButton and self.KaNavigationButton.OnClicked:Add(self, self.OnClickNavigation)
  Valid = self.KaMailButton and self.KaMailButton.OnClicked:Add(self, self.OnClickMail)
  Valid = self.Button_Close and self.Button_Close.OnClicked:Add(self, self.OnClickClose)
end
function KaPhonePageMobile:RemoveEvent()
  Valid = self.KaChatButton and self.KaChatButton.OnClicked:Remove(self, self.OnClickChat)
  Valid = self.KaNavigationButton and self.KaNavigationButton.OnClicked:Remove(self, self.OnClickNavigation)
  Valid = self.KaMailButton and self.KaMailButton.OnClicked:Remove(self, self.OnClickMail)
  Valid = self.Button_Close and self.Button_Close.OnClicked:Remove(self, self.OnClickClose)
end
function KaPhonePageMobile:OnClickChat()
end
function KaPhonePageMobile:OnClickMail()
  self:ChangedisableButton(Mail)
  Valid = self.KaPhoneSwitcher and self.KaPhoneSwitcher:SetActiveWidgetIndex(Mail)
  Valid = self.LeftBackgroundImage and self.LeftBackgroundImage:SetVisibility(SelfHitTestInvisible)
  GameFacade:SendNotification(NotificationDefines.UpdateMailList)
end
function KaPhonePageMobile:OnClickNavigation()
  self:ChangedisableButton(NAVIGATION)
  Valid = self.KaPhoneSwitcher and self.KaPhoneSwitcher:SetActiveWidgetIndex(NAVIGATION)
  Valid = self.LeftBackgroundImage and self.LeftBackgroundImage:SetVisibility(SelfHitTestInvisible)
  GameFacade:SendNotification(NotificationDefines.UpdateKaNavigation)
end
function KaPhonePageMobile:OnClickClose()
  ViewMgr:ClosePage(self)
end
function KaPhonePageMobile:ChangedisableButton(Button)
  Valid = self.KaChatButton and self.KaChatButton:SetIsEnabled(Button ~= CHAT)
  Valid = self.WBP_KaChatPanel and self.WBP_KaChatPanel:SetIsActive(Button == CHAT)
  Valid = self.KaMailButton and self.KaMailButton:SetIsEnabled(Button ~= Mail)
  Valid = self.WBP_KaMailPanel and self.WBP_KaMailPanel:SetIsActive(Button == Mail)
  Valid = self.KaNavigationButton and self.KaNavigationButton:SetIsEnabled(Button ~= NAVIGATION)
  Valid = self.WBP_KaNavigationPanel and self.WBP_KaNavigationPanel:SetIsActive(Button == NAVIGATION)
end
function KaPhonePageMobile:ActiveParticle()
  Valid = self.ParticleSystem and self.ParticleSystem:SetVisibility(SelfHitTestInvisible)
  Valid = self.ParticleSystem and self.ParticleSystem:SetReactivate(true)
end
function KaPhonePageMobile:BindRedDot()
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
function KaPhonePageMobile:UnbindRedDot()
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.KaChat)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.KaMail)
  RedDotTree:Unbind(RedDotModuleDef.ModuleName.KaNavigation)
end
function KaPhonePageMobile:UpdateRedDotKaChat(cnt)
  Valid = self.RedDot_KaChat and self.RedDot_KaChat:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function KaPhonePageMobile:UpdateRedDotKaMail(cnt)
  Valid = self.RedDot_KaMail and self.RedDot_KaMail:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function KaPhonePageMobile:UpdateRedDotKaNavigation(cnt)
  Valid = self.RedDot_KaNavigation and self.RedDot_KaNavigation:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
return KaPhonePageMobile
