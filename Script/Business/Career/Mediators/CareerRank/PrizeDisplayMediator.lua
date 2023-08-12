local PrizeDisplayMediator = class("PrizeDisplayMediator", PureMVC.Mediator)
function PrizeDisplayMediator:ListNotificationInterests()
  return {
    NotificationDefines.Career.CareerRank.AcquireRankPrize
  }
end
function PrizeDisplayMediator:HandleNotification(notification)
  if notification:GetName() == NotificationDefines.Career.CareerRank.AcquireRankPrize then
    if 0 == notification:GetBody().code then
      self:GetViewComponent():SetPrizeState(notification:GetBody().status)
      local openData = {}
      openData.itemList = {}
      for key, value in pairs(notification:GetBody().items) do
        local itemData = {
          itemId = value.item_id,
          itemCnt = value.item_count
        }
        table.insert(openData.itemList, itemData)
      end
    else
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, notification:GetBody().code)
    end
  end
end
function PrizeDisplayMediator:OnRegister()
  PrizeDisplayMediator.super.OnRegister(self)
end
function PrizeDisplayMediator:OnRemove()
  PrizeDisplayMediator.super.OnRemove(self)
end
return PrizeDisplayMediator
