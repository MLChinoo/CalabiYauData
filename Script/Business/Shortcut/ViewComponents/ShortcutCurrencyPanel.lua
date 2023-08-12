local ShortcutCurrencyPanel = class("ShortcutCurrencyPanel", PureMVC.ViewComponentPanel)
local CurrencyMediator = require("Business/Common/Mediators/Currency/CurrencyMediator")
function ShortcutCurrencyPanel:ListNeededMediators()
  return {CurrencyMediator}
end
function ShortcutCurrencyPanel:InitializeLuaEvent()
  self.initViewEvent = LuaEvent.new()
end
function ShortcutCurrencyPanel:Construct()
  ShortcutCurrencyPanel.super.Construct(self)
  self.initViewEvent()
  self:InitText()
end
function ShortcutCurrencyPanel:Destruct()
  ShortcutCurrencyPanel.super.Destruct(self)
end
function ShortcutCurrencyPanel:OnMouseEnter(MyGrometry, MouseEvent)
  self:SetVisibility(UE4.ESlateVisibility.Visible)
end
function ShortcutCurrencyPanel:OnMouseLeave(MyGrometry)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function ShortcutCurrencyPanel:InitText()
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if itemProxy then
    local cystalInfo = itemProxy:GetCurrencyConfig("3")
    if cystalInfo then
      self.Txt_Crystal_Name:SetText(cystalInfo.Name)
      self.Txt_Crystal_Desc:SetText(cystalInfo.Desc)
    end
    local idealInfo = itemProxy:GetCurrencyConfig("2")
    if idealInfo then
      self.Txt_Ideal_Name:SetText(idealInfo.Name)
      self.Txt_Ideal_Desc:SetText(idealInfo.Desc)
    end
    local roleScrapInfo = itemProxy:GetCurrencyConfig("6")
    if roleScrapInfo then
      self.Txt_RoleScrap_Name:SetText(roleScrapInfo.Name)
      self.Txt_RoleScrap_Desc:SetText(roleScrapInfo.Desc)
    end
    local weaponScrapInfo = itemProxy:GetCurrencyConfig("5")
    if weaponScrapInfo then
      self.Txt_WeaponScrap_Name:SetText(weaponScrapInfo.Name)
      self.Txt_WeaponScrap_Desc:SetText(weaponScrapInfo.Desc)
    end
  end
end
function ShortcutCurrencyPanel:UpdateView(crystal, Ideal, roleScrap, weaponScrap)
  if self.Txt_Crystal then
    self.Txt_Crystal:SetText(self:AssembleString(crystal))
  end
  if self.Txt_Ideal then
    self.Txt_Ideal:SetText(self:AssembleString(Ideal))
  end
  if self.Txt_RoleScrap then
    self.Txt_RoleScrap:SetText(self:AssembleString(roleScrap))
  end
  if self.Txt_WeaponScrap then
    self.Txt_WeaponScrap:SetText(self:AssembleString(weaponScrap))
  end
end
function ShortcutCurrencyPanel:AssembleString(inNumber)
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
return ShortcutCurrencyPanel
