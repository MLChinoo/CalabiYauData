local BattlePassBackGroundMediator = class("BattlePassBackGroundMediator", PureMVC.Mediator)
local BP_SENIOR_COST_ID = 2001
local BP_SENIORPLUS_COST_ID = 2002
local BP_EXTRA_LEVEL_ID = 2003
local SHOW_ITEM = 6
function BattlePassBackGroundMediator:ListNotificationInterests()
  return {
    NotificationDefines.BattlePass.ProgressUpdateView
  }
end
function BattlePassBackGroundMediator:ctor(mediatorName, viewComponent)
  BattlePassBackGroundMediator.super.ctor(self, mediatorName, viewComponent)
end
function BattlePassBackGroundMediator:OnRegister()
  self:GetViewComponent().switchContentEvent:Add(self.SwitchContent, self)
  self:GetViewComponent().purchaseChoiceEvent:Add(self.PurchaseChoice, self)
end
function BattlePassBackGroundMediator:OnRemove()
  self:GetViewComponent().switchContentEvent:Remove(self.SwitchContent, self)
  self:GetViewComponent().purchaseChoiceEvent:Remove(self.PurchaseChoice, self)
end
function BattlePassBackGroundMediator:SwitchContent(index)
  if self.backGroundCfg[index] then
    self:GetViewComponent():OperateView(self.backGroundCfg[index])
  end
end
function BattlePassBackGroundMediator:PurchaseChoice(value)
  self.isSeniorPlus = value
end
function BattlePassBackGroundMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.BattlePass.ProgressUpdateView then
    local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
    if bpProxy then
      viewComponent:SetVip(bpProxy:IsBattlePassVip())
      local NavBarBodyTable = {
        pageType = UE4.EPMFunctionTypes.BattlePass,
        secondIndex = 2
      }
      GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, NavBarBodyTable)
      if self.isSeniorPlus then
        ViewMgr:OpenPage(viewComponent, UIPageNameDefine.BattlePassLevelUpPage, false, {
          Level = self.endLevel
        })
      end
    end
  end
end
function BattlePassBackGroundMediator:OnViewComponentPagePostOpen(luaOpenData, nativeOpenData)
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local viewComponent = self:GetViewComponent()
  if bpProxy then
    if bpProxy:IsSeasonIntermission() then
      viewComponent:SeasonIntermission()
    else
      self.backGroundCfg = bpProxy:GetBackGroundCfg()
      local vip = bpProxy:IsBattlePassVip()
      viewComponent:InitView(self.backGroundCfg, vip, luaOpenData)
      local basicProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
      local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
      local rewards = {}
      if basicProxy and playerProxy then
        rewards.seniorCost = basicProxy:GetParameterIntValue(BP_SENIOR_COST_ID)
        rewards.seniorPlusCost = basicProxy:GetParameterIntValue(BP_SENIORPLUS_COST_ID)
        local extraLevel = basicProxy:GetParameterIntValue(BP_EXTRA_LEVEL_ID)
        local cfg = bpProxy:GetPrizeCfgList()
        local explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
        local curLevel = bpProxy:GetLvByExplore(explore)
        self.endLevel = math.clamp(curLevel + extraLevel, extraLevel + 1, #cfg)
      end
      viewComponent:InitSenior(rewards)
      do return end
      if not vip then
        local rewards = {}
        rewards.prizes = {}
        rewards.obtains = {}
        local basicProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
        local extraLevel = 0
        if basicProxy then
          rewards.seniorCost = basicProxy:GetParameterIntValue(BP_SENIOR_COST_ID)
          rewards.seniorPlusCost = basicProxy:GetParameterIntValue(BP_SENIORPLUS_COST_ID)
          extraLevel = basicProxy:GetParameterIntValue(BP_EXTRA_LEVEL_ID)
        end
        local items
        for index, value in ipairs(self.backGroundCfg) do
          if value.prize:Length() > 0 then
            items = value.prize
            break
          end
        end
        local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
        local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
        if items and itemsProxy and playerProxy then
          for i = 1, items:Length() do
            do
              local prizeInfo = {}
              local itemId = items:Get(i).ItemId
              local itemCfg = itemsProxy:GetAnyItemInfoById(itemId)
              prizeInfo.itemId = itemId
              prizeInfo.img = itemCfg.image
              prizeInfo.num = items:Get(i).ItemAmount
              prizeInfo.name = itemCfg.name
              local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
              if qualityInfo then
                prizeInfo.qualityColor = qualityInfo.Color
              end
              table.insert(rewards.prizes, prizeInfo)
            end
          end
          local cfg = bpProxy:GetPrizeCfgList()
          local explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
          local curLevel = bpProxy:GetLvByExplore(explore)
          self.endLevel = math.clamp(curLevel + extraLevel, extraLevel + 1, #cfg)
          local tempItems = {}
          for index = 1, self.endLevel do
            local prizeCfg = cfg[index]
            if prizeCfg then
              for i = 1, prizeCfg.Prize2:Length() do
                local prizeInfo = {}
                local itemId = prizeCfg.Prize2:Get(i).ItemId
                local itemCfg = itemsProxy:GetAnyItemInfoById(itemId)
                prizeInfo.itemId = itemId
                prizeInfo.img = itemCfg.image
                prizeInfo.num = prizeCfg.Prize2:Get(i).ItemAmount
                prizeInfo.quality = itemCfg.quality
                prizeInfo.name = itemCfg.name
                local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
                if qualityInfo then
                  prizeInfo.qualityColor = qualityInfo.Color
                end
                table.insert(tempItems, prizeInfo)
              end
            end
          end
          for index = curLevel + 1, self.endLevel do
            local prizeCfg = cfg[index]
            if prizeCfg then
              for i = 1, prizeCfg.Prize1:Length() do
                local prizeInfo = {}
                local itemId = prizeCfg.Prize1:Get(i).ItemId
                local itemCfg = itemsProxy:GetAnyItemInfoById(itemId)
                prizeInfo.itemId = itemId
                prizeInfo.img = itemCfg.image
                prizeInfo.num = prizeCfg.Prize1:Get(i).ItemAmount
                prizeInfo.quality = itemCfg.quality
                prizeInfo.name = itemCfg.name
                local qualityInfo = itemsProxy:GetItemQualityConfig(itemCfg.quality)
                if qualityInfo then
                  prizeInfo.qualityColor = qualityInfo.Color
                end
                table.insert(tempItems, prizeInfo)
              end
            end
          end
          table.sort(tempItems, function(a, b)
            return a.quality > b.quality
          end)
          for index, tempItem in ipairs(tempItems) do
            local have = false
            for index, obtain in ipairs(rewards.obtains) do
              if tempItem.itemId == obtain.itemId then
                obtain.num = obtain.num + tempItem.num
                have = true
                break
              end
            end
            if not have and #rewards.obtains < SHOW_ITEM then
              table.insert(rewards.obtains, tempItem)
              have = false
            end
          end
        end
        viewComponent:InitSenior(rewards)
      end
    end
  end
end
return BattlePassBackGroundMediator
