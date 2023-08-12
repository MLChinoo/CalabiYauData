local BallSetDisplayMediator = class("BallSetDisplayMediator", PureMVC.Mediator)
local LotteryEnum = require("Business/Lottery/Proxies/LotteryEnumDefine")
function BallSetDisplayMediator:ListNotificationInterests()
  return {
    NotificationDefines.Lottery.InitSceneViews,
    NotificationDefines.Lottery.InitOperationDesk,
    NotificationDefines.Lottery.SetBallType,
    NotificationDefines.Lottery.ClearTypeSet,
    NotificationDefines.Lottery.DoLottery,
    NotificationDefines.Lottery.EnableTableInput
  }
end
function BallSetDisplayMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Lottery.InitSceneViews then
    self:GetViewComponent():InitView()
  end
  local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
  if notification:GetName() == NotificationDefines.Lottery.InitOperationDesk then
    GameFacade:SendNotification(NotificationDefines.Lottery.SetLotteryCnt, 0)
    lotteryProxy:ClearLotteryBallSet()
    self:GetViewComponent():InitOperationDesk()
  end
  if notification:GetName() == NotificationDefines.Lottery.EnableTableInput then
    self:GetViewComponent():SetEnableInput(notification:GetBody())
  end
  if notification:GetName() == NotificationDefines.Lottery.SetBallType then
    local maxCount = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetMaxCount()
    if notification:GetBody() == LotteryEnum.ballItemType.Null then
      local curCount = table.count(lotteryProxy:GetLotteryBallSet())
      if maxCount <= curCount then
        return
      end
      for i = curCount + 1, maxCount do
        local itemType = math.random() >= 0.5 and LotteryEnum.ballItemType.Line or LotteryEnum.ballItemType.Circle
        lotteryProxy:SetLotteryBallType(i, itemType)
      end
      self:GetViewComponent():QuickPlay()
      self.activeItemIndex = maxCount
    else
      lotteryProxy:SetLotteryBallType(self.activeItemIndex, notification:GetBody())
      self:GetViewComponent():SetBallType(self.activeItemIndex)
    end
    GameFacade:SendNotification(NotificationDefines.Lottery.SetLotteryCnt, table.count(lotteryProxy:GetLotteryBallSet()))
  end
  if notification:GetName() == NotificationDefines.Lottery.ClearTypeSet and table.count(lotteryProxy:GetLotteryBallSet()) >= 1 then
    GameFacade:SendNotification(NotificationDefines.Lottery.SetLotteryCnt, 0)
    lotteryProxy:ClearLotteryBallSet()
    self:GetViewComponent():Clear()
    self.activeItemIndex = 1
  end
  if notification:GetName() == NotificationDefines.Lottery.DoLottery then
    self:GetViewComponent():StartLotteryProcess()
  end
end
function BallSetDisplayMediator:OnRegister()
  LogDebug("BallSetDisplayMediator", "On register")
  BallSetDisplayMediator.super.OnRegister(self)
  self:GetViewComponent().actionOnSetActiveItem:Add(self.SetActiveItemIndex, self)
  self.activeItemIndex = 1
end
function BallSetDisplayMediator:OnRemove()
  self:GetViewComponent().actionOnSetActiveItem:Remove(self.SetActiveItemIndex, self)
  BallSetDisplayMediator.super.OnRemove(self)
end
function BallSetDisplayMediator:SetActiveItemIndex(index)
  LogDebug("BallSetDisplayMediator", "Set active item index:%d", index)
  local maxCount = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetMaxCount()
  self.activeItemIndex = math.min(index, maxCount)
end
return BallSetDisplayMediator
