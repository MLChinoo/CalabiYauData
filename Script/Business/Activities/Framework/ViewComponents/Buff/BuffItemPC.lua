local BuffItemPC = class("BuffItemPC", PureMVC.ViewComponentPanel)
function BuffItemPC:OnMouseEnter()
  LogInfo("BuffItemPC", "ShowMouseEnter")
  self.CanvasPanel_Tip:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function BuffItemPC:OnMouseLeave()
  LogInfo("BuffItemPC", "ShowMouseLeave")
  self.CanvasPanel_Tip:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function BuffItemPC:SetContent(expTxt)
  self.TextBlock_Exp:SetText(expTxt)
end
function BuffItemPC:SetRestTime(restTimeText)
  self.TextBlock_RestTime:SetText(restTimeText)
end
function BuffItemPC:RefreshContentAndRestTime(expTxt, restTimeText)
  self:SetContent(expTxt)
  self:SetRestTime(restTimeText)
  local a = UE4.UPMLuaBridgeBlueprintLibrary.GetTextBlockSize(self.TextBlock_Exp)
  local b = UE4.UPMLuaBridgeBlueprintLibrary.GetTextBlockSize(self.TextBlock_RestTime)
  local size = self.Image_133.Slot:GetSize()
  local t = a.X > b.X and a.X or b.X
  self.Image_133.Slot:SetSize(UE4.FVector2D(t + 20, size.Y))
end
function BuffItemPC:RefreshPrivilegeCfg(barInfo)
  self:SetContent(barInfo)
  self:SetRestTime("")
  local s = UE4.UPMLuaBridgeBlueprintLibrary.GetTextBlockSize(self.TextBlock_Exp)
  self.Image_133.Slot:SetSize(UE4.FVector2D(s.X + 20, s.Y + 25))
end
function BuffItemPC:SetBrush(brushImage)
  self.Image_Icon:SetBrush(brushImage)
end
return BuffItemPC
