local ModePage = class("ModePage", PureMVC.ViewComponentPage)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ModePage:OnOpen()
  self:CreateModePanel()
end
function ModePage:CreateModePanel()
  if self.ModePanel then
    return
  end
  local GameState = UE4.UGameplayStatics.GetGameState(self)
  if not GameState or not GameState.GetModeType then
    return
  end
  local ModePanelSoftClass = self.ModePanelMap:Find(GameState:GetModeType())
  ModePanelSoftClass = ModePanelSoftClass or self.ModePanelMap:Find(UE4.EPMGameModeType.Team)
  local ModePanelClass = ObjectUtil:LoadClass(ModePanelSoftClass)
  if ModePanelClass then
    GamePlayGlobal:CreateWidget(self, ModePanelClass, 1, function(ModePanel)
      if not ModePanel then
        ViewMgr:ClosePage(self, self.PageName)
        return
      end
      self.ModePanel = ModePanel
      self.CanvasPanel_Mode:AddChild(self.ModePanel)
      local Layout = self.ModePanel.Slot:GetLayout()
      Layout.Offsets.Bottom = 0
      Layout.Offsets.Left = 0
      Layout.Offsets.Top = 0
      Layout.Offsets.Right = 0
      Layout.Anchors.Minimum = UE4.FVector2D(0, 0)
      Layout.Anchors.Maximum = UE4.FVector2D(1, 1)
      self.ModePanel.Slot:SetLayout(Layout)
    end)
  end
end
return ModePage
