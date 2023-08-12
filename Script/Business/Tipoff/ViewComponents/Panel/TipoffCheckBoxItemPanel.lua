local TipoffPlayerMediator = require("Business/Tipoff/Mediators/TipoffPlayerMediator")
local TipoffCheckBoxItemPanel = class("TipoffCheckBoxItemPanel", PureMVC.ViewComponentPanel)
function TipoffCheckBoxItemPanel:Construct()
  TipoffCheckBoxItemPanel.super.Construct(self)
  if self.CheckBox_Slider then
    self.CheckBox_Slider.OnCheckStateChanged:Add(self, self.OnHandleChangeCheckBox)
  end
end
function TipoffCheckBoxItemPanel:Destruct()
  TipoffCheckBoxItemPanel.super.Destruct(self)
  if self.CheckBox_Slider then
    self.CheckBox_Slider.OnCheckStateChanged:Remove(self, self.OnHandleChangeCheckBox)
  end
end
function TipoffCheckBoxItemPanel:OnHandleChangeCheckBox(bChoose)
  local Data = {
    ReasonType = self.CachedReasonData.ReasonType,
    bChoose = bChoose
  }
  GameFacade:SendNotification(NotificationDefines.TipoffPlayer.TipoffBehaviorChooseCmd, Data)
end
function TipoffCheckBoxItemPanel:InitView(TipoffReasonData)
  if not TipoffReasonData then
    return
  end
  self.CachedReasonData = TipoffReasonData
end
function TipoffCheckBoxItemPanel:UpdateItemView(TipOffBehaviorDataRow)
  if not self.CachedReasonData then
    return
  end
  self.CheckContent_Text:SetText(self.CachedReasonData.ReasonDescType)
end
function TipoffCheckBoxItemPanel:GetTipOffReasonType()
  if self.CachedReasonData then
    return self.CachedReasonData.ReasonType
  end
end
function TipoffCheckBoxItemPanel:SetIsChecked(bSelect)
  if self.CheckBox_Slider then
    self.CheckBox_Slider:SetIsChecked(bSelect)
  end
end
return TipoffCheckBoxItemPanel
