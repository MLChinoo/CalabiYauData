local CrossHairSettingPanelPC = class("CrossHairSettingPanelPC", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local PanelTypeStr = SettingEnum.PanelTypeStr
function CrossHairSettingPanelPC:ListNeededMediators()
  return {}
end
function CrossHairSettingPanelPC:InitializeLuaEvent()
  local settingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local keyPanelStr = PanelTypeStr.CrossHair
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
return CrossHairSettingPanelPC
