local InvitationLetterInvitationCodePanel = class("InvitationLetterInvitationCodePanel", PureMVC.ViewComponentPage)
function InvitationLetterInvitationCodePanel:ListNeededMediators()
  return {}
end
InvitationLetterInvitationCodePanel.InvitationCodeStatus = {
  TaskNoCompleted = 0,
  TaskFinished = 1,
  InvitationCodeReceived = 2,
  InvitationCodeUsed = 3
}
function InvitationLetterInvitationCodePanel:Construct()
  InvitationLetterInvitationCodePanel.super.Construct(self)
  self.Btn_ReqReceiveInvitationCode.OnClicked:Add(self, InvitationLetterInvitationCodePanel.OnReqReceiveInvitationCode)
  self.Btn_CopyInvitationCode.OnClicked:Add(self, InvitationLetterInvitationCodePanel.OnCopyInvitationCode)
  self.activityId = 0
  self.subActivityId = 0
  self.currentInvitationCodeStatus = 0
  if self.bp_backgroundTextuire then
    self:SetImageByTexture2D(self.Img_Background, self.bp_backgroundTextuire)
  end
end
function InvitationLetterInvitationCodePanel:Destruct()
  InvitationLetterInvitationCodePanel.super.Destruct(self)
  self.Btn_ReqReceiveInvitationCode.OnClicked:Remove(self, InvitationLetterInvitationCodePanel.OnReqReceiveInvitationCode)
  self.Btn_CopyInvitationCode.OnClicked:Remove(self, InvitationLetterInvitationCodePanel.OnCopyInvitationCode)
end
function InvitationLetterInvitationCodePanel:InitCfgList(data)
  if data.activity_name then
    local activityName = data.activity_name
    local activityNameLen = string.len(activityName)
    for index = 1, activityNameLen do
      local subStr = string.sub(activityName, index, index)
      if subStr and tonumber(subStr) then
        self.Txt_TaskName:SetText(string.sub(activityName, 0, index - 1))
        self.Txt_TaskName_RightStr:SetText(string.sub(activityName, index, activityNameLen))
        break
      end
    end
  else
    LogInfo("InvitationLetterLog:", "InitCfgList" .. "   activity_name is nil")
  end
  if data.activity_id then
    self.activityId = data.activity_id
  else
    LogInfo("InvitationLetterLog:", "InitCfgList" .. "   activity_id is nil")
  end
  if data.sub_activity_id then
    self.subActivityId = data.sub_activity_id
  else
    LogInfo("InvitationLetterLog:", "InitCfgList" .. "   sub_activity_id is nil")
  end
  if data.conditions then
    LogInfo("InvitationLetterLog:", "InitCfgList" .. "   conditions num is " .. #data.conditions)
    for key, value in pairs(data.conditions) do
      self.Txt_TotalProgress:SetText(value.cond_value)
    end
  else
    LogInfo("InvitationLetterLog:", "InitCfgList" .. "   conditions is nil")
  end
end
function InvitationLetterInvitationCodePanel:InitDataList(data)
  if data.cond_value then
    self.Txt_CurrentProgress:SetText(data.cond_value)
  else
    LogInfo("InvitationLetterLog:", "InitDataList" .. "   cond_value is nil")
  end
  if data.status then
    local InvitationLetterProxy = GameFacade:RetrieveProxy(ProxyNames.InvitationLetterProxy)
    local oldCodeStatus = self.currentInvitationCodeStatus
    if oldCodeStatus == InvitationLetterInvitationCodePanel.InvitationCodeStatus.TaskFinished then
      InvitationLetterProxy:SetRedRotNum(InvitationLetterProxy:GetRedRotNum() - 1)
    end
    local codeStatus = data.status
    self.currentInvitationCodeStatus = codeStatus
    if codeStatus < 2 then
      self.WS_InvitationCodeState:SetActiveWidgetIndex(0)
      if codeStatus == InvitationLetterInvitationCodePanel.InvitationCodeStatus.TaskFinished then
        self.WS_TaskReceiveState:SetActiveWidgetIndex(1)
        self:PlayAnimation(self.Prompt, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
        InvitationLetterProxy:SetRedRotNum(InvitationLetterProxy:GetRedRotNum() + 1)
      end
    else
      self.WS_InvitationCodeState:SetActiveWidgetIndex(1)
      if codeStatus == InvitationLetterInvitationCodePanel.InvitationCodeStatus.InvitationCodeUsed then
        self.WS_CodeCopyState:SetActiveWidgetIndex(1)
        self.Txt_CodeStr:SetStrikeBrush(self.bp_strikeBrush)
      end
    end
    if data.code_str then
      self.codeStr = data.code_str
      self.Txt_CodeStr:SetText(self.codeStr)
    else
      LogInfo("InvitationLetterLog:", "InitDataList" .. "   code_str is nil")
    end
  else
    LogInfo("InvitationLetterLog:", "InitDataList" .. "   status is nil")
  end
end
function InvitationLetterInvitationCodePanel:OnCopyInvitationCode()
  if self.codeStr then
    UE4.UPMLuaBridgeBlueprintLibrary.ClipboardCopy(tostring(self.codeStr))
    local CopyStrSuccess = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "CopyStrSuccess")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, CopyStrSuccess)
  end
end
function InvitationLetterInvitationCodePanel:OnReqReceiveInvitationCode()
  if self.activityId and self.subActivityId then
    local InvitationLetterProxy = GameFacade:RetrieveProxy(ProxyNames.InvitationLetterProxy)
    InvitationLetterProxy:ReqGetInvitationCode(self.activityId, self.subActivityId)
  else
    LogInfo("InvitationLetterLog:", "OnReqReceiveInvitationCode" .. "   activityId or subActivityId is invalid")
  end
end
return InvitationLetterInvitationCodePanel
