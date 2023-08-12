local BattlePassLvMediator = class("BattlePassLvMediator", PureMVC.Mediator)
BattlePassLvMediator.BIG = 5
BattlePassLvMediator.SMALL = 1
function BattlePassLvMediator:ctor(mediatorName, viewComponent)
  BattlePassLvMediator.super.ctor(self, mediatorName, viewComponent)
  self.buyLevel = BattlePassLvMediator.BIG
  self.buyLevelMax = 0
  self.buyMoney = 0
  self.buyNum = 0
  self.targetLevel = 0
end
function BattlePassLvMediator:OnRegister()
  self:GetViewComponent().lvOperateEvent:Add(self.LvOperate, self)
  self:GetViewComponent().lvBuyEvent:Add(self.LvBuy, self)
end
function BattlePassLvMediator:OnRemove()
  self:GetViewComponent().lvOperateEvent:Remove(self.LvOperate, self)
  self:GetViewComponent().lvBuyEvent:Remove(self.LvBuy, self)
end
function BattlePassLvMediator:LvOperate(num)
  if num > 0 then
    if self.buyLevel < self.buyLevelMax then
      self.buyLevel = self.buyLevel + num
      if self.buyLevel > self.buyLevelMax then
        self.buyLevel = self.buyLevelMax
      end
      self:ProcessData()
    end
  elseif num < 0 and self.buyLevel > 1 then
    self.buyLevel = self.buyLevel + num
    if self.buyLevel < 1 then
      self.buyLevel = 1
    end
    self:ProcessData()
  end
end
function BattlePassLvMediator:LvBuy()
  local data = {
    buyNum = self.buyNum,
    targetLevel = self.targetLevel
  }
  GameFacade:SendNotification(NotificationDefines.BattlePass.ProgressLvBuyView, data)
end
function BattlePassLvMediator:OnViewComponentPagePostOpen()
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  if playerProxy and bpProxy then
    local explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
    local curLevel = bpProxy:GetLvByExplore(explore)
    self.buyLevelMax = bpProxy:GetExploreLvMax() - curLevel
    self.buyLevel = self.buyLevelMax > BattlePassLvMediator.BIG and BattlePassLvMediator.BIG or self.buyLevelMax
  end
  self:ProcessData()
end
function BattlePassLvMediator:ProcessData()
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  if playerProxy and bpProxy then
    local explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
    local curLevel = bpProxy:GetLvByExplore(explore)
    self.targetLevel = curLevel + self.buyLevel
    self.buyNum = self.buyLevel
    local hotlistProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
    if hotlistProxy then
      local itemData = hotlistProxy:GetAnyStoreGoodsDataByStoreId("19301")
      if itemData then
        self.buyMoney = self.buyNum * itemData.now_price[1].currency_amount
      end
    end
    self:GetViewComponent():UpdateButtonState(curLevel, self.targetLevel, bpProxy:GetExploreLvMax())
    local costData = {}
    costData.num = self.targetLevel
    costData.cost = self.buyMoney
    costData.add = self.buyLevel
    self:GetViewComponent():UpdateCost(costData)
    local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
    local completeData = {}
    local origin = bpProxy:GetRewardsBetweenLv(curLevel, self.targetLevel, bpProxy:IsBattlePassVip())
    if itemsProxy then
      for index, dataCfg in ipairs(origin) do
        for i = 1, dataCfg:Length() do
          local itemData = {}
          local itemId = dataCfg:Get(i).ItemId
          local itemCfg = itemsProxy:GetAnyItemInfoById(itemId)
          itemData.img = itemCfg.image
          itemData.num = dataCfg:Get(i).ItemAmount
          local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
          if qualityInfo then
            itemData.qualityColor = qualityInfo.Color
          end
          table.insert(completeData, itemData)
        end
      end
      self:GetViewComponent():UpdateItemList(completeData)
    end
  end
end
return BattlePassLvMediator
