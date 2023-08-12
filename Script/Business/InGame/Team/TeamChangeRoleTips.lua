local TeamChangeRoleTips = class("TeamChangeRoleTips", PureMVC.ViewComponentPanel)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function TeamChangeRoleTips:Construct()
  TeamChangeRoleTips.super.Construct(self)
  self.Border_Tips:SetVisibility(UE4.ESlateVisibility.Hidden)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if not self.TipOpen then
    self.OnChangeRoleSelectHandle = DelegateMgr:AddDelegate(MyPlayerController.OnPMPlayerState_StartRoleSelect, self, "OnChangeRoleSelect")
    self.Switch_Desc:SetActiveWidgetIndex(1)
  else
    self.Switch_Desc:SetActiveWidgetIndex(0)
  end
end
function TeamChangeRoleTips:Destruct()
  TeamChangeRoleTips.super.Destruct(self)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  if self.OnChangeRoleSelectHandle then
    DelegateMgr:RemoveDelegate(MyPlayerController.OnPMPlayerState_StartRoleSelect, self.OnChangeRoleSelect)
    self.OnChangeRoleSelectHandle = nil
  end
end
function TeamChangeRoleTips:OnChangeRoleSelect(bStart)
  if bStart then
    self.Border_Tips:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function TeamChangeRoleTips:Tick()
  if self.TipOpen then
    self:UpdateVisible()
  end
end
function TeamChangeRoleTips:UpdateVisible()
  self.Border_Tips:SetVisibility(UE4.ESlateVisibility.Hidden)
  local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
  if not (GameState and MyPlayerController) or not MyPlayerState then
    return
  end
  local CurrentTime = GameState:GetServerWorldTimeSeconds()
  local LastDeathTime = MyPlayerState.LastDeathTime
  if not CurrentTime or not LastDeathTime then
    return
  end
  local DurationTime = CurrentTime - LastDeathTime
  local MinRespawnDelay = GameState.MinRespawnDelay
  if MinRespawnDelay and MinRespawnDelay > 0 then
    if DurationTime < MinRespawnDelay then
      self.Border_Tips:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.Border_Tips:SetVisibility(UE4.ESlateVisibility.Hidden)
    end
  end
end
function TeamChangeRoleTips:UpdateKey()
  local InputName = "GameKeyTips"
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName(InputName, arr)
  local ele = arr:Get(1)
  if ele then
    self.Txt_Key:SetText(UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key))
  end
end
return TeamChangeRoleTips
