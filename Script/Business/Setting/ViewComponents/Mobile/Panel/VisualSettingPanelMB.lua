local VisualSettingPanelMB = class("VisualSettingPanelMB", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local PanelTypeStr = SettingEnum.PanelTypeStr
function VisualSettingPanelMB:ListNeededMediators()
  return {}
end
function VisualSettingPanelMB:InitializeLuaEvent()
  local settingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local keyPanelStr = PanelTypeStr.Visual
  local subTypeMap, titleTypeMap, allItemMap = settingConfigProxy:GetDataByPanelStr(keyPanelStr)
  if 1 == #subTypeMap then
    local subTypeStr = subTypeMap[1]
    local args = {
      itemList = allItemMap[subTypeStr],
      titleList = titleTypeMap[subTypeStr]
    }
    local itemlistPanel = SettingHelper.CreateItemListPanel(args)
    self.SizeBox_ShowItem:AddChild(itemlistPanel)
  end
end
return VisualSettingPanelMB
