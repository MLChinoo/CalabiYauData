local SenseSettingPanelPC = class("SenseSettingPanelPC", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local PanelTypeStr = SettingEnum.PanelTypeStr
function SenseSettingPanelPC:ListNeededMediators()
  return {}
end
function SenseSettingPanelPC:InitializeLuaEvent()
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local subTypeMap, titleTypeMap, allItemMap = SettingConfigProxy:GetDataByPanelStr(PanelTypeStr.Sense)
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
return SenseSettingPanelPC
