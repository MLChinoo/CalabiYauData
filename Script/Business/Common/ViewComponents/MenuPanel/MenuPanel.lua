local MenuPanel = class("MenuPanel", PureMVC.ViewComponentPanel)
function MenuPanel:Construct()
  MenuPanel.super.Construct(self)
  if self.IsShowChat then
    if self.Btn_Chat then
      self.Btn_Chat.OnClicked:Add(self, MenuPanel.OnClickChat)
    end
  else
    self.SizeBox_Chat:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.IsShowHermes then
    if self.Btn_Hermes then
      self.Btn_Hermes.OnClicked:Add(self, MenuPanel.OnClickHermes)
    end
  elseif self.CurrencyPanel then
    self.CurrencyPanel:SetHermes()
  end
  if self.Btn_Currency then
    self.Btn_Currency.OnClicked:Add(self, MenuPanel.OnClickCurrency)
  end
  if self.Btn_Setting then
    self.Btn_Setting.OnClicked:Add(self, MenuPanel.OnClickSetting)
  end
end
function MenuPanel:Destruct()
  MenuPanel.super.Destruct(self)
  if self.Btn_Chat then
    self.Btn_Chat.OnClicked:Remove(self, MenuPanel.OnClickChat)
  end
  if self.Btn_Currency then
    self.Btn_Currency.OnClicked:Remove(self, MenuPanel.OnClickCurrency)
  end
  if self.Btn_Hemes then
    self.Btn_Hemes.OnClicked:Remove(self, MenuPanel.OnClickHermes)
  end
  if self.Btn_Setting then
    self.Btn_Setting.OnClicked:Remove(self, MenuPanel.OnClickSetting)
  end
end
function MenuPanel:OnClickChat()
  ViewMgr:OpenPage(self, UIPageNameDefine.KaPhonePage)
end
function MenuPanel:OnClickCurrency()
  if self.MenuAnchor_Tips and not self.MenuAnchor_Tips:IsOpen() then
    self.MenuAnchor_Tips:Open(true)
  end
end
function MenuPanel:OnClickHermes()
  ViewMgr:PushPage(self, UIPageNameDefine.HermesTopUpPage, nil, true)
end
function MenuPanel:OnClickSetting()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    ViewMgr:OpenPage(self, UIPageNameDefine.SettingPage)
  else
    ViewMgr:OpenPage(self, UIPageNameDefine.NavigationMenuPage)
  end
end
function MenuPanel:UpdateRedDotKaPhone(cnt)
  if self.RedDot_KaPhone then
    self.RedDot_KaPhone:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return MenuPanel
