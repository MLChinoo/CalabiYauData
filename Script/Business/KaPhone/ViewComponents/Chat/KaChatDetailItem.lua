local KaChatDetailItem = class("KaChatDetailItem", PureMVC.ViewComponentPanel)
local Hidden = UE4.ESlateVisibility.Hidden
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
local Audio = UE4.UPMLuaAudioBlueprintLibrary
local EnumContentType = {
  Text = 0,
  Picture = 1,
  ShowingAnimation = 2
}
function KaChatDetailItem:Construct()
  KaChatDetailItem.super.Construct(self)
  self.StopTipBox:SetVisibility(Collapsed)
  self.RetainerBox_175:SetVisibility(Collapsed)
end
function KaChatDetailItem:Destruct()
  Valid = self.AnimationTask and self.AnimationTask:EndTask()
  self.AnimationTask = nil
  self:StopAllAnimations()
  KaChatDetailItem.super.Destruct(self)
end
function KaChatDetailItem:InitItem(Data, bIsNewMsg)
  self.ContentSwitcher:SetVisibility(SelfHitTestInvisible)
  self.StopTipBox:SetVisibility(Collapsed)
  self.RetainerBox_175:SetVisibility(Collapsed)
  if not Data then
    return nil
  end
  if Data.IsAddStopTip then
    GameFacade:RetrieveProxy(ProxyNames.KaChatProxy):ReqChatEnd(Data.UniqueMark)
    Valid = self.ContentSwitcher and self.ContentSwitcher:SetVisibility(UE.ESlateVisibility.Collapsed)
    Valid = self.StopTipBox and self.StopTipBox:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    return
  end
  self.ContentSwitcher:SetActiveWidgetIndex(Data.IsNpc and 0 or 1)
  if Data.IsNpc then
    self:InitNPCItem(Data, bIsNewMsg)
  else
    self:InitPlayerItem(Data)
  end
end
function KaChatDetailItem:InitNPCItem(Data, bIsNewMsg)
  if not Data.ContentType then
    return nil
  end
  local ContentType = EnumContentType.Text
  if Data.ContentType == UE.ECyCommunicationContentType.Texture then
    ContentType = EnumContentType.Picture
    local ContentPictureStrpath = UE.UKismetSystemLibrary.MakeSoftObjectPath(Data.ContentPicture)
    local ContentPicture = UE.UKismetSystemLibrary.Conv_SoftObjPathToSoftObjRef(ContentPictureStrpath)
    Valid = self.NpcContentImage and self:SetImageByTexture2D_MatchSize(self.NpcContentImage, ContentPicture)
    Valid = self.NpcContentImage and self.NpcContentImage:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.IsCanClick = false
  elseif Data.ContentType == UE.ECyCommunicationContentType.Voice then
    ContentType = EnumContentType.AkEvent
    local AkEventDuration = Data.ContentAkEvent and math.floor(Audio.GetAkEventMinimumDuration(Data.ContentAkEvent) * 10 + 0.5) / 10
    self.AkEvent = Data.ContentAkEvent
    Valid = AkEventDuration and self.ContentVioceDuration and self.ContentVioceDuration:SetText(AkEventDuration .. "″")
    self.IsCanClick = true
  elseif Data.ContentType == UE.ECyCommunicationContentType.Text then
    ContentType = EnumContentType.Text
    Valid = self.NpcContentText and self.NpcContentText:SetText(Data.ContentText)
    self.IsCanClick = false
  end
  if bIsNewMsg then
    self:ShowAnimation(ContentType)
  else
    Valid = self.ContentTypeSwitcher and self.ContentTypeSwitcher:SetActiveWidgetIndex(ContentType)
  end
  if Data.IsShowAvatar then
    if Data.RoleAvatar and Data.RoleAvatar ~= "" then
      local RoleAvatarStrpath = UE.UKismetSystemLibrary.MakeSoftObjectPath(Data.RoleAvatar)
      local RoleAvatar = UE.UKismetSystemLibrary.Conv_SoftObjPathToSoftObjRef(RoleAvatarStrpath)
      Valid = self.NPCImg and self:SetImageByTexture2D(self.NPCImg, RoleAvatar)
      Valid = self.NPCImg and self.NPCImg:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    else
      Valid = self.NPCImg and self.NPCImg:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  Valid = self.Text_Name and self.Text_Name:SetText(Data.RoleName)
  Valid = self.Overlay_NPCImg and self.Overlay_NPCImg:SetVisibility(Data.IsShowAvatar and SelfHitTestInvisible or Hidden)
  Valid = self.HeadSpacer and self.HeadSpacer:SetVisibility(Data.IsShowAvatar and SelfHitTestInvisible or Collapsed)
  Valid = self.NPCChatImgSwitcher and self.NPCChatImgSwitcher:SetActiveWidgetIndex(Data.IsShowAvatar and 0 or 1)
end
function KaChatDetailItem:InitPlayerItem(Data)
  Valid = self.PlayerContent and self.PlayerContent:SetText(Data.ContentText)
end
function KaChatDetailItem:ShowAnimation(ContentType)
  Valid = self.ShowingAnim and self:StopAnimation(self.ShowingAnim)
  Valid = self.ShowingAnim and self:PlayAnimation(self.ShowingAnim, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
  if ContentType == EnumContentType.Picture then
    Valid = self.NpcContentImage and self.NpcContentImage:SetVisibility(UE.ESlateVisibility.Hidden)
    local delayTime = self.DelayLoadingImgTime or 0
    self.AnimationTask = TimerMgr and TimerMgr:AddTimeTask(delayTime, 0, 0, function()
      Valid = self.NpcContentImage and self.NpcContentImage:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self:StopAllAnimations()
      self.AnimationTask = nil
    end)
    Valid = self.ContentTypeSwitcher and self.ContentTypeSwitcher:SetActiveWidgetIndex(ContentType)
  else
    Valid = self.ContentTypeSwitcher and self.ContentTypeSwitcher:SetActiveWidgetIndex(EnumContentType.ShowingAnimation)
    local delayTime = self.DelayLoadingTime or 0
    self.AnimationTask = TimerMgr and TimerMgr:AddTimeTask(delayTime, 0.0, 0, function()
      Valid = self.ContentTypeSwitcher and self.ContentTypeSwitcher:SetActiveWidgetIndex(ContentType)
      self:StopAllAnimations()
      self.AnimationTask = nil
    end)
  end
end
return KaChatDetailItem
