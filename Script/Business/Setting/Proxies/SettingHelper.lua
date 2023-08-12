local SettingHelper = {}
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingStoreMap = require("Business/Setting/Proxies/Map/SettingStoreMap")
local PanelTypeStr = SettingEnum.PanelTypeStr
local ItemType = SettingEnum.ItemType
local CreateItem = function(itemPath, args, extras)
  local itemClass = UE4.UClass.Load(itemPath)
  if itemClass:IsValid() then
    local item = UE4.UWidgetBlueprintLibrary.Create(LuaGetWorld(), itemClass)
    if item.InitView then
      item:InitView(args, extras)
    end
    return item
  end
end
local DetailItemPath, SliderItemPath, SwitcherItemPath, OperateItemPath, SliderWithCheckItemPath, TitleItemPath, sliderItemPath, BgItemPath, ItemListPanelPath, TabItemPanelPath, SubTabItemPath, TabItemPath, DescItemPath, ButtonItemPath, ShapedScreenItemPath, NormalButtonPath, SettingVoiceConfigPath
local SoftToString = function(page, index)
  if page.ItemClassArray:IsValidIndex(index) then
    return UE4.UKismetSystemLibrary.Conv_SoftClassReferenceToString(page.ItemClassArray:Get(index))
  end
  return nil
end
function SettingHelper.InitCfgPath(page)
  if page.ItemClassArray == nil then
    return
  end
  if nil == BgItemPath then
    BgItemPath = SoftToString(page, 3)
    SubTabItemPath = SoftToString(page, 4)
    TabItemPath = SoftToString(page, 6)
    TitleItemPath = SoftToString(page, 7)
    OperateItemPath = SoftToString(page, 8)
    SliderItemPath = SoftToString(page, 9)
    SliderWithCheckItemPath = SoftToString(page, 10)
    SwitcherItemPath = SoftToString(page, 11)
    ItemListPanelPath = SoftToString(page, 16)
    TabItemPanelPath = SoftToString(page, 17)
    DescItemPath = SoftToString(page, 20)
    ButtonItemPath = SoftToString(page, 21)
    ShapedScreenItemPath = SoftToString(page, 23)
    NormalButtonPath = SoftToString(page, 24)
    SettingVoiceConfigPath = SoftToString(page, 26)
  end
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  if SettingConfigProxy and nil == SettingConfigProxy.pathCfg then
    local tabCfg = {
      [PanelTypeStr.Basic] = SoftToString(page, 12),
      [PanelTypeStr.Operate] = SoftToString(page, 14),
      [PanelTypeStr.Sense] = SoftToString(page, 15),
      [PanelTypeStr.Visual] = SoftToString(page, 19),
      [PanelTypeStr.Sound] = SoftToString(page, 18),
      [PanelTypeStr.Combat] = {
        SoftToString(page, 13),
        SoftToString(page, 27),
        SoftToString(page, 28)
      },
      [PanelTypeStr.CrossHair] = SoftToString(page, 22),
      [PanelTypeStr.Account] = SoftToString(page, 25)
    }
    SettingConfigProxy:InitTabCfg(tabCfg)
  end
end
function SettingHelper.InitMBCfgPath(page)
  SettingHelper.InitCfgPath(page)
end
function SettingHelper.CreateSliderItem(args)
  return CreateItem(SliderItemPath, args)
end
function SettingHelper.CreateSwitchItem(args)
  return CreateItem(SwitcherItemPath, args)
end
function SettingHelper.CreateOperateItem(args)
  return CreateItem(OperateItemPath, args)
end
function SettingHelper.CreateSliderItemWithCheck(args)
  return CreateItem(SliderWithCheckItemPath, args)
end
function SettingHelper.CreateTitleItem(args)
  return CreateItem(TitleItemPath, args)
end
function SettingHelper.CreateBgItem()
  return CreateItem(BgItemPath)
end
function SettingHelper.CreateItemListPanel(args)
  return CreateItem(ItemListPanelPath, args)
end
function SettingHelper.CreateSubPanel(classPath, subIndex)
  return CreateItem(classPath, subIndex)
end
function SettingHelper.CreateTabItemPanel(args, extras)
  return CreateItem(TabItemPanelPath, args, extras)
end
function SettingHelper.CreateTabItem(args)
  return CreateItem(TabItemPath, args)
end
function SettingHelper.CreateSubTabItem(args)
  return CreateItem(SubTabItemPath, args)
end
function SettingHelper.CreateInteractItem(args)
  LogInfo("SettingHelper", "UIType" .. args.UiType)
  local item
  local bWithBg = true
  if args.UiType == ItemType.CustomItem then
    if args.indexKey == "VoucherJump" then
      item = CreateItem(NormalButtonPath, args)
    elseif args.indexKey == "SpecialShapedAdaption" then
      item = CreateItem(ShapedScreenItemPath, args)
    elseif args.indexKey == "SwitchTeamChatDesc" then
      bWithBg = false
      item = CreateItem(DescItemPath, args)
    elseif args.indexKey == "SwitchTeamChatJump" then
      bWithBg = false
      item = CreateItem(ButtonItemPath, args)
    elseif args.indexKey == "VoiceInputModeDesc" then
      bWithBg = false
      item = CreateItem(DescItemPath, args)
    elseif args.indexKey == "WindowVoiceConfigDesc" then
      item = CreateItem(SettingVoiceConfigPath, args)
    end
  elseif args.UiType == ItemType.SwitchItem then
    item = SettingHelper.CreateSwitchItem(args)
  elseif args.UiType == ItemType.SliderItem then
    item = SettingHelper.CreateSliderItem(args)
  elseif args.UiType == ItemType.SliderItemWithCheck then
    item = SettingHelper.CreateSliderItemWithCheck(args)
  elseif args.UiType == ItemType.OperateItem then
    item = SettingHelper.CreateOperateItem(args)
  end
  if bWithBg then
    local bgItem = SettingHelper.CreateBgItem()
    bgItem:AddChild(item)
    return bgItem
  else
    return item
  end
end
function SettingHelper.IsVolume(oriData)
  if nil == oriData then
    return false
  end
  local volumeArr = {
    "Volume",
    "MusicVolume",
    "UIVolume",
    "GameVolume",
    "CharacterVoice",
    "MicrophoneVolume",
    "VoiceChatVolume"
  }
  for i, v in ipairs(volumeArr) do
    if v == oriData.indexKey then
      return true
    end
  end
  return false
end
function SettingHelper.IsBrightNess(oriData)
  return oriData.indexKey == "ScreenBrightness"
end
function SettingHelper.IsCrossHair(oriData)
  return oriData.type == PanelTypeStr.CrossHair
end
function SettingHelper.DirectAdjustMap(oriData, currentValue, bInit)
  if SettingHelper.IsVolume(oriData) then
    local SettingProxy = GameFacade:RetrieveProxy(ProxyNames.SettingProxy)
    SettingProxy:SetVolume(oriData, math.floor(currentValue / SettingEnum.Multipler))
  elseif SettingHelper.IsBrightNess(oriData) then
    local SettingProxy = GameFacade:RetrieveProxy(ProxyNames.SettingProxy)
    SettingProxy:ApplyBrightnessChanged(currentValue / SettingEnum.Multipler)
  elseif SettingHelper.IsCrossHair(oriData) then
    GameFacade:SendNotification(NotificationDefines.Setting.SettingValueChangeNtf, {oriData = oriData, value = currentValue})
  else
    local SettingSensitivityProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSensitivityProxy)
    if SettingSensitivityProxy:IsMBSensitivity(oriData.indexKey) and not bInit then
      SettingSensitivityProxy:ChangeGlobalSensivity(oriData.indexKey, currentValue)
    end
  end
end
function SettingHelper.IsVisualAttribute(oriData)
  if oriData and oriData.Type == PanelTypeStr.Visual then
    return true
  end
  return false
end
function SettingHelper.FilterVisualAttribute(setting_list)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local ret = {}
  for i, v in ipairs(setting_list) do
    local oriData = SettingConfigProxy:GetOriDataBySaveKey(v.key)
    if nil == oriData or SettingHelper.IsVisualAttribute(oriData) == false then
      ret[#ret + 1] = v
    end
  end
  return ret
end
function SettingHelper.FilterLocalAttribute(setting_list)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local ret = {}
  for i, v in ipairs(setting_list) do
    local oriData = SettingConfigProxy:GetOriDataBySaveKey(v.key)
    if nil == oriData or oriData.indexKey ~= "VoiceInputDevice" and oriData.indexKey ~= "VoiceOutputDevice" then
      ret[#ret + 1] = v
    end
  end
  return ret
end
function SettingHelper.FilterServerNotSaveAttribute(setting_list)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local ret = {}
  for i, v in ipairs(setting_list) do
    local oriData = SettingConfigProxy:GetOriDataBySaveKey(v.key)
    if nil == oriData or SettingHelper.CheckApplyServerStatus(oriData.status) == true then
      ret[#ret + 1] = v
    end
  end
  return ret
end
function SettingHelper.FixVoluemAttribute(setting_list)
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local defaultData = SettingSaveDataProxy:GetDefaultData()
  local settingMap = {}
  for i, v in ipairs(setting_list) do
    settingMap[v.key] = v.value
  end
  for indexKey, v in pairs(defaultData) do
    local oriData = SettingConfigProxy:GetOriDataByIndexKey(indexKey)
    local key = SettingStoreMap.indexKeyToSaveKey[indexKey]
    if oriData and SettingHelper.IsVolume(oriData) == true and key and nil == settingMap[key] then
      setting_list[#setting_list + 1] = {
        key = SettingStoreMap.indexKeyToSaveKey[indexKey],
        value = v
      }
    end
  end
  return setting_list
end
function SettingHelper.PrintSettingList(setting_list)
  LogInfo("SettingHelper", "PrintSettingList")
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  for i, v in ipairs(setting_list) do
    local oriData = SettingConfigProxy:GetOriDataBySaveKey(v.key)
    if oriData then
      print(oriData.indexKey, v.value, v.key)
    end
  end
end
function SettingHelper.CheckSwitchIsOn(value)
  return SettingHelper.CheckLuaValueIsSameAsCPPValue(value, UE4.ESwitch.ES_ON)
end
function SettingHelper.IsTeamChatOpen()
  local SettingSaveDataProxy = GameFacade:RetrieveProxy(ProxyNames.SettingSaveDataProxy)
  local value = SettingSaveDataProxy:GetCurrentValueByKey("Switch_TeamChat")
  return SettingHelper.CheckSwitchIsOn(value)
end
function SettingHelper.IsVisualAndSaveAttribute(oriData)
  if SettingHelper.IsVisualAttribute(oriData) then
    local indexKeyMap = {ScreenMode = false, Resolution = false}
    if false == indexKeyMap[oriData.indexKey] then
      return false
    else
      return true
    end
  elseif oriData.indexKey == "CvStyle" then
    return true
  end
  return false
end
local GraphicQualityMap = {
  TextureQuality = true,
  MaterialQuality = true,
  TextureStreamingSpeedQuality = true,
  TextureSamplerQuality = true,
  BloomQuality = true,
  LensFlareQuality = true,
  SSAOQuality = true,
  SSRQuality = true,
  EffectQuality = true,
  AntiAliasingQuality = true,
  TonemapperQuality = true,
  RefractionQuality = true,
  FogQuality = true,
  ShadowQuality = true,
  SkyAtmoSphereQuality = true,
  RenderMode = true,
  ModelDetailQuality = true
}
function SettingHelper.CheckIsGraphicQuality(indexKey, b)
  if GraphicQualityMap[indexKey] then
    return true
  end
  return false
end
function SettingHelper.GetGraphicQualityMap()
  return GraphicQualityMap
end
function SettingHelper.CheckHideStatus(status)
  if status == SettingEnum.Status.Hide or status == SettingEnum.Status.NotUse then
    return true
  end
  return false
end
function SettingHelper.CheckApplyServerStatus(status)
  if status == SettingEnum.Status.Default then
    return true
  end
  return false
end
function SettingHelper.CheckApplyDefaultStatus(status)
  if status == SettingEnum.Status.Default or status == SettingEnum.Status.Hide then
    return true
  end
  return false
end
function SettingHelper.GetKeyMapType(oriData)
  if oriData and oriData.indexKey then
    local indexKey = oriData.indexKey
    if "ViewNextPlayer" == indexKey or "ViewPrevPlayer" == indexKey or "FreeView" == indexKey or "AroundViewPlayer" == indexKey or "HideAllPlayerOverheadInfo" == indexKey then
      return SettingEnum.KeyMapType.Spectators
    end
  end
  return SettingEnum.KeyMapType.Normal
end
function SettingHelper.GetScreenModeType(screenMode, bSetting)
  if bSetting then
    if screenMode == SettingEnum.WindowType.ShowFullScreen then
      return UE4.EScreenMode.WindowedFullscreen
    elseif screenMode == SettingEnum.WindowType.ShowWindowed then
      return UE4.EScreenMode.Windowed
    else
      return UE4.EScreenMode.WindowedFullscreen
    end
  elseif screenMode == UE4.EScreenMode.WindowedFullscreen then
    return SettingEnum.WindowType.ShowFullScreen
  elseif screenMode == UE4.EScreenMode.Windowed then
    return SettingEnum.WindowType.ShowWindowed
  else
    return SettingEnum.WindowType.ShowFullScreen
  end
end
function SettingHelper.GetShowStep(Step)
  if Step % 10 > 0 then
    return 3
  elseif Step % 100 > 0 then
    return 2
  elseif Step % 1000 > 0 then
    return 1
  else
    return 0
  end
end
function SettingHelper.CheckLuaValueIsSameAsCPPValue(luaValue, cppValue)
  return luaValue == cppValue + 1
end
function SettingHelper.GetCPPValueByLuaValue(luaValue)
  return luaValue - 1
end
function SettingHelper.GetLuaValueByCPPValue(cppValue)
  return cppValue + 1
end
return SettingHelper
