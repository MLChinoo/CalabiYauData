local BattlePassProgressMediatorMobile = class("BattlePassProgressMediatorMobile", PureMVC.Mediator)
local BATTLEPASS_BASIC_GOOD_ID = 8101
local BATTLEPASS_SENIOR_GOOD_ID = 8102
local BATTLEPASS_EXPLORE_GOOD_ID = 8103
function BattlePassProgressMediatorMobile:ListNotificationInterests()
  return {
    NotificationDefines.BattlePass.ProgressInitView,
    NotificationDefines.BattlePass.ProgressUpdateView,
    NotificationDefines.BattlePass.ProgressLvBuyView,
    NotificationDefines.OnResPlayerAttrSync,
    NotificationDefines.BattlePass.PregressLvRewardObtain,
    NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed
  }
end
function BattlePassProgressMediatorMobile:OnRegister()
  self:GetViewComponent().itemSelectEvent:Add(self.ItemSelect, self)
end
function BattlePassProgressMediatorMobile:OnRemove()
  self:GetViewComponent().itemSelectEvent:Remove(self.ItemSelect, self)
end
function BattlePassProgressMediatorMobile:ItemSelect(data, bIsScrolled)
  if not data.isLock and not data.isReceived and not bIsScrolled then
    local sendBody = {
      level = data.level,
      senior = data.isSenior
    }
    GameFacade:SendNotification(NotificationDefines.BattlePass.ProgressCmd, sendBody, NotificationDefines.BattlePass.ProgressCmdTypeClaimOnePrize)
  end
  self:GetViewComponent():UpdateDesc(data)
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if itemProxy then
    local itemType = itemProxy:GetItemIdIntervalType(data.itemId)
    self:GetViewComponent():UpdateModel(data.itemId, itemType)
  end
end
function BattlePassProgressMediatorMobile:OnViewComponentPagePostOpen()
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  if bpProxy then
    if bpProxy:IsSeasonIntermission() then
      self:GetViewComponent():SeasonIntermission()
    else
      GameFacade:SendNotification(NotificationDefines.BattlePass.ProgressCmd, nil, NotificationDefines.BattlePass.ProgressCmdTypeView)
    end
  end
end
function BattlePassProgressMediatorMobile:HandleNotification(notification)
  local noteName = notification:GetName()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.BattlePass.ProgressInitView then
    viewComponent:InitRewards(self:ProcessPrize())
    viewComponent:UpdateLevel(self:ProcessExplore())
    viewComponent:UpdateSeasonInfo(self:ProcessSeason())
    viewComponent:ScrollToView(self:ProcessExplore())
  elseif noteName == NotificationDefines.BattlePass.ProgressUpdateView then
    viewComponent:UpdateRewards(self:ProcessPrize())
    viewComponent:UpdateLevel(self:ProcessExplore())
  elseif noteName == NotificationDefines.BattlePass.ProgressLvBuyView then
    self:ProcessBuyLv(notification:GetBody())
  elseif noteName == NotificationDefines.OnResPlayerAttrSync then
    viewComponent:UpdateRewards(self:ProcessPrize())
    viewComponent:UpdateLevel(self:ProcessExplore())
  elseif noteName == NotificationDefines.BattlePass.PregressLvRewardObtain then
    ViewMgr:OpenPage(viewComponent, UIPageNameDefine.RewardDisplayPage, false, notification:GetBody())
  elseif noteName == NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed then
    ViewMgr:ClosePage(viewComponent, UIPageNameDefine.PendingPage)
    local body = notification:GetBody()
    if body and body.PageName == UIPageNameDefine.BattlePassProgressPage then
      if body.IsSuccessed then
        ViewMgr:OpenPage(viewComponent, UIPageNameDefine.BattlePassLevelUpPage, false, {
          Level = self.targetLevel
        })
      else
        local pageData = {}
        pageData.contentTxt = body.Message
        pageData.source = self
        pageData.cb = self.JumpToBuyCrystal
        ViewMgr:OpenPage(viewComponent, UIPageNameDefine.MsgDialogPage, false, pageData)
      end
    end
  end
end
function BattlePassProgressMediatorMobile:ProcessPrize()
  local completeData = {}
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if playerProxy and bpProxy and itemsProxy then
    local explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
    local curLevel = bpProxy:GetLvByExplore(explore)
    local isVip = bpProxy:IsBattlePassVip()
    local cfg = bpProxy:GetPrizeCfgList()
    for level, prizeCfg in ipairs(cfg) do
      local prizes = {}
      for i = 1, prizeCfg.Prize2:Length() do
        local prizeInfo = {}
        local itemId = prizeCfg.Prize2:Get(i).ItemId
        local itemCfg = itemsProxy:GetAnyItemInfoById(itemId)
        prizeInfo.level = level
        prizeInfo.itemId = itemId
        prizeInfo.img = itemCfg.image
        prizeInfo.num = prizeCfg.Prize2:Get(i).ItemAmount
        local intervalInfo = itemsProxy:GetItemIdInterval(itemId)
        if intervalInfo then
          prizeInfo.intervalName = intervalInfo.ItemTypeName
        end
        local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
        if qualityInfo then
          prizeInfo.qualityColor = qualityInfo.Color
          prizeInfo.qualityName = qualityInfo.Desc
        end
        prizeInfo.isSenior = true
        prizeInfo.isLock = level > curLevel or not isVip
        prizeInfo.isReceived = bpProxy:IsRewardReceived(level, true)
        prizeInfo.name = itemCfg.name
        prizeInfo.desc = itemCfg.desc
        table.insert(prizes, prizeInfo)
      end
      for i = 1, prizeCfg.Prize1:Length() do
        local prizeInfo = {}
        local itemId = prizeCfg.Prize1:Get(i).ItemId
        local itemCfg = itemsProxy:GetAnyItemInfoById(itemId)
        prizeInfo.level = level
        prizeInfo.itemId = itemId
        prizeInfo.img = itemCfg.image
        prizeInfo.num = prizeCfg.Prize1:Get(i).ItemAmount
        local intervalInfo = itemsProxy:GetItemIdInterval(itemId)
        if intervalInfo then
          prizeInfo.intervalName = intervalInfo.ItemTypeName
        end
        local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
        if qualityInfo then
          prizeInfo.qualityColor = qualityInfo.Color
          prizeInfo.qualityName = qualityInfo.Desc
        end
        prizeInfo.isSenior = false
        prizeInfo.isLock = level > curLevel
        prizeInfo.isReceived = bpProxy:IsRewardReceived(level, false)
        prizeInfo.name = itemCfg.name
        prizeInfo.desc = itemCfg.desc
        table.insert(prizes, prizeInfo)
      end
      completeData[level] = prizes
    end
  end
  return completeData
end
function BattlePassProgressMediatorMobile:ProcessExplore()
  local completeData = {}
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  if playerProxy and bpProxy then
    local explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
    local curLevel = bpProxy:GetLvByExplore(explore)
    local curExplore, maxExplore = bpProxy:GetExploreProgress(tonumber(explore))
    completeData.curLevel = curLevel
    completeData.curExp = curExplore
    completeData.maxExp = maxExplore
    completeData.bIsMaxLevel = curLevel >= bpProxy:GetExploreLvMax()
  end
  return completeData
end
function BattlePassProgressMediatorMobile:ProcessBuyLv(data)
  self:BuyProgressLv(true)
end
function BattlePassProgressMediatorMobile:ProcessSeason()
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  if bpProxy then
    local data = {
      inTime = bpProxy:GetSeasonFinshTime() - UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime(),
      inSeasonName = bpProxy:GetSeasonName()
    }
    return data
  end
end
function BattlePassProgressMediatorMobile:BuyProgressLv(bIsConfirm)
  if bIsConfirm then
    local sendBody = {
      StoreId = "19301",
      GoodsNum = self.buyNum,
      PageName = UIPageNameDefine.BattlePassProgressPage
    }
    ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.PendingPage)
    GameFacade:SendNotification(NotificationDefines.Hermes.PurchaseGoods.ReqBuyGoods, sendBody)
  end
end
function BattlePassProgressMediatorMobile:JumpToBuyCrystal(IsClickedTrue)
  if IsClickedTrue then
    local NavBarBodyTable = {
      pageType = UE4.EPMFunctionTypes.Shop,
      secondIndex = 2
    }
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, NavBarBodyTable)
  end
end
return BattlePassProgressMediatorMobile
