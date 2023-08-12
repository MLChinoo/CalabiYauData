local NavBarCurrencyPanel = class("NavBarCurrencyPanel", PureMVC.ViewComponentPanel)
local CurrencyMediator = require("Business/Common/Mediators/Currency/CurrencyMediator")
function NavBarCurrencyPanel:ListNeededMediators()
  return {CurrencyMediator}
end
function NavBarCurrencyPanel:InitializeLuaEvent()
  self.initViewEvent = LuaEvent.new()
end
function NavBarCurrencyPanel:Construct()
  NavBarCurrencyPanel.super.Construct(self)
  self.initViewEvent()
end
function NavBarCurrencyPanel:Destruct()
  NavBarCurrencyPanel.super.Destruct(self)
end
function NavBarCurrencyPanel:OnBtnClick()
  local obtainData = {}
  obtainData.overflowItemList = {}
  obtainData.itemList = {}
  local testList = {
    "31000002",
    "10202002",
    "31000",
    "20101051",
    "32000003",
    "10202002",
    "30000004"
  }
  for key, value in ipairs(testList) do
    local info = {}
    info.itemId = value
    info.itemCnt = 1
    table.insert(obtainData.itemList, info)
  end
  ViewMgr:OpenPage(self, UIPageNameDefine.RewardDisplayPage, false, obtainData)
end
function NavBarCurrencyPanel:UpdateView(inCrystal, Ideal)
  if self.Txt_Crystal then
    self.Txt_Crystal:SetText(self:AssembleString(inCrystal))
  end
  if self.Txt_Ideal then
    self.Txt_Ideal:SetText(self:AssembleString(Ideal))
  end
end
function NavBarCurrencyPanel:AssembleString(inNumber)
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
return NavBarCurrencyPanel
