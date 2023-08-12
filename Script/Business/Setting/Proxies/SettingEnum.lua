local SettingEnum = {}
SettingEnum.PanelTypeStr = {
  Basic = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "19"),
  Operate = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "20"),
  Sense = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "21"),
  Visual = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "22"),
  Sound = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "23"),
  Combat = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "18"),
  CrossHair = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "24"),
  Account = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "32")
}
SettingEnum.OperateSubPanelTypeStr = {
  Action = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "25"),
  Fight = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "26"),
  Communicate = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "27"),
  UI = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "28")
}
SettingEnum.ItemType = {
  CustomItem = 0,
  SliderItem = 1,
  SliderItemWithCheck = 2,
  SwitchItem = 3,
  OperateItem = 4
}
SettingEnum.TabStyle = {
  Left = 0,
  Middle = 1,
  Right = 2
}
SettingEnum.Multipler = 1000
SettingEnum.CombatTitle = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "18")
SettingEnum.Invalid = "Invalid"
SettingEnum.SaveStatus = {
  SaveToCurrent = 1,
  SaveToCPP = 2,
  SaveToApplyChange = 3
}
SettingEnum.GraphicCustomIndex = 6
SettingEnum.Status = {
  Default = 0,
  Hide = 1,
  NotUse = 2
}
SettingEnum.KeyMapType = {Normal = 1, Spectators = 2}
SettingEnum.WindowType = {ShowFullScreen = 1, ShowWindowed = 2}
SettingEnum.NoDevice = ConfigMgr:FromStringTable(StringTablePath.ST_Setting, "35")
SettingEnum.PerformaceMode = {
  Normal = 1,
  FrameRate = 2,
  Efficient = 3
}
return SettingEnum
