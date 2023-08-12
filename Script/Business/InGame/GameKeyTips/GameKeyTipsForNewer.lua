local GameKeyTipsForNewer = class("GameKeyTipsForNewer", PureMVC.ViewComponentPanel)
local GameKeyTipsForNewerMediator = require("Business/InGame/GameKeyTips/GameKeyTipsForNewerMediator")
function GameKeyTipsForNewer:ListNeededMediators()
  return {GameKeyTipsForNewerMediator}
end
function GameKeyTipsForNewer:Construct()
  GameKeyTipsForNewer.super.Construct(self)
  if self.IsOnlyASpectator and self:IsOnlyASpectator() then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  self:UpdateVisible()
  if not GameState then
    return
  end
  self:UpdateKey()
  self.OnRoundStageUpdateHandle = DelegateMgr:AddDelegate(GameState.OnNotifyRoundStateChange, self, "OnRoundStageUpdate")
end
function GameKeyTipsForNewer:Destruct()
  GameKeyTipsForNewer.super.Destruct(self)
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState then
    return
  end
  if self.OnRoundStageUpdateHandle then
    DelegateMgr:RemoveDelegate(GameState.OnNotifyRoundStateChange, self.OnRoundStageUpdateHandle)
    self.OnRoundStageUpdateHandle = nil
  end
end
function GameKeyTipsForNewer:OnRoundStageUpdate()
  self:UpdateVisible()
end
function GameKeyTipsForNewer:UpdateVisible()
  self.Border_Tips:SetVisibility(UE4.ESlateVisibility.Hidden)
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState then
    return
  end
  local playerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  if playerAttrProxy then
    local level = playerAttrProxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emLevel)
    if level and level > 0 and level < 3 and GameState:GetRoundState() <= UE4.ERoundStage.Freeze then
      self.Border_Tips:SetVisibility(UE4.ESlateVisibility.Visible)
      self:UpdateKey()
    end
  end
end
function GameKeyTipsForNewer:UpdateKey()
  local InputName = "GameKeyTips"
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName(InputName, arr)
  local ele = arr:Get(1)
  if ele then
    self.Txt_Key:SetText(UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key))
  end
end
return GameKeyTipsForNewer
