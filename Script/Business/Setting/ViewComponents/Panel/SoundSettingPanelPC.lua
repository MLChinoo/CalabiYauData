local SoundSettingPanelPC = class("SoundSettingPanelPC", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local PanelTypeStr = SettingEnum.PanelTypeStr
function SoundSettingPanelPC:ListNeededMediators()
  return {}
end
function SoundSettingPanelPC:InitializeLuaEvent()
  local settingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local subTypeMap, titleTypeMap, allItemMap = settingConfigProxy:GetDataByPanelStr(PanelTypeStr.Sound)
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
return SoundSettingPanelPC
