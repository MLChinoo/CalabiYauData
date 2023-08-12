local BattlePassClueMediatorMobile = class("BattlePassClueMediatorMobile", PureMVC.Mediator)
function BattlePassClueMediatorMobile:ctor(mediatorName, viewComponent)
  BattlePassClueMediatorMobile.super.ctor(self, mediatorName, viewComponent)
  self.clueData = {}
end
function BattlePassClueMediatorMobile:ListNotificationInterests()
  return {
    NotificationDefines.BattlePass.ClueRewardUpdate
  }
end
function BattlePassClueMediatorMobile:HandleNotification(notification)
  local noteName = notification:GetName()
  if noteName == NotificationDefines.BattlePass.ClueRewardUpdate then
    local clueId = notification:GetBody()
    if self.clueData[clueId] then
      self.clueData[clueId].isRewardRecevied = true
      self:GetViewComponent():UpdateRewardState(clueId)
    end
  end
end
function BattlePassClueMediatorMobile:OnRegister()
  self:GetViewComponent().switchEvent:Add(self.SwitchEvent, self)
end
function BattlePassClueMediatorMobile:OnRemove()
  self:GetViewComponent().switchEvent:Remove(self.SwitchEvent, self)
end
function BattlePassClueMediatorMobile:SwitchEvent(index)
  if self.clueData[index] then
    ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.BattlePassClueRewardPage, false, self.clueData[index])
  end
end
function BattlePassClueMediatorMobile:OnViewComponentPagePostOpen()
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  if bpProxy then
    if bpProxy:IsSeasonIntermission() then
      self:GetViewComponent():SeasonIntermission()
    else
      self:ProcessData()
    end
  end
end
function BattlePassClueMediatorMobile:ProcessData()
  self.clueData = {}
  local playerProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local bpProxy = GameFacade:RetrieveProxy(ProxyNames.BattlePassProxy)
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if playerProxy and bpProxy and itemProxy then
    local explore = playerProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emExplore)
    local curLevel = bpProxy:GetLvByExplore(explore)
    for clueId, value in ipairs(bpProxy:GetClueCfgList()) do
      local itemData = {}
      itemData.clueId = value.ClueId
      itemData.title = value.Title
      itemData.content = value.Content
      itemData.unlockLevel = value.UnlockLevel
      itemData.iconNormal = value.IconNormal
      itemData.iconHovered = value.IconHovered
      itemData.iconPressed = value.IconPressed
      itemData.iconClueId = value.IconClueId
      itemData.newsTitle = value.NewsTitle
      itemData.newsContent = value.NewsContent
      itemData.isUnlock = curLevel >= value.UnlockLevel and true or false
      itemData.isRewardRecevied = bpProxy:IsClueRewardReceived(clueId)
      local prizeInfo = {}
      local prize = value.Prize1:Get(1)
      local itemInfo = itemProxy:GetAnyItemInfoById(prize.ItemId)
      prizeInfo.img = itemInfo.image
      prizeInfo.num = prize.ItemAmount
      prizeInfo.name = itemInfo.name
      prizeInfo.itemId = prize.ItemId
      itemData.prizeInfo = prizeInfo
      self.clueData[clueId] = itemData
    end
  end
  self:GetViewComponent():UpdateCluePage(self.clueData)
end
return BattlePassClueMediatorMobile