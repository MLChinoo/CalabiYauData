local KaChatDetailPanel = class("KaChatDetailPanel", PureMVC.ViewComponentPanel)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Audio = UE4.UPMLuaAudioBlueprintLibrary
local Valid
local List = {}
function List.new()
  return {First = 0, Last = -1}
end
function List.PushLeft(InList, value)
  local First = InList.First - 1
  InList.First = First
  InList[First] = value
end
function List.PushRight(InList, value)
  local Last = InList.Last + 1
  InList.Last = Last
  InList[Last] = value
end
function List.PopLeft(InList)
  local First = InList.First
  if First > InList.Last then
    return nil
  end
  local value = InList[First]
  InList[First] = nil
  InList.First = First + 1
  return value
end
function List.PopRight(InList)
  local Last = InList.Last
  if Last < InList.First then
    return nil
  end
  local value = InList[Last]
  InList[Last] = nil
  InList.Last = Last - 1
  return value
end
function List.PopAll(InList)
  for i, v in pairs(InList or {}) do
    v = nil
  end
  InList = {First = 0, Last = -1}
end
function KaChatDetailPanel:Update(CurSecondListMap, ChatDetailName)
  if not CurSecondListMap then
    return nil
  end
  self.CurSecondListMap = CurSecondListMap
  Valid = self.ChatDetailList and self.ChatDetailList:SetVisibility(UE.ESlateVisibility.Visible)
  Valid = self.NPCName and self.NPCName:SetText(ChatDetailName)
  self:RefreshAllDetail()
  self:SetVisibility(SelfHitTestInvisible)
  self:SetSkipButtonEnable(false)
end
function KaChatDetailPanel:SetSkipButtonEnable(IsEnable)
  Valid = self.Button_Skip and self.Button_Skip:SetIsEnabled(IsEnable)
  Valid = self.Button_Skip and self.Button_Skip:SetVisibility(IsEnable and Visible or SelfHitTestInvisible)
end
function KaChatDetailPanel:RefreshAllDetail()
  self.KaPhoneInput:ShowInput(false)
  self:ClearTimer()
  Valid = self.ChatDetailList and self.ChatDetailList:Reset(true)
  local obj
  for key, value in pairsByKeys(self.CurSecondListMap or {}, function(a, b)
    return a < b
  end) do
    self:CreateDetailItem(key, value)
  end
  Valid = self.ScrollBox_List and self.ScrollBox_List:ScrollToEnd()
  if self.NewMsgList then
    List.PopAll(self.NewMsgList)
    self.NewMsgList = nil
  end
end
function KaChatDetailPanel:AddNewDetail(DetailData)
  if not DetailData then
    return {}
  end
  self.KaPhoneInput:ShowInput(false)
  Valid = self.ScrollBox_List and self.ScrollBox_List:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if not self.NewMsgList then
    self.NewMsgList = List.new()
  end
  for key, value in pairsByKeys(DetailData or {}, function(a, b)
    return a < b
  end) do
    List.PushRight(self.NewMsgList, {Key = key, Value = value})
  end
  self:PlayCurMsg()
end
function KaChatDetailPanel:PlayCurMsg()
  if self.NewMsgList then
    local CurNewMsg = List.PopLeft(self.NewMsgList)
    self:ClearTimer()
    if CurNewMsg then
      Valid = self.ScrollBox_List and self.ScrollBox_List:ScrollToEnd()
      self:CreateDetailItem(CurNewMsg.Key, CurNewMsg.Value, true)
      self:SetSkipButtonEnable(true)
      self.ShowCurNewMsgTimer = TimerMgr:AddTimeTask(self.fDelayTime, 0, 1, function()
        self:PlayCurMsg()
      end)
    else
      self.AllowScrollTimer = TimerMgr:AddTimeTask(self.fDelayTime, 0, 1, function()
        Valid = self.ScrollBox_List and self.ScrollBox_List:SetVisibility(UE.ESlateVisibility.Visible)
        self:SetSkipButtonEnable(false)
      end)
    end
  end
end
function KaChatDetailPanel:ClearTimer()
  if self.AllowScrollTimer then
    self.AllowScrollTimer:EndTask()
    self.AllowScrollTimer = nil
  end
  if self.ShowCurNewMsgTimer then
    self.ShowCurNewMsgTimer:EndTask()
    self.ShowCurNewMsgTimer = nil
  end
end
function KaChatDetailPanel:CreateDetailItem(Key, Data, bIsNewMsg)
  if Data.IsNeedOpenOption then
    Valid = self.KaPhoneInput and self.KaPhoneInput:UpdateInputInfo(Data.OptionData, Key)
    Valid = self.KaPhoneInput and self.KaPhoneInput:ShowInput(true)
  else
    local ChatDetailItem = self.ChatDetailList and self.ChatDetailList:BP_CreateEntry()
    if ChatDetailItem then
      ChatDetailItem:InitItem(Data, bIsNewMsg)
    end
  end
end
function KaChatDetailPanel:OnClickSkip()
  self:SetSkipButtonEnable(false)
  Valid = self.ShowCurNewMsgTimer and self.ShowCurNewMsgTimer:FinishedTask()
end
function KaChatDetailPanel:Construct()
  KaChatDetailPanel.super.Construct(self)
  self:SetVisibility(Collapsed)
  self:ClearTimer()
  self:BindEvent()
  if self.NewMsgList then
    List.PopAll(self.NewMsgList)
    self.NewMsgList = nil
  end
end
function KaChatDetailPanel:Destruct()
  self:RemoveEvent()
  self:ClearTimer()
  Valid = self.PlayingId and Audio.StopPlayingID(self.PlayingId)
  if self.ShowInputTimer then
    self.ShowInputTimer:EndTask()
    self.ShowInputTimer = nil
  end
  if self.NewMsgList then
    List.PopAll(self.NewMsgList)
    self.NewMsgList = nil
  end
  KaChatDetailPanel.super.Destruct(self)
end
function KaChatDetailPanel:BindEvent()
  Valid = self.Button_Skip and self.Button_Skip.OnClicked:Add(self, self.OnClickSkip)
end
function KaChatDetailPanel:RemoveEvent()
  Valid = self.Button_Skip and self.Button_Skip.OnClicked:Remove(self, self.OnClickSkip)
end
function KaChatDetailPanel:OnItemClicked(UObject)
end
return KaChatDetailPanel
