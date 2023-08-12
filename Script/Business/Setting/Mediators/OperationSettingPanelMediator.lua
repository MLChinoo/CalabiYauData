local OperationSettingPanelMediator = class("OperationSettingPanelMediator", PureMVC.Mediator)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local PanelTypeStr = SettingEnum.PanelTypeStr
local ItemType = SettingEnum.ItemType
function OperationSettingPanelMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingSubJumpPage
  }
end
function OperationSettingPanelMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingSubJumpPage and self._tabPanel and body.pageName == PanelTypeStr.Operate then
    self._tabPanel:SwitchTab(body.subIndex)
  end
end
function OperationSettingPanelMediator:OnRegister()
  self.super:OnRegister()
  self.mapIndexUI = {}
  self:InitView()
end
function OperationSettingPanelMediator:InitView()
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local subTypeList, titleTypeMap, allItemMap = SettingConfigProxy:GetDataByPanelStr(PanelTypeStr.Operate)
  self._data = {
    subTypeList = subTypeList,
    titleTypeMap = titleTypeMap,
    allItemMap = allItemMap
  }
  local args = {}
  for i, v in ipairs(subTypeList) do
    args[#args + 1] = {
      text = v,
      callfunc = function(index)
        self:ShowSubView(index)
      end
    }
  end
  local extras = {isSub = true}
  local tabPanel = SettingHelper.CreateTabItemPanel(args, extras)
  self:GetViewComponent().CanvasPanel_TopSubItemList:AddChild(tabPanel)
  self._tabPanel = tabPanel
  self._subTypeList = subTypeList
  if self._tabPanel then
    local targetIndex = self:GetViewComponent():GetTargetIndex()
    self._tabPanel:SwitchTab(targetIndex)
  end
end
function OperationSettingPanelMediator:ShowSubView(index)
  local widgetSwitcher = self:GetViewComponent().WidgetSwitcher
  if index then
    if self.mapIndexUI[index] == nil then
      local subTypeStr = self._data.subTypeList[index]
      local titleTypeMap = self._data.titleTypeMap[subTypeStr]
      local args = {
        itemList = self._data.allItemMap[subTypeStr],
        titleList = self._data.titleTypeMap[subTypeStr]
      }
      local itemlistPanel = SettingHelper.CreateItemListPanel(args)
      widgetSwitcher:AddChild(itemlistPanel)
      self.mapIndexUI[index] = widgetSwitcher:GetChildrenCount() - 1
    end
    widgetSwitcher:SetActiveWidgetIndex(self.mapIndexUI[index])
  end
end
function OperationSettingPanelMediator:OnRemove()
  self.super:OnRemove()
end
return OperationSettingPanelMediator
