local PlayerNameMediator = class("PlayerNameMediator", PureMVC.Mediator)
function PlayerNameMediator:OnRegister()
  self.ViewPage = self:GetViewComponent()
  self:InitModel()
end
function PlayerNameMediator:OnRemove()
  self.super:OnRemove()
  if self.ReqRandomNameTimer then
    self.ReqRandomNameTimer:EndTask()
    self.ReqRandomNameTimer = nil
  end
end
function PlayerNameMediator:InitModel()
  self.ViewPage.InitPageEvent:Add(self.InitPage, self)
  self.LoginSubsystem = UE4.UPMLoginSubSystem.GetInstance(self.ViewPage)
  if not self.LoginSubsystem then
    LogInfo("PlayerNameMediator", "OnRegister, LoginSubsystem is nil")
    return
  end
  DelegateMgr:BindDelegate(self.LoginSubsystem.GetRandomNameDelegate, self, PlayerNameMediator.GetRandomName)
  DelegateMgr:BindDelegate(self.LoginSubsystem.OnPlayerBenameDelegate, self, PlayerNameMediator.OnBenameResult)
end
function PlayerNameMediator:InitPage()
  local initName = self.LoginSubsystem:GetInheritPlayerName()
  self.ViewPage:ShowInputName(initName)
end
function PlayerNameMediator:ListNotificationInterests()
  return {
    NotificationDefines.Login.NtfReqRandomName,
    NotificationDefines.Login.NtfDoCreatPlayer
  }
end
function PlayerNameMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  if NtfName == NotificationDefines.Login.NtfReqRandomName then
    self:ReqRandomName()
  elseif NtfName == NotificationDefines.Login.NtfDoCreatPlayer then
    self:DoPlayerBename(notification:GetBody())
  end
end
function PlayerNameMediator:ReqRandomName()
  if self.ReqRandomNameTimer then
    return
  end
  self.ReqRandomNameTimer = TimerMgr:AddTimeTask(0.4, 0.0, 1, function()
    self.ReqRandomNameTimer = nil
  end)
  self.LoginSubsystem:OnClickRandomNick()
end
function PlayerNameMediator:GetRandomName(RandomName)
  self.ViewPage:ShowInputName(RandomName)
end
function PlayerNameMediator:DoPlayerBename(newName)
  local rlt = self.LoginSubsystem:OnPlayerBeName(newName)
  if not rlt then
    self.ViewPage:ClearEnsureTimer()
    self.ViewPage:EnableAllInput(true)
  end
end
function PlayerNameMediator:OnBenameResult(result, errCode)
  self.ViewPage:ClearEnsureTimer()
  if result then
    self.LoginSubsystem:PlayerBenameComplete()
    local GuideEventTrackSubSys = UE4.UCyClientEventTrackSubsystem.Get(LuaGetWorld())
    if GuideEventTrackSubSys then
      GuideEventTrackSubSys:UploadBenameGuideData()
    end
    self.ViewPage:PlayNamedAniAndClose()
    if self.ViewPage and self.ViewPage.Txt_NickName then
      local name = self.ViewPage.Txt_NickName:GetText()
      local PlayerController = UE4.UGameplayStatics.GetPlayerController(self.ViewPage, 0)
      local HUD = PlayerController:GetHUD()
      HUD:SetPlayerUIDAndName("", name)
    end
  else
    self.ViewPage:EnableAllInput(true)
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, errCode)
  end
end
return PlayerNameMediator
