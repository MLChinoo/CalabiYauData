local ApartmentContractMissionItem = class("ApartmentContractMissionItem", PureMVC.ViewComponentPanel)
function ApartmentContractMissionItem:Construct()
  ApartmentContractMissionItem.super.Construct(self)
  if self.ImgReward then
    self.ImgReward.OnMouseButtonDownEvent:Bind(self, self.OnRewardImgClick)
  end
end
function ApartmentContractMissionItem:Destruct()
  ApartmentContractMissionItem.super.Destruct(self)
  if self.ImgReward then
    self.ImgReward.OnMouseButtonDownEvent:Unbind()
  end
end
function ApartmentContractMissionItem:OnRewardImgClick()
  if self.itemData.taskState ~= Pb_ncmd_cs.ETaskState.TaskState_FINISH then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local sequenceId = RoleProxy:GetSequenceIdByRoleIdAndFavorLevel(self.itemData.roleId, self.itemData.taskLv)
  if sequenceId > 0 then
    self:PlaySequence(sequenceId)
  elseif GameFacade:RetrieveProxy(ProxyNames.ApartmentContractProxy):CheckPlayTaskRewardsAnim() then
    GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):SwithchGetGiftState()
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function ApartmentContractMissionItem:PlaySequence(sequenceId)
  if sequenceId <= 0 then
    return
  end
  local CySequenceMgr = UE4.UCySequenceManager.Get(LuaGetWorld())
  CySequenceMgr:PlaySequence(sequenceId)
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, true)
end
function ApartmentContractMissionItem:OnListItemObjectSet(UObject)
  self.UObject = UObject
  self.UObject.Entry = self
  self.ParentPanel = self.UObject.parentPage
  self:SetItemData(self.UObject.data)
end
function ApartmentContractMissionItem:SetItemData(itemData)
  self.itemData = itemData
  if self.itemData.taskState and not self.itemData.newUnlock then
    self.MissonBg:SetOpacity(0.4)
    self.RewardBg:SetOpacity(0.4)
    self.ImgReward:SetOpacity(1)
    self.MissionName:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.CanvasLocked:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ImgRewardLock:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SBTaskDetails:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.AvailableRedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.itemData.taskState >= Pb_ncmd_cs.ETaskState.TaskState_FINISH then
      self.Img_Done:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.CanvasDone:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      self.HB_Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.AvailableRedDot:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
      if self.itemData.taskState == Pb_ncmd_cs.ETaskState.TaskState_PRIZE_TAKEN then
        self.ImgReward:SetOpacity(0.4)
        self.AvailableRedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    else
      self.Img_Done:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.CanvasDone:SetVisibility(UE4.ESlateVisibility.Collapsed)
      self.HB_Progress:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    end
  else
    self.MissonBg:SetOpacity(0.1)
    self.RewardBg:SetOpacity(0.1)
    self.ImgReward:SetOpacity(1)
    self.MissionName:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasLocked:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ImgRewardLock:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    self.Img_Done:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.CanvasDone:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.HB_Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.SBTaskDetails:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.TxtLvCondi:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.AvailableRedDot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.Txt_MissionLv:SetText(tostring(self.itemData.taskLv))
  self.MissionName:SetText(self.itemData.taskDesc)
  self.TextProgress:SetText(tostring(self.itemData.taskProgress))
  local targetStr = string.format("/%d", self.itemData.taskTarget)
  self.MissionTarget:SetText(targetStr)
  if self.itemData.softTexture then
    self.ImgReward:SetVisibility(UE4.ESlateVisibility.Visible)
    self.ImgReward:SetBrushFromSoftTexture(self.itemData.softTexture)
  else
    self.ImgReward:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function ApartmentContractMissionItem:PlayUnlockEff()
  if not self.itemData.newUnlock then
    return
  end
  self:PlayAnimation(self.SBTask, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.itemData.newUnlock = false
  self:SetItemData(self.itemData)
end
return ApartmentContractMissionItem
