local SpaceMusicMediator = class("SpaceMusicMediator", PureMVC.Mediator)
function SpaceMusicMediator:ListNotificationInterests()
  return {
    NotificationDefines.Activities.SpaceMusic.UpdateReward
  }
end
function SpaceMusicMediator:OnRegister()
end
function SpaceMusicMediator:OnRemove()
end
function SpaceMusicMediator:OnViewComponentPagePostOpen()
  self:GetViewComponent():InitView(self:ProcessData())
  self:GetViewComponent():InitTimer(self:ProcessTime())
end
function SpaceMusicMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  local viewComponent = self:GetViewComponent()
  if noteName == NotificationDefines.Activities.SpaceMusic.UpdateReward then
    ViewMgr:ClosePage(viewComponent, UIPageNameDefine.PendingPage)
    local body = notification:GetBody()
    if body then
      viewComponent:UpdateRewardState(body)
    end
  end
end
function SpaceMusicMediator:ProcessData()
  local showInfoList = {}
  local musicProxy = GameFacade:RetrieveProxy(ProxyNames.SpaceMusicProxy)
  local itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if musicProxy and itemsProxy then
    local rewardList = musicProxy:GetRewardList()
    for index, value in ipairs(rewardList) do
      local showInfo = {}
      showInfo.day = index
      showInfo.id = value.itemId
      showInfo.cnt = value.itemCnt
      showInfo.status = value.status
      local itemCfg = itemsProxy:GetAnyItemInfoById(value.itemId)
      if itemCfg then
        showInfo.image = itemCfg.image
        showInfo.quality = itemCfg.quality
      end
      showInfoList[index] = showInfo
    end
  else
    LogDebug("SpaceMusic", "//ProcessData获取SpaceMusicProxy = nil ItemsProxy = nil")
  end
  return showInfoList
end
function SpaceMusicMediator:ProcessTime()
  local timeInfo = {}
  local musicProxy = GameFacade:RetrieveProxy(ProxyNames.SpaceMusicProxy)
  local actProxy = GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy)
  if musicProxy and actProxy then
    local actId = musicProxy:GetActivityId()
    if actId then
      local actInfo = actProxy:GetActivityById(actId)
      timeInfo.start = actInfo.cfg.start_time
      timeInfo.expire = actInfo.cfg.expire_time
      timeInfo.valid = timeInfo.expire - UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
    end
  else
    LogDebug("SpaceMusic", "//ProcessTime获取SpaceMusicProxy = nil and ActivitiesProxy = nil")
  end
  return timeInfo
end
return SpaceMusicMediator
