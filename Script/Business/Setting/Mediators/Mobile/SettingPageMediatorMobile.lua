local SettingPageMediatorMobile = class("SettingPageMediatorMobile", PureMVC.Mediator)
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local UGameplayStatics = UE4.UGameplayStatics
local EPMGameModeType = UE4.EPMGameModeType
local TabStyle = SettingEnum.TabStyle
local PanelTypeStr = SettingEnum.PanelTypeStr
function SettingPageMediatorMobile:OnRegister()
  self.super:OnRegister()
  self._mapIndex = {}
  self._mapUI = {}
  if self:GetViewComponent().NavigationBar then
    self:GetViewComponent().NavigationBar.OnItemCheckEvent:Add(self.OnNavigationBarClick, self)
  end
  local World = self:GetViewComponent():GetWorld()
  local GameState = World and UGameplayStatics.GetGameState(World) or nil
  local GameModeType = GameState and GameState.GetModeType and GameState:GetModeType() or EPMGameModeType.None
  local FunctionMobileType = UE4.ECYFunctionMobileTypes.Setting
  if EPMGameModeType.NoviceGuide == GameModeType then
    FunctionMobileType = UE4.ECYFunctionMobileTypes.NoviceGuideSetting
  end
  self:GenerateNavbar(FunctionMobileType)
  self:InitView()
end
function SettingPageMediatorMobile:OnNavigationBarClick(index)
  self:DoNavigationBarClick(index)
end
function SettingPageMediatorMobile:InitView()
  local targetIndex = self:GetViewComponent():GetTargetIndex()
  self:DoNavigationBarClick(targetIndex)
end
function SettingPageMediatorMobile:DoNavigationBarClick(index)
  self.curButtonIndex = index
  local data = self._datas[index]
  if self._mapIndex[index] == nil then
    local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
    local pathCfg = SettingConfigProxy.pathCfg
    local pageText = data.barName
    local path = pathCfg[pageText]
    if type(path) == "table" then
      path = path[1]
    end
    local subPanel = SettingHelper.CreateSubPanel(path)
    local widgetSwitcher = self:GetViewComponent().WidgetSwitcher
    widgetSwitcher:AddChild(subPanel)
    self._mapIndex[index] = widgetSwitcher:GetChildrenCount() - 1
    self._mapUI[index] = subPanel
  end
  local SettingManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingManagerProxy)
  SettingManagerProxy:SetCurPanelTypeStr(data.barName)
  self:GetViewComponent().WidgetSwitcher:SetActiveWidgetIndex(self._mapIndex[index])
  self:GetViewComponent().NavigationBar:SetBarCheckStateByCustomType(data.customType)
  GameFacade:SendNotification(NotificationDefines.Setting.SettingSwitchPageNtf)
  self:GetViewComponent().WBP_CommonReturnButton_Mobile:SetButtonName(data.barName)
end
function SettingPageMediatorMobile:GenerateNavbar(barType, selectIndex)
  local proxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  if not proxy then
    return
  end
  local funcTableRow = proxy:GetFunctionMobileById(barType)
  if not funcTableRow then
    return
  end
  local subFuncLen = funcTableRow.SubFunction:Length()
  if subFuncLen > 0 then
    local datas = {}
    self.curButtonIndex = selectIndex
    for index = 1, subFuncLen do
      local subFuncTableRow = proxy:GetFunctionMobileById(funcTableRow.SubFunction:Get(index))
      if subFuncTableRow then
        local data = {}
        data.barIcon = subFuncTableRow.IconItem
        data.barName = subFuncTableRow.Name
        data.customType = index
        datas[index] = data
      end
    end
    self:GetViewComponent().NavigationBar:UpdateBar(datas)
    self._datas = datas
  end
end
function SettingPageMediatorMobile:OnRemove()
  self._mapIndex = {}
  self._mapUI = {}
end
return SettingPageMediatorMobile
