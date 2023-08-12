local KaPhoneInputPanel = class("KaPhoneInputPanel", PureMVC.ViewComponentPanel)
local Collapsed = UE.ESlateVisibility.Collapsed
local Visible = UE.ESlateVisibility.Visible
local SelfHitTestInvisible = UE.ESlateVisibility.SelfHitTestInvisible
local Valid
function KaPhoneInputPanel:Construct()
  KaPhoneInputPanel.super.Construct(self)
end
function KaPhoneInputPanel:Destruct()
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  KaPhoneInputPanel.super.Destruct(self)
end
function KaPhoneInputPanel:UpdateInputInfo(TableRow, InContentIndex)
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  for idx, value in pairs(TableRow.OptionalJumpRowNameArray or {}) do
    local MsgItemPanel = self.DynamicEntryBox and self.DynamicEntryBox:BP_CreateEntry()
    Valid = MsgItemPanel and MsgItemPanel:Init(TableRow, idx, InContentIndex)
  end
end
function KaPhoneInputPanel:ShowInput(IsShow)
  self:SetVisibility(IsShow and SelfHitTestInvisible or Collapsed)
  Valid = IsShow and self.OpenAnim and self:PlayAnimationForward(self.OpenAnim, 1, false)
end
return KaPhoneInputPanel
