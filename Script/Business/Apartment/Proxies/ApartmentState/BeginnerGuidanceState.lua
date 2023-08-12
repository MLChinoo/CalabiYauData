local BaseState = require("Business/Apartment/Proxies/ApartmentState/ApartmentBaseState")
local BeginnerGuidanceState = class("BeginnerGuidanceState", BaseState)
local PlayerGuideProxy
function BeginnerGuidanceState:Start()
  self.super.Start(self)
  PlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  self:HideUI()
  self:NextStep()
end
function BeginnerGuidanceState:Stop()
  self.super.Stop(self)
end
function BeginnerGuidanceState:Tick(time)
  self.super:Tick(time)
end
function BeginnerGuidanceState:OnSequenceStop(sequenceId, reasonType)
  if (reasonType == UE4.ESequenceStopReason.Reason_Completed or reasonType == UE4.ESequenceStopReason.Reason_Skip) and self.lastStepConfig and self.lastStepConfig.GuideEventType == UE4.EPMNewerGuideEventType.PlaySequencer then
    self:ReportTlog(sequenceId, reasonType)
    self.lastStepConfig = nil
    PlayerGuideProxy:SetCurComplete()
  end
end
function BeginnerGuidanceState:NextStep()
  if PlayerGuideProxy:IsAllGuideComplete() then
    LogDebug("BeginnerGuidanceState", "GuideComplete")
    self:ShowUI()
    self:SwitchStateByID(UE4.ECyApartmentState.SceneInterpretationIdle)
    return
  end
  local stepConfig = PlayerGuideProxy:GetCurStepConfig()
  if nil == stepConfig then
    LogError("BeginnerGuidanceState", "stepConfig is nil")
    self:ShowUI()
    self:SwitchStateByID(UE4.ECyApartmentState.Entry)
    return
  end
  local stepType = stepConfig.GuideEventType
  if stepType == UE4.EPMNewerGuideEventType.PlaySequencer then
    self:PlaySequence(stepConfig.EventSequencerId)
    self.lastStepConfig = stepConfig
  elseif stepType == UE4.EPMNewerGuideEventType.OpenUIPage then
    self:PlaySequence(stepConfig.EventSequencerId)
    ViewMgr:OpenPage(LuaGetWorld(), stepConfig.EventUIName)
  end
end
function BeginnerGuidanceState:ReportTlog(sequenceID, reasonType)
  local tempState = 0
  if reasonType == UE4.ESequenceStopReason.Reason_Skip then
    tempState = 1
  elseif reasonType == UE4.ESequenceStopReason.Reason_Completed then
    tempState = 2
  end
  UE4.UCyClientEventTrackSubsystem.Get(LuaGetWorld()):UploadSequenceGuideData(sequenceID, tempState)
end
return BeginnerGuidanceState
