local SettingManagerProxy = class("SettingManagerProxy", PureMVC.Proxy)
function SettingManagerProxy:OnRegister()
  SettingManagerProxy.super.OnRegister(self)
  self:OnInit()
end
function SettingManagerProxy:OnInit()
  local SettingSaveGameProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveGameProxy)
  SettingSaveGameProxy:PreInit()
  local SettingVisualProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVisualProxy)
  SettingVisualProxy:OnInit()
  local SettingVoiceProxy = GameFacade:RetrieveProxy(ProxyNames.SettingVoiceProxy)
  SettingVoiceProxy:OnInit()
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  SettingConfigProxy:OnInit()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  SettingSaveDataProxy:OnInit()
  local SettingSensitivityProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSensitivityProxy)
  SettingSensitivityProxy:OnInit()
  SettingSaveGameProxy:OnInit()
  local SettingOperationProxy = GameFacade:RetrieveProxy(ProxyNames.SettingOperationProxy)
  SettingOperationProxy:OnInit()
  self._showPanelMap = {}
end
function SettingManagerProxy:OnRemove()
  SettingManagerProxy.super.OnRemove(self)
  self:OnDestory()
end
function SettingManagerProxy:OnDestory()
end
function SettingManagerProxy:InitTemplateDataWithOpen()
  self._curPanelType = nil
  local SettingKeyMapManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingKeyMapManagerProxy)
  SettingKeyMapManagerProxy:InitKeyMap()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  SettingSaveDataProxy:ClearTemplateData()
end
function SettingManagerProxy:DestoryTemplateDataWithClose()
  self._curPanelType = nil
  self._showPanelMap = {}
  local SettingKeyMapManagerProxy = GameFacade:RetrieveProxy(ProxyNames.SettingKeyMapManagerProxy)
  SettingKeyMapManagerProxy:ClearKeyMap()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  SettingSaveDataProxy:ClearTemplateData()
end
function SettingManagerProxy:SetCurPanelTypeStr(curPanelTypeStr)
  self._curPanelTypeStr = curPanelTypeStr
  self._showPanelMap[curPanelTypeStr] = true
end
function SettingManagerProxy:GetCurPanelTypeStr()
  return self._curPanelTypeStr
end
function SettingManagerProxy:GetCurPanelStr()
  return self._curPanelTypeStr
end
function SettingManagerProxy:CheckPanelShowed(panelTypeStr)
  return self._showPanelMap[panelTypeStr] == true
end
return SettingManagerProxy
