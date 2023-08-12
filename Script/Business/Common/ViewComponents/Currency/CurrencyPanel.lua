local CurrencyPanel = class("CurrencyPanel", PureMVC.ViewComponentPanel)
local CurrencyMediator = require("Business/Common/Mediators/Currency/CurrencyMediator")
local Valid
function CurrencyPanel:ListNeededMediators()
  return {CurrencyMediator}
end
function CurrencyPanel:InitializeLuaEvent()
  self.initViewEvent = LuaEvent.new()
end
function CurrencyPanel:Construct()
  CurrencyPanel.super.Construct(self)
  Valid = self.HorizontalBox_Role and self.HorizontalBox_Role:SetVisibility(self.bIsShowRole and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.HorizontalBox_Crystal and self.HorizontalBox_Crystal:SetVisibility(self.bIsShowCrystal and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.HorizontalBox_Ideal and self.HorizontalBox_Ideal:SetVisibility(self.bIsShowIdeal and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.Spacer_Role and self.Spacer_Role:SetVisibility(self.bIsShowRole and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  Valid = self.Spacer_Ideal and self.Spacer_Ideal:SetVisibility(self.bIsShowIdeal and UE.ESlateVisibility.SelfHitTestInvisible or UE.ESlateVisibility.Collapsed)
  self.initViewEvent()
end
function CurrencyPanel:Destruct()
  CurrencyPanel.super.Destruct(self)
end
function CurrencyPanel:OnMouseButtonUp(MyGrometry, MouseEvent)
  if self.JumpToHermes then
    GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
      target = UIPageNameDefine.HermesHotListPage
    })
  end
  return true
end
function CurrencyPanel:UpdateView(inCrystal, Ideal, roleScrap, emWeaponScrap)
  if self.Txt_Crystal then
    self.Txt_Crystal:SetText(self:AssembleString(inCrystal))
  end
  if self.Txt_Ideal then
    self.Txt_Ideal:SetText(self:AssembleString(Ideal))
  end
  if self.Txt_Role then
    self.Txt_Role:SetText(self:AssembleString(roleScrap))
  end
  if self.Txt_Particle then
    self.Txt_Particle:SetText(self:AssembleString(emWeaponScrap))
  end
end
function CurrencyPanel:AssembleString(inNumber)
  local number = tonumber(inNumber) or 0
  local unit
  if number <= 999999 then
    unit = ""
  elseif number <= 99999999 then
    number = math.floor(number / 10000)
    unit = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "TenThousand")
  else
    number = math.floor(number / 100000000)
    unit = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "HundredMillion")
  end
  number = number .. unit
  return number
end
return CurrencyPanel
