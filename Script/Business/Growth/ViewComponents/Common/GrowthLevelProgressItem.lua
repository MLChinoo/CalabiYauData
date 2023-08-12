local GrowthLevelProgressItem = class("GrowthLevelProgressItem", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function GrowthLevelProgressItem:UpdateItem(ItemData)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  self.SlotType = ItemData.SlotType
  self.Lv = ItemData.Lv
  local GrowthProxy = GameFacade:RetrieveProxy(ProxyNames.GrowthProxy)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleRow = roleProxy:GetRole(MyPlayerState.SelectRoleId)
  local CurrentLevel = GrowthProxy:GetGrowthLv(MyPlayerState, self.SlotType)
  local bSkillSlot = GrowthProxy:IsSkillSlot(self.SlotType)
  local SkillId, SkillRow
  if self.SlotType == UE4.EGrowthSlotType.QSkill then
    SkillId = RoleRow.SkillActive:Get(1)
  elseif self.SlotType == UE4.EGrowthSlotType.PassiveSkill then
    SkillId = RoleRow.SkillPassive:Get(1)
  elseif self.SlotType == UE4.EGrowthSlotType.Survive then
    SkillId = MyPlayerState.SelectRoleId * 10 + 7
  elseif self.SlotType == UE4.EGrowthSlotType.Shield then
    SkillId = MyPlayerState.SelectRoleId * 10 + 8
  end
  if SkillId then
    SkillRow = roleProxy:GetRoleSkill(SkillId)
    if not SkillRow then
      LogError("Get Skill Table Error", "SkillId=%s", SkillId)
    end
  end
  local Desc = ""
  if bSkillSlot or self.SlotType == UE4.EGrowthSlotType.Survive or self.SlotType == UE4.EGrowthSlotType.Shield then
    Desc = SkillRow["Intro" .. self.Lv]
  end
  self.Text_Desc:SetText(Desc)
  local bActive = CurrentLevel >= self.Lv
  self.WidgetSwitcher_Active:SetActiveWidgetIndex(bActive and 1 or 0)
  self.Text_Desc:SetColorAndOpacity(bActive and self.LinearColor_Active or self.LinearColor_UnActive)
end
return GrowthLevelProgressItem
