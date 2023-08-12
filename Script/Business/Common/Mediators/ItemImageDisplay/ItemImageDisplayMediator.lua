local ItemImageDisplayMediator = class("ItemImageDisplayMediator", PureMVC.Mediator)
local ItemsProxy
function ItemImageDisplayMediator:ListNotificationInterests()
  return {
    NotificationDefines.ItemImageDisplay
  }
end
function ItemImageDisplayMediator:OnRegister()
  ItemImageDisplayMediator.super.OnRegister(self)
  ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
end
function ItemImageDisplayMediator:OnRemove()
  ItemImageDisplayMediator.super.OnRemove(self)
end
function ItemImageDisplayMediator:HandleNotification(notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.ItemImageDisplay then
    self:SetItemImg(notifyBody)
  end
end
function ItemImageDisplayMediator:SetItemImg(itemID)
  if itemID then
    self:GetViewComponent():SetImage(itemID)
  else
    self:GetViewComponent():ClearImage()
  end
end
return ItemImageDisplayMediator
