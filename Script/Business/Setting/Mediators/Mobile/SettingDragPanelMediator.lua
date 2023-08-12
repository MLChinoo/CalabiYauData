local SettingDragPanelMediator = class("SettingDragPanelMediator", PureMVC.Mediator)
function SettingDragPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.MBSaveLayout
  }
end
function SettingDragPanelMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.MBSaveLayout then
    self:SavePanel()
  end
end
function SettingDragPanelMediator:SavePanel()
  local SettingCustomLayoutMap = require("Business/Setting/Proxies/Map/SettingCustomLayoutMap")
  local CustomeKeyList = SettingCustomLayoutMap.KeyList
  local View = self:GetViewComponent()
  local layoutMap = {}
  for key, tbl in pairs(CustomeKeyList) do
    local widgetName = tbl[1]
    local item = UE4.FMoveItem()
    local widget = View[widgetName]
    local pos = widget.Slot:GetPosition()
    item.PosX = math.floor(pos.X * 100)
    item.PosY = math.floor(pos.Y * 100)
    item.Opacity = math.floor(widget.RenderOpacity * 100)
    item.Scale = math.floor(widget.RenderTransform.Scale.X * 100)
    print("widgetName:", widgetName, "Scale", item.Scale, "Opacity", item.Opacity)
    layoutMap[widgetName] = item
  end
  local SettingSaveGameProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveGameProxy)
  SettingSaveGameProxy:StoreLayoutMapToSaveGame(layoutMap)
end
function SettingDragPanelMediator:OnRegister()
  self.super:OnRegister()
end
function SettingDragPanelMediator:OnRemove()
  self.super:OnRemove()
end
return SettingDragPanelMediator
