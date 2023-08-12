local PrizeDisplayPage = class("PrizeDisplayPage", PureMVC.ViewComponentPage)
local PrizeDisplayMediator = require("Business/Career/Mediators/CareerRank/PrizeDisplayMediator")
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function PrizeDisplayPage:ListNeededMediators()
  return {PrizeDisplayMediator}
end
function PrizeDisplayPage:InitView(prizeCfg, prizeStatus)
  if nil == prizeCfg then
    LogError("PrizeDisplayPage", "Prize config is invalid")
    return
  end
  self.rewardId = prizeCfg.Id
  if self.Text_PrizeName then
    self.Text_PrizeName:SetText(prizeCfg.Title)
  end
  if self.PrizeItemsPanel then
    for index = 1, prizeCfg.Reward:Length() do
      local itemData = {}
      itemData.ItemId = prizeCfg.Reward:Get(index).ItemId
      itemData.ItemNum = prizeCfg.Reward:Get(index).ItemAmount
      local Item = self.PrizeItemsPanel:BP_CreateEntry()
      Item:Init(itemData)
      Item.clickItemEvent:Add(self.ChooseItem, self)
    end
    self.itemsPanel = self.PrizeItemsPanel:GetAllEntries()
    if self.itemsPanel:Get(1) then
      self.itemsPanel:Get(1):ClickedItem()
    end
  end
  self:SetPrizeState(prizeStatus)
end
function PrizeDisplayPage:ChooseItem(itemId)
  for index = 1, self.itemsPanel:Length() do
    if self.itemsPanel:Get(index).ItemId ~= itemId then
      self.itemsPanel:Get(index):ResetItem()
    end
  end
  self:ShowItemInfo(itemId)
  if self.KeysPanel then
    local data = {}
    data.itemId = itemId
    data.imageBG = self.Img_BG
    self.KeysPanel:SetItemDisplayed(data)
  end
end
function PrizeDisplayPage:ShowItemInfo(itemId)
  if self.DescPanel then
    self.DescPanel:Update(itemId)
  end
end
function PrizeDisplayPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("PrizeDisplayPage", "Lua implement OnOpen")
  self.isPreviewing = false
  if self.KeysPanel then
    self.KeysPanel.actionOnReturn:Add(self.OnClickReturnPC, self)
    self.KeysPanel.actionOnStartPreview:Add(self.StartPreview, self)
    self.KeysPanel.actionOnStopPreview:Add(self.StopPreview, self)
  end
  self:InitView(luaOpenData.prizeCfg, luaOpenData.status)
  if self.Button_Acquire then
    self.Button_Acquire.OnClickEvent:Add(self, self.AcquirePrize)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Add(self, self.OnClickReturn)
    if self.PageTitle then
      self.Button_Return:SetButtonName(self.PageTitle)
    end
  end
  GameFacade:SendNotification(NotificationDefines.Career.CareerRank.ShowPage, false)
end
function PrizeDisplayPage:OnClose()
  if self.KeysPanel then
    self.KeysPanel.actionOnReturn:Remove(self.OnClickReturnPC, self)
    self.KeysPanel.actionOnStartPreview:Remove(self.StartPreview, self)
    self.KeysPanel.actionOnStopPreview:Remove(self.StopPreview, self)
  end
  GameFacade:SendNotification(NotificationDefines.Career.CareerRank.ShowPage, true)
  if self.Button_Acquire then
    self.Button_Acquire.OnClickEvent:Remove(self, self.AcquirePrize)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Remove(self, self.OnClickReturn)
  end
end
function PrizeDisplayPage:AcquirePrize()
  GameFacade:SendNotification(NotificationDefines.Career.CareerRank.AcquireRankPrizeCmd, self.rewardId)
end
function PrizeDisplayPage:StartPreview(is3DModel)
  if self.SwtichAnimation and not self.isPreviewing then
    self.SwtichAnimation:PlayCloseAnimation()
    self.isPreviewing = true
  end
end
function PrizeDisplayPage:StopPreview(is3DModel)
  if self.SwtichAnimation and self.isPreviewing then
    self.SwtichAnimation:PlayOpenAnimation()
    self.isPreviewing = false
  end
end
function PrizeDisplayPage:SetPrizeState(newState)
  self.prizeStatus = newState
  if self.Button_Acquire then
    if self.prizeStatus == CareerEnumDefine.rewardStatus.locked then
      self.Button_Acquire:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "Locked"))
      self.Button_Acquire:SetButtonIsEnabled(false)
    end
    if self.prizeStatus == CareerEnumDefine.rewardStatus.unlocked then
      self.Button_Acquire:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "AcquireReward"))
      self.Button_Acquire:SetButtonIsEnabled(true)
    end
    if self.prizeStatus == CareerEnumDefine.rewardStatus.hasAcquired then
      self.Button_Acquire:SetPanelName(ConfigMgr:FromStringTable(StringTablePath.ST_Career, "HasAcquired"))
      self.Button_Acquire:SetButtonIsEnabled(false)
    end
    self.Button_Acquire:SetRedDotVisible(self.prizeStatus == CareerEnumDefine.rewardStatus.unlocked)
  end
end
function PrizeDisplayPage:OnClickReturn()
  ViewMgr:PopPage(self, UIPageNameDefine.CareerPrizeDisplay)
end
function PrizeDisplayPage:LuaHandleKeyEvent(key, inputEvent)
  if self.KeysPanel then
    return self.KeysPanel:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function PrizeDisplayPage:OnClickReturnPC()
  ViewMgr:ClosePage(self)
end
return PrizeDisplayPage
