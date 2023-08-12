local BattlePassTaskItem = class("BattlePassTaskItem", PureMVC.ViewComponentPanel)
function BattlePassTaskItem:Construct()
  BattlePassTaskItem.super.Construct(self)
  if self.Btn_Flush then
    self.Btn_Flush.OnClicked:Add(self, self.OnBtnFlushClick)
  end
  if self.Effece_Refresh then
    self.Effece_Refresh:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function BattlePassTaskItem:Destruct()
  BattlePassTaskItem.super.Destruct(self)
  if self.Btn_Flush then
    self.Btn_Flush.OnClicked:Remove(self, self.OnBtnFlushClick)
  end
end
function BattlePassTaskItem:OnBtnFlushClick()
  if self.parentPage then
    self.parentPage:OnBtnFlushTask(self)
  end
end
function BattlePassTaskItem:UpdateView(parent, data)
  self.parentPage = parent
  self.taskId = data.taskId
  if self.Btn_Flush then
    if data.type == GlobalEnumDefine.EBattlePassTaskType.kDayTask and not data.permanent then
      self.Btn_Flush:SetVisibility(UE4.ESlateVisibility.Visible)
    else
      self.Btn_Flush:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self:SetLoopIconVisible(data.type == GlobalEnumDefine.EBattlePassTaskType.kLoopTask)
  if self.Txt_Desc then
    self.Txt_Desc:SetText(data.desc)
  end
  if self.Txt_PrizeCnt then
    self.Txt_PrizeCnt:SetText("+" .. data.prize)
  end
  if self.Txt_Progress_Cur then
    self.Txt_Progress_Cur:SetText(data.value)
  end
  if self.Txt_Progress_Tar then
    self.Txt_Progress_Tar:SetText(data.targetValue)
  end
  if self.PB_Progress then
    self.PB_Progress:SetPercent(data.value / data.targetValue)
  end
  if self.Switcher_Progress then
    if data.state >= 3 then
      self.Switcher_Progress:SetActiveWidgetIndex(1)
    else
      self.Switcher_Progress:SetActiveWidgetIndex(0)
    end
  end
end
function BattlePassTaskItem:FlushAnim()
  if self.Effece_Refresh then
    self.Effece_Refresh:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.Effece_Refresh:SetReactivate(true)
    self:K2_PostAkEvent(self.FlushSound)
  end
end
function BattlePassTaskItem:SetLoopIconVisible(bShow)
  if self.Overlay_Loop then
    self.Overlay_Loop:SetVisibility(bShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    if bShow then
      local canLoopText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "RepeatableComplete")
      if self.Txt_Loop then
        self.Txt_Loop:SetText(canLoopText)
      end
    end
  end
end
return BattlePassTaskItem
