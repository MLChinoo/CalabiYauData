local ResultAccountAndRolePanel = class("ResultAccountAndRolePanel", PureMVC.ViewComponentPanel)
local ResultAccountAndRoleMediator = require("Business/BattleResult/Mediators/ResultAccountAndRoleMediator")
function ResultAccountAndRolePanel:ListNeededMediators()
  return {ResultAccountAndRoleMediator}
end
function ResultAccountAndRolePanel:Construct()
  ResultAccountAndRolePanel.super.Construct(self)
  LogDebug("ResultAccountAndRolePanel", "Construct")
end
function ResultAccountAndRolePanel:Destruct()
  ResultAccountAndRolePanel.super.Destruct(self)
end
function ResultAccountAndRolePanel:UpdateRole(ResultRoleDatas)
  LogDebug("ResultAccountAndRolePanel", "UpdateRole")
  self.ListView_Role:ClearChildren()
  for key, ResultRoleData in pairs(ResultRoleDatas) do
    local ResultRoleDataObject = {}
    ResultRoleDataObject.RoleData = ResultRoleData
    local ItemClass = ObjectUtil.LoadClass(self, self.ListItemClass)
    local ResultRolePanel_PC = UE4.UWidgetBlueprintLibrary.Create(self, ItemClass)
    self.ListView_Role:AddChild(ResultRolePanel_PC)
    ResultRolePanel_PC:OnListItemObjectSet(ResultRoleDataObject)
    local margin = UE4.FMargin()
    margin.Bottom = 30
    ResultRolePanel_PC.Slot:SetPadding(margin)
  end
end
function ResultAccountAndRolePanel:StopProgressAni()
  if self.WBP_ResultAcountPanel:IsProgressAniPlaying() then
    self.WBP_ResultAcountPanel:StopProgressAni()
  end
  local RolePanelArray = self.ListView_Role:GetAllChildren()
  for i = 1, RolePanelArray:Length() do
    local ResultRolePanel_PC = RolePanelArray:Get(i)
    if ResultRolePanel_PC:IsProgressAniPlaying() then
      ResultRolePanel_PC:StopProgressAni()
    end
  end
end
function ResultAccountAndRolePanel:IsProgressAniPlaying()
  local IsPlaying = self.WBP_ResultAcountPanel:IsProgressAniPlaying()
  local RolePanelArray = self.ListView_Role:GetAllChildren()
  for i = 1, RolePanelArray:Length() do
    local ResultRolePanel_PC = RolePanelArray:Get(i)
    IsPlaying = IsPlaying or ResultRolePanel_PC:IsProgressAniPlaying()
  end
  return IsPlaying
end
function ResultAccountAndRolePanel:GetProgressAniMaxTime()
  local MaxTime = self.WBP_ResultAcountPanel:GetProgressAniMaxTime()
  local RolePanelArray = self.ListView_Role:GetAllChildren()
  for i = 1, RolePanelArray:Length() do
    local ResultRolePanel_PC = RolePanelArray:Get(i)
    local Time = ResultRolePanel_PC:GetProgressAniMaxTime()
    if MaxTime < Time then
      MaxTime = Time
    end
  end
  return MaxTime
end
return ResultAccountAndRolePanel
