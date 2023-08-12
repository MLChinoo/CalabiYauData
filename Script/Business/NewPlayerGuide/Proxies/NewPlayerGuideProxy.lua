local NewPlayerGuideProxy = class("NewPlayerGuideProxy", PureMVC.Proxy)
local NewPlayerGuideEnum = require("Business/NewPlayerGuide/Proxies/NewPlayerGuideEnum")
local NewPlayerGuideId = 1
function NewPlayerGuideProxy:OnRegister()
  self.super.OnRegister(self)
  self.GuideStepCfgs = {}
  self:InitNewPlayerGuideCfgs()
  self.CurStep = UE4.ENewPlayerGuideSpecialStep.START_STEP
  self.bExist = false
  self.ResetTeamFightGuideFlag = false
end
function NewPlayerGuideProxy:OnRemove()
  self.super.OnRemove(self)
end
function NewPlayerGuideProxy:InitNewPlayerGuideCfgs()
  local GuideStepCfgs = ConfigMgr:GetNewPlayerGuideTableRow()
  if GuideStepCfgs then
    GuideStepCfgs = GuideStepCfgs:ToLuaTable()
    for key, cfg in pairs(GuideStepCfgs) do
      self.GuideStepCfgs[cfg.GuideStep] = cfg
    end
  end
end
function NewPlayerGuideProxy:CheckSubSystem()
  if not self.NewPlayerGuideSubsystem then
    self.NewPlayerGuideSubsystem = UE4.UPMNewPlayerGuideSubsystem.GetInstance(LuaGetWorld())
    self.CurStep = self.NewPlayerGuideSubsystem:GetPlayerGuideCurStep(NewPlayerGuideId)
    self.CurStep = self:GetNextStep()
    if self.NewPlayerGuideSubsystem:IsSkipAllGuide() then
      self.CurStep = UE4.ENewPlayerGuideSpecialStep.DONE_STEP
    end
    LogDebug("NewPlayerGuide", "CheckSubSystem, current step = %d", self.CurStep)
  end
end
function NewPlayerGuideProxy:GetGuideStepCfg(step)
  return self.GuideStepCfgs[step]
end
function NewPlayerGuideProxy:SetCurComplete()
  if 0 == self.CurStep then
    return
  end
  self.NewPlayerGuideSubsystem:ReqUpdateGuideStep(NewPlayerGuideId, self.CurStep)
  local nextStep, nextCfg = self:GetNextStep()
  self.CurStep = nextStep
  GameFacade:SendNotification(NotificationDefines.NewPlayerGuide.GuideStepUpdate, {
    CurStep = self.CurStep
  })
  LogDebug("NewPlayerGuide", "Guide step update, current step = %d", self.CurStep)
  return nextCfg
end
function NewPlayerGuideProxy:GetNextStep()
  local nextStep, nextCfg
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if self.CurStep ~= UE4.ENewPlayerGuideSpecialStep.DONE_STEP then
    local totalStep = #self.GuideStepCfgs
    for step = self.CurStep + 1, totalStep do
      local cfg = self.GuideStepCfgs[step]
      if cfg then
        local isStepEnable = cfg.IsEnable
        if platform == GlobalEnumDefine.EPlatformType.Mobile then
          isStepEnable = cfg.IsMBEnable
        end
        if isStepEnable then
          nextStep = step
          nextCfg = cfg
          break
        end
      end
    end
  end
  nextStep = nextStep or UE4.ENewPlayerGuideSpecialStep.DONE_STEP
  return nextStep, nextCfg
end
function NewPlayerGuideProxy:CheckNewPageStep(curStep)
  local cfg = self.GuideStepCfgs[curStep]
  if cfg and cfg.EventUIName == "NewGuidePage" then
    return true
  end
  return false
end
function NewPlayerGuideProxy:SkipLoggingStep()
  for i, v in pairs(self.GuideStepCfgs or {}) do
    if 2 ~= i then
      v.IsEnable = false
    end
  end
end
function NewPlayerGuideProxy:IsAllGuideComplete()
  self:CheckSubSystem()
  return self.CurStep == UE4.ENewPlayerGuideSpecialStep.DONE_STEP
end
function NewPlayerGuideProxy:IsShowGuideUI(step)
  local NewPlayerGuideTriggerProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideTriggerProxy)
  if self:CheckNewPageStep(self.CurStep) and NewPlayerGuideTriggerProxy:CheckStep(step) then
    return true
  end
  return false
end
function NewPlayerGuideProxy:CheckIsTeamFightGuide(step)
  local cfg = self.GuideStepCfgs[step]
  if cfg and cfg.EventUIName and cfg.EventUIName == "TeamCompetitionPage" then
    return true
  end
  return false
end
function NewPlayerGuideProxy:IsNowGuidingTeamFight()
  return self:CheckIsTeamFightGuide(self.CurStep)
end
function NewPlayerGuideProxy:GetCurStep()
  self:CheckSubSystem()
  return self.CurStep
end
function NewPlayerGuideProxy:GetCurStepConfig()
  return self:GetGuideStepCfg(self:GetCurStep())
end
function NewPlayerGuideProxy:CheckOpenUI(stepCfg)
  if stepCfg and stepCfg.GuideEventType == UE4.EPMNewerGuideEventType.OpenUIPage and stepCfg.EventUIName then
    local UIName = UIPageNameDefine[stepCfg.EventUIName]
    if UIName then
      ViewMgr:OpenPage(LuaGetWorld(), UIName)
    end
    LogDebug("NewPlayerGuide", "Open UI : %s", UIName)
  end
end
function NewPlayerGuideProxy:SetGuideUIExistFlag(bFlag)
  self.bExist = bFlag
end
function NewPlayerGuideProxy:GetGuideUIExistFlag()
  return self.bExist
end
function NewPlayerGuideProxy:ResetTeamFightGuide()
  local targetStep = 0
  for k, v in pairs(self.GuideStepCfgs or {}) do
    if self:CheckIsTeamFightGuide(v.GuideStep) then
      targetStep = tonumber(v.GuideStep)
      break
    end
  end
  if targetStep > 0 and targetStep == self.CurStep then
    self.ResetTeamFightGuideFlag = false
    GameFacade:SendNotification(NotificationDefines.NewPlayerGuide.GuideStepUpdate, {CurStep = targetStep})
  end
end
return NewPlayerGuideProxy
