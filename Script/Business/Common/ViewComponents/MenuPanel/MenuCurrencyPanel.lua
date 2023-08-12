local MenuCurrencyPanel = class("MenuCurrencyPanel", PureMVC.ViewComponentPanel)
local CurrencyMediator = require("Business/Common/Mediators/Currency/CurrencyMediator")
function MenuCurrencyPanel:ListNeededMediators()
  return {CurrencyMediator}
end
function MenuCurrencyPanel:InitializeLuaEvent()
  self.initViewEvent = LuaEvent.new()
end
function MenuCurrencyPanel:Construct()
  MenuCurrencyPanel.super.Construct(self)
  self.initViewEvent()
end
function MenuCurrencyPanel:Destruct()
  MenuCurrencyPanel.super.Destruct(self)
end
function MenuCurrencyPanel:UpdateView(inCrystal, Ideal, roleScrap)
  if self.Txt_Crystal then
    self.Txt_Crystal:SetText(self:AssembleString(inCrystal))
  end
  if self.Txt_Ideal then
    self.Txt_Ideal:SetText(self:AssembleString(Ideal))
  end
  if self.Txt_RoleScrap then
    self.Txt_RoleScrap:SetText(self:AssembleString(roleScrap))
  end
end
function MenuCurrencyPanel:AssembleString(inNumber)
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
function MenuCurrencyPanel:SetHermes()
  if self.Img_Hermes then
    self.Img_Hermes:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
return MenuCurrencyPanel
