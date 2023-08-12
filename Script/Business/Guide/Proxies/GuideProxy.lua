local UGameplayStatics = UE4.UGameplayStatics
local EPMGameModeType = UE4.EPMGameModeType
local GuideProxy = class("GuideProxy", PureMVC.Proxy)
local ModuleNotificationDefines = NotificationDefines.Guide
function GuideProxy:OnRegister()
  GuideProxy.super.OnRegister(self)
  local World = LuaGetWorld()
  if not World then
    return
  end
  local GameState = UGameplayStatics.GetGameState(World)
  if not GameState or not GameState.GetModeType then
    return
  end
  local ModeType = GameState:GetModeType()
  if ModeType ~= EPMGameModeType.NoviceGuide and ModeType ~= EPMGameModeType.TeamGuide then
    return
  end
  local GameplayDelegate = GetGamePlayDelegateManager()
  if GameplayDelegate and DelegateMgr then
    self.OnGuideTaskBeginHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnGuideTaskBegin, self, "OnGuideTaskBegin")
    self.OnGuideTaskUpdateHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnGuideTaskUpdate, self, "OnGuideTaskUpdate")
    self.OnGuideSubTaskUpdateHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnGuideSubTaskUpdate, self, "OnGuideSubTaskUpdate")
    self.OnGuideDeathTipsHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnGuideDeathTips, self, "OnGuideDeathTips")
    self.OnGuideDialogueBeginHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnGuideDialogBegin, self, "OnGuideDialogBegin")
    self.OnGuideDialogEndHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnGuideDialogEnd, self, "OnGuideDialogEnd")
    self.OnGuideMediaGuideHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnGuideMediaGuide, self, "OnGuideMediaGuide")
    self.OnGuideUIGuideHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnGuideUIGuide, self, "OnGuideUIGuide")
  end
end
function GuideProxy:OnRemove()
  local World = LuaGetWorld()
  if not World then
    return
  end
  local GameState = UGameplayStatics.GetGameState(World)
  if not GameState or not GameState.GetModeType then
    return
  end
  local ModeType = GameState:GetModeType()
  if ModeType ~= EPMGameModeType.NoviceGuide and ModeType ~= EPMGameModeType.TeamGuide then
    return
  end
  local GameplayDelegate = GetGamePlayDelegateManager()
  if GameplayDelegate and DelegateMgr then
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnGuideTaskBegin, self.OnGuideTaskBeginHandle)
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnGuideTaskUpdate, self.OnGuideTaskUpdateHandle)
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnGuideSubTaskUpdate, self.OnGuideSubTaskUpdateHandle)
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnGuideDeathTips, self.OnGuideDeathTipsHandle)
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnGuideDialogBegin, self.OnGuideDialogueBeginHandle)
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnGuideDialogEnd, self.OnGuideDialogEndHandle)
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnGuideMediaGuide, self.OnGuideMediaGuideHandle)
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnGuideUIGuide, self.OnGuideUIGuideHandle)
  end
end
function GuideProxy:TryInitGuideTask(World)
  LogInfo("GuideProxy", "TryInitGuideTask")
  local PlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(World, 0)
  LogInfo("GuideProxy", "TryInitGuideTask - 1 %s %s", PlayerController, PlayerController and PlayerController.PlayerState)
  if PlayerController and PlayerController.PlayerState then
    local GuideTask = PlayerController.PlayerState.GuideTask
    LogInfo("GuideProxy", "TryInitGuideTask - 2 %s %s", GuideTask, GuideTask and GuideTask.TaskId)
    if GuideTask and GuideTask.TaskId and GuideTask.TaskId > 0 then
      LogInfo("GuideProxy", "TryInitTask - InitTask")
      self:OnGuideTaskBegin(GuideTask)
    end
  end
end
function GuideProxy:TryInitGuideDialogue(World)
  LogInfo("GuideProxy", "TryInitGuideDialogue")
  local PlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(World, 0)
  if PlayerController and PlayerController.PlayerState then
    local GuideDialogue = PlayerController.PlayerState.GuideDialogue
    if GuideDialogue and GuideDialogue.DialogueId and GuideDialogue.DialogueId > 0 then
      LogInfo("GuideProxy", "TryInitDialogue - InitDialogue")
      self:OnGuideDialogBegin(GuideDialogue)
    end
  end
end
function GuideProxy:TryInitGuideUIGuide(World)
  LogInfo("GuideProxy", "TryInitGuideUIGuide")
  local PlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(World, 0)
  if PlayerController and PlayerController.PlayerState then
    local GuideUIGuideConfig = PlayerController.PlayerState.GuideUIGuideConfig
    if GuideUIGuideConfig and GuideUIGuideConfig.Id > 0 then
      LogInfo("GuideProxy", "TryInitUIGuide - InitUIGuide")
      self:OnGuideUIGuide(GuideUIGuideConfig, true)
    end
  end
end
function GuideProxy:OnGuideTaskBegin(InTaskData)
  LogInfo("GuideProxy", "OnGuideTaskBegin")
  if GameFacade then
    local SubTaskCount = InTaskData.SubTasks:Length()
    local SubTasks = {}
    local SubTaskData, TipsCount, TipData
    for i = 1, SubTaskCount do
      SubTaskData = InTaskData.SubTasks:Get(i)
      if SubTaskData then
        TipsCount = SubTaskData.TipTexts:Length()
        local TipDatas = {}
        for j = 1, TipsCount do
          TipData = SubTaskData.TipTexts:Get(j)
          if TipData then
            TipDatas[#TipDatas + 1] = TipData
          end
        end
        SubTasks[#SubTasks + 1] = {
          SubTaskId = SubTaskData.SubTaskId,
          bMustComplete = SubTaskData.bMustComplete,
          bShow = SubTaskData.bShow,
          TaskName = SubTaskData.TaskName,
          TaskState = SubTaskData.TaskState,
          KeyText = SubTaskData.KeyText,
          TipDatas = TipDatas
        }
      end
    end
    local TaskData = {
      TaskId = InTaskData.TaskId,
      bShow = InTaskData.bShow,
      bGuideEnd = InTaskData.bGuideEnd,
      TaskName = InTaskData.TaskName,
      TaskState = InTaskData.TaskState,
      TargetPointTag = InTaskData.TargetPointTag,
      SubTasks = SubTasks
    }
    GameFacade:SendNotification(ModuleNotificationDefines.GuideTask, {TaskData = TaskData}, ModuleNotificationDefines.GuideTaskType.Begin)
  end
end
function GuideProxy:OnGuideTaskUpdate(InTaskId, InTaskState, InCompleteNum)
  LogInfo("GuideProxy", "OnGuideTaskUpdate")
  if GameFacade then
    GameFacade:SendNotification(ModuleNotificationDefines.GuideTask, {TaskState = InTaskState}, ModuleNotificationDefines.GuideTaskType.Update)
  end
end
function GuideProxy:OnGuideSubTaskUpdate(InSubTaskId, InTaskState, InCompleteNum)
  LogInfo("GuideProxy", "OnGuideSubTaskUpdate")
  if GameFacade then
    GameFacade:SendNotification(ModuleNotificationDefines.GuideSubTask, {
      SubTaskId = InSubTaskId,
      TaskState = InTaskState,
      CompleteNum = InCompleteNum
    }, ModuleNotificationDefines.GuideSubTaskType.Update)
  end
end
function GuideProxy:OnGuideDeathTips(InTipsData)
  LogInfo("GuideProxy", "OnGuideDeathTips")
  if GameFacade then
    GameFacade:SendNotification(ModuleNotificationDefines.DeathTipsCmd, InTipsData, nil)
  end
end
function GuideProxy:OnGuideDialogBegin(InDialogueData)
  LogInfo("GuideProxy", "OnGuideDialogBegin")
  if not (InDialogueData and InDialogueData.bShow) or not GameFacade then
    return
  end
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  if not RoleProxy then
    return
  end
  local RoleSkinData = RoleProxy:GetRoleDefaultSkin(InDialogueData.RoleId)
  local RoleProfileData = RoleProxy:GetRoleProfile(InDialogueData.RoleId)
  if not RoleSkinData or not RoleProfileData then
    return
  end
  GameFacade:SendNotification(ModuleNotificationDefines.GuideDialogue, {
    DialogueId = InDialogueData.DialogueId,
    bFlickerHead = InDialogueData.bFlickerHead,
    RoleHead = RoleSkinData.IconRoleHud,
    RoleName = RoleProfileData.NameCn,
    Text = InDialogueData.Text,
    RoleNameColor = InDialogueData.RoleNameColor
  }, ModuleNotificationDefines.GuideDialogueType.Begin)
end
function GuideProxy:OnGuideDialogEnd(InDialogueId)
  LogInfo("GuideProxy", "OnGuideDialogEnd")
  if GameFacade then
    GameFacade:SendNotification(ModuleNotificationDefines.GuideDialogue, {DialogueId = InDialogueId}, ModuleNotificationDefines.GuideDialogueType.End)
  end
end
function GuideProxy:OnGuideMediaGuide(InData)
  LogInfo("GuideProxy", "OnGuideMediaGuide")
  if GameFacade then
    GameFacade:SendNotification(ModuleNotificationDefines.MediaGuideCmd, InData, nil)
  end
end
function GuideProxy:OnGuideUIGuide(InData, bInShow)
  LogInfo("GuideProxy", "OnGuideUIGuide")
  if GameFacade then
    local GuideTypeConfigCount = InData.UIGuideTypeConfigs:Length()
    local GuideTypeConfigs = {}
    local GuideTypeConfig
    for i = 1, GuideTypeConfigCount do
      GuideTypeConfig = InData.UIGuideTypeConfigs:Get(i)
      if GuideTypeConfig then
        GuideTypeConfigs[#GuideTypeConfigs + 1] = {
          GameFunctionType = GuideTypeConfig.GameFunctionType,
          UIGuideType = GuideTypeConfig.UIGuideType,
          GuideInfo = GuideTypeConfig.GuideInfo,
          BeginDelay = GuideTypeConfig.BeginDelay,
          LoopTimes = GuideTypeConfig.LoopTimes,
          LoopInterval = GuideTypeConfig.LoopInterval,
          bCustomLayout = GuideTypeConfig.bCustomLayout,
          bCustomLocation = GuideTypeConfig.bCustomLocation,
          LocationOffset = GuideTypeConfig.LocationOffset,
          Location = GuideTypeConfig.Location,
          Size = GuideTypeConfig.Size,
          AnchorData = GuideTypeConfig.AnchorData
        }
      end
    end
    if bInShow then
      GameFacade:SendNotification(ModuleNotificationDefines.UIGuide, GuideTypeConfigs, ModuleNotificationDefines.UIGuideType.Begin)
    else
      GameFacade:SendNotification(ModuleNotificationDefines.UIGuide, GuideTypeConfigs, ModuleNotificationDefines.UIGuideType.End)
    end
  end
end
return GuideProxy
