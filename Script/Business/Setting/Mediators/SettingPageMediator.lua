local SettingPageMediator = class("SettingPageMediator", PureMVC.Mediator)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local UGameplayStatics = UE4.UGameplayStatics
local EPMGameModeType = UE4.EPMGameModeType
local TabStyle = SettingEnum.TabStyle
local PanelTypeStr = SettingEnum.PanelTypeStr
function SettingPageMediator:ListNotificationInterests()
  return {
    NotificationDefines.Setting.SettingJumpPage
  }
end
function SettingPageMediator:HandleNotification(notification)
  local name = notification:GetName()
  local body = notification:GetBody()
  if name == NotificationDefines.Setting.SettingJumpPage then
    local index = self:GetIndexByPageStr(body.panelTypeStr)
    local subIndex = 1
    local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
    local subTypeList, titleTypeMap, allItemMap = SettingConfigProxy:GetDataByPanelStr(body.panelTypeStr)
    for i, v in ipairs(subTypeList) do
      if v == body.subPanelStr then
        subIndex = i
      end
    end
    self._tabPanel:SwitchTab(index, subIndex)
  end
end
function SettingPageMediator:OnRegister()
  self.super:OnRegister()
  self._mapIndex = {}
  self._mapUI = {}
  self._pageOrder = {}
end
function SettingPageMediator:OnViewComponentPagePreOpen(luaOpenData, nativeOpenData)
  self:InitView(luaOpenData)
end
function SettingPageMediator:InitView(luaOpenData)
  if nil ~= luaOpenData and type(luaOpenData) == "table" then
    self:InitPageOrder(luaOpenData.PageOrderParam)
    self:InitTabPanel(luaOpenData.bHideTab)
    self:InitTitleText(luaOpenData.SettingTitle)
  else
    self:InitPageOrder()
    self:InitTabPanel()
  end
  if self._tabPanel then
    local targetIndex = self:GetViewComponent():GetTargetIndex()
    self._tabPanel:SwitchTab(targetIndex)
  end
end
function SettingPageMediator:GetIndexByPageStr(pageStr)
  for i, v in ipairs(self._pageOrder) do
    if v == pageStr then
      return i
    end
  end
  return 1
end
function SettingPageMediator:InitPageOrder(PageOrderParam)
  local viewComponent = self.viewComponent
  if not viewComponent then
    return
  end
  local World = viewComponent:GetWorld()
  if not World then
    return
  end
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local pageOrder = {}
  local GameState = UGameplayStatics.GetGameState(World)
  local GameModeType = GameState and GameState.GetModeType and GameState:GetModeType() or EPMGameModeType.None
  if nil == PageOrderParam then
    if EPMGameModeType.NoviceGuide == GameModeType then
      pageOrder[#pageOrder + 1] = SettingEnum.PanelTypeStr.Sense
      pageOrder[#pageOrder + 1] = SettingEnum.PanelTypeStr.Visual
      pageOrder[#pageOrder + 1] = SettingEnum.PanelTypeStr.Sound
    else
      pageOrder[#pageOrder + 1] = SettingEnum.PanelTypeStr.Basic
      pageOrder[#pageOrder + 1] = SettingEnum.PanelTypeStr.Operate
      pageOrder[#pageOrder + 1] = SettingEnum.PanelTypeStr.Sense
      pageOrder[#pageOrder + 1] = SettingEnum.PanelTypeStr.CrossHair
      pageOrder[#pageOrder + 1] = SettingEnum.PanelTypeStr.Visual
      pageOrder[#pageOrder + 1] = SettingEnum.PanelTypeStr.Sound
    end
    self._pageOrder = pageOrder
  else
    for key, value in pairs(PageOrderParam) do
      if value then
        pageOrder[#pageOrder + 1] = value
      end
    end
    self._pageOrder = pageOrder
  end
end
function SettingPageMediator:InitTabPanel(HideTabParam)
  local args = {}
  local clickCallFunc = function(index, subIndex)
    self:ShowView(index, subIndex)
  end
  for i, v in ipairs(self._pageOrder) do
    args[#args + 1] = {text = v, callfunc = clickCallFunc}
  end
  local tabPanel = SettingHelper.CreateTabItemPanel(args)
  if tabPanel and HideTabParam then
    tabPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:GetViewComponent().CanvasPanel_TopItemList:AddChild(tabPanel)
  self._tabPanel = tabPanel
end
function SettingPageMediator:ShowView(index, subIndex)
  if self._mapIndex[index] == nil then
    self:InitSubPage(index, subIndex)
    self:GetViewComponent().WidgetSwitcher:SetActiveWidgetIndex(self._mapIndex[index])
  else
    self:GetViewComponent().WidgetSwitcher:SetActiveWidgetIndex(self._mapIndex[index])
    if nil ~= subIndex then
      GameFacade:SendNotification(NotificationDefines.Setting.SettingSubJumpPage, {
        subIndex = subIndex,
        pageName = self._pageOrder[index]
      })
    end
  end
  local pageText = self._pageOrder[index]
  local SettingManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingManagerProxy)
  SettingManagerProxy:SetCurPanelTypeStr(pageText)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingSwitchPageNtf)
end
function SettingPageMediator:InitSubPage(index, subIndex)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local pathCfg = SettingConfigProxy.pathCfg
  local pageText = self._pageOrder[index]
  local path = pathCfg[pageText]
  if type(path) == "table" and #path > 1 and pageText == SettingEnum.PanelTypeStr.Combat then
    local GameState = UE4.UGameplayStatics.GetGameState(self:GetViewComponent())
    if GameState:GetModeType() == UE4.EPMGameModeType.Spar then
      path = path[2]
    elseif GameState:GetModeType() == UE4.EPMGameModeType.Team then
      path = path[3]
    else
      path = path[1]
    end
  end
  local subPanel = SettingHelper.CreateSubPanel(path, {subIndex = subIndex})
  local widgetSwitcher = self:GetViewComponent().WidgetSwitcher
  widgetSwitcher:AddChild(subPanel)
  self._mapIndex[index] = widgetSwitcher:GetChildrenCount() - 1
  self._mapUI[index] = subPanel
end
function SettingPageMediator:InitTitleText(titleText)
  if nil ~= titleText and self:GetViewComponent() and self:GetViewComponent().Text_SettingTitle then
    self:GetViewComponent().Text_SettingTitle:SetText(titleText)
  end
end
function SettingPageMediator:OnRemove()
  self._mapIndex = {}
  self._mapUI = {}
  self._tabPanel = nil
  self:GetViewComponent().WidgetSwitcher:ClearChildren()
end
return SettingPageMediator
