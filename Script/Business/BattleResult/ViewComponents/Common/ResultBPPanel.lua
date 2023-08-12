local ResultBPPanel = class("ResultBPPanel", PureMVC.ViewComponentPanel)
local ResultBPMediator = require("Business/BattleResult/Mediators/ResultBPMediator")
function ResultBPPanel:ListNeededMediators()
  return {ResultBPMediator}
end
function ResultBPPanel:Construct()
  ResultBPPanel.super.Construct(self)
  LogDebug("ResultBPPanel", "Construct")
end
function ResultBPPanel:Destruct()
  ResultBPPanel.super.Destruct(self)
end
function ResultBPPanel:UpdateBPTasks(BPTasks)
  LogDebug("ResultBPPanel", "UpdateBPTasks")
  if table.count(BPTasks) > 0 then
    local Layout = self.CanvasPanel_Bg.Slot:GetLayout()
    Layout.Offsets.Bottom = -28
    self.CanvasPanel_Bg.Slot:SetLayout(Layout)
    self.SizeBox_BPTasks:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    local Layout = self.CanvasPanel_Bg.Slot:GetLayout()
    Layout.Offsets.Bottom = 0
    self.CanvasPanel_Bg.Slot:SetLayout(Layout)
    self.SizeBox_BPTasks:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  for key, Task in pairs(BPTasks) do
    local ResultBPTaskDataObject = {}
    ResultBPTaskDataObject.Task = Task
    local ItemClass = ObjectUtil.LoadClass(self, self.ListItemClass)
    local ResultBPTaskItemPanel = UE4.UWidgetBlueprintLibrary.Create(self, ItemClass)
    self.ListView_BPTasks:AddChild(ResultBPTaskItemPanel)
    ResultBPTaskItemPanel:OnListItemObjectSet(ResultBPTaskDataObject)
    local margin = UE4.FMargin()
    margin.Bottom = 20
    ResultBPTaskItemPanel.Slot:SetPadding(margin)
  end
end
function ResultBPPanel:AddBPTask(BPTask)
  local ResultBPTaskDataObject = {}
  ResultBPTaskDataObject.Task = BPTask
  local ItemClass = ObjectUtil.LoadClass(self, self.ListItemClass)
  local ResultBPTaskItemPanel = UE4.UWidgetBlueprintLibrary.Create(self, ItemClass)
  self.ListView_BPTasks:AddChild(ResultBPTaskItemPanel)
  ResultBPTaskItemPanel:OnListItemObjectSet(ResultBPTaskDataObject)
  local margin = UE4.FMargin()
  margin.Bottom = 28
  ResultBPTaskItemPanel.Slot:SetPadding(margin)
end
function ResultBPPanel:StopProgressAni()
  if self.WBP_ResultBPBaseInfoPanel:IsProgressAniPlaying() then
    self.WBP_ResultBPBaseInfoPanel:StopProgressAni()
  end
  local ChildPanelArray = self.ListView_BPTasks:GetAllChildren()
  for i = 1, ChildPanelArray:Length() do
    local ResultBPTaskItemPanel = ChildPanelArray:Get(i)
    if ResultBPTaskItemPanel:IsProgressAniPlaying() then
      ResultBPTaskItemPanel:StopProgressAni()
    end
  end
end
function ResultBPPanel:IsProgressAniPlaying()
  local IsPlaying = self.WBP_ResultBPBaseInfoPanel:IsProgressAniPlaying()
  local ChildPanelArray = self.ListView_BPTasks:GetAllChildren()
  for i = 1, ChildPanelArray:Length() do
    local ResultBPTaskItemPanel = ChildPanelArray:Get(i)
    IsPlaying = IsPlaying or ResultBPTaskItemPanel:IsProgressAniPlaying()
  end
  return IsPlaying
end
function ResultBPPanel:GetProgressAniMaxTime()
  local MaxTime = self.WBP_ResultBPBaseInfoPanel:GetProgressAniMaxTime() or 0
  local ChildPanelArray = self.ListView_BPTasks:GetAllChildren()
  for i = 1, ChildPanelArray:Length() do
    local ResultBPTaskItemPanel = ChildPanelArray:Get(i)
    local Time = ResultBPTaskItemPanel:GetProgressAniMaxTime() or 0
    if MaxTime < Time then
      MaxTime = Time
    end
  end
  return MaxTime
end
return ResultBPPanel
