local GrowthDowngradeDialog = class("GrowthDowngradeDialog", PureMVC.ViewComponentPage)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
local GrowthPartMediator = require("Business/Growth/Mediators/GrowthPartMediator")
function GrowthDowngradeDialog:ListNeededMediators()
  return {GrowthPartMediator}
end
function GrowthDowngradeDialog:InitializeLuaEvent()
  GrowthDowngradeDialog.super.InitializeLuaEvent(self)
  self.OnRevertBtnClicked = LuaEvent.new()
end
function GrowthDowngradeDialog:OnShow(luaOpenData, nativeOpenData)
  self:PlayAnimation(self.OpenAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  self.SlotType = luaOpenData
  self.Btn_Cancel.OnClicked:Add(self, self.OnCancel)
  self.Btn_Confirm.OnClicked:Add(self, self.OnConfirm)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  self.PartData = {}
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleRow = roleProxy:GetRole(MyPlayerState.SelectRoleId)
  self.PartData.SlotType = self.SlotType
  self.PartData.bSkillSlot = GrowthProxy:IsSkillSlot(self.SlotType)
  if self.SlotType == UE4.EGrowthSlotType.QSkill then
    self.PartData.SkillId = RoleRow.SkillActive:Get(1)
  elseif self.SlotType == UE4.EGrowthSlotType.PassiveSkill then
    self.PartData.SkillId = RoleRow.SkillPassive:Get(1)
  elseif self.SlotType == UE4.EGrowthSlotType.Survive then
    self.PartData.SkillId = MyPlayerState.SelectRoleId * 10 + 7
  elseif self.SlotType == UE4.EGrowthSlotType.Shield then
    self.PartData.SkillId = MyPlayerState.SelectRoleId * 10 + 8
  end
  if self.PartData.SkillId then
    self.PartData.SkillRow = roleProxy:GetRoleSkill(self.PartData.SkillId)
    if not self.PartData.SkillRow then
      LogError("Get Skill Table Error", "SkillId=%s", self.PartData.SkillId)
    end
  end
  local Tips1 = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "GrowthDowngradeTips1")
  local Tips2 = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "GrowthDowngradeTips2")
  local Tips3 = ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "GrowthDowngradeTips3")
  local PartName = ""
  if self.PartData.SkillRow then
    PartName = self.PartData.SkillRow.Name
  else
    PartName = GrowthProxy:GetGrowthPartSlotName(MyPlayerState.SelectRoleId, self.SlotType)
  end
  self.PartData.CurrentLevel = GrowthProxy:GetGrowthLv(MyPlayerState, self.SlotType)
  self.PartData.CurrentLevel = self.PartData.CurrentLevel and self.PartData.CurrentLevel or 0
  self.PartData.UpgradeCost = GrowthProxy:GetGrowthSlotCost(MyPlayerState.SelectRoleId, self.SlotType, self.PartData.CurrentLevel)
  local GrowthTableRow = GrowthProxy:GetGrowthRow(MyPlayerState.SelectRoleId)
  local growth = self.PartData.UpgradeCost * (1 - GrowthTableRow.DowngradeCost)
  self.RichText_Tips:SetText(string.format("%s <NameText>%s</> %s%s%s", Tips1, PartName, Tips2, math.floor(growth), Tips3))
end
function GrowthDowngradeDialog:OnClose()
  self.Btn_Cancel.OnClicked:Remove(self, self.OnCancel)
  self.Btn_Confirm.OnClicked:Remove(self, self.OnConfirm)
end
function GrowthDowngradeDialog:OnCancel()
  self:K2_PostAkEvent(self.AK_Map:Find("Btn"), false)
  ViewMgr:HidePage(self, UIPageNameDefine.GrowthDowngradeDialog)
end
function GrowthDowngradeDialog:OnConfirm()
  self.OnRevertBtnClicked(self.SlotType, false)
  ViewMgr:HidePage(self, UIPageNameDefine.GrowthDowngradeDialog)
end
function GrowthDowngradeDialog:LuaHandleKeyEvent(key, inputEvent)
  GamePlayGlobal:LuaHandleKeyEvent(self, key, inputEvent)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return false
  end
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName("Growth", arr)
  local keyNames = {}
  for i = 1, arr:Length() do
    local ele = arr:Get(i)
    if ele then
      table.insert(keyNames, UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key))
    end
  end
  local inputKeyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == inputKeyName or table.index(keyNames, inputKeyName) then
    ViewMgr:HidePage(self, UIPageNameDefine.GrowthPage)
    ViewMgr:HidePage(self, UIPageNameDefine.GrowthDowngradeDialog)
    return true
  end
  return false
end
return GrowthDowngradeDialog
