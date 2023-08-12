local PrefaceStoryPage = class("PrefaceStoryPage", PureMVC.ViewComponentPage)
function PrefaceStoryPage:OnOpen(luaOpenData, nativeOpenData)
  self.IsReplay = luaOpenData and luaOpenData.IsReplay
  self.LoginEntered = false
  if self.BtnSkip then
    self.BtnSkip.OnClicked:Add(self, self.ClosePage)
  end
  self:PlayBgVideo()
end
function PrefaceStoryPage:ListNeededMediators()
  return {}
end
function PrefaceStoryPage:OnClose()
  self:ClearLoginEnterTimer()
  if self.CGMediaPlayer then
    self.CGMediaPlayer:Close()
  end
  if self.DelegetVedioPlayEnd then
    DelegateMgr:RemoveDelegate(self.CGMediaPlayer.OnEndReached, self.DelegetVedioPlayEnd)
    self.DelegetVedioPlayEnd = nil
  end
end
function PrefaceStoryPage:PlayBgVideo()
  if not self.CGMediaPlayer or not self.VideoPlayList then
    return
  end
  self.DelegetVedioPlayEnd = DelegateMgr:AddDelegate(self.CGMediaPlayer.OnEndReached, self, PrefaceStoryPage.ClosePage)
  if self.VideoPlayList then
    self.VideoPlayList:RemoveAt(0)
  end
  self.VideoPlayList:AddFile(self.CGMediaFile.FilePath)
  self.CGMediaPlayer:OpenPlaylist(self.VideoPlayList)
  self.CGMediaPlayer:SetLooping(false)
  self.CGMediaPlayer:Play()
  self:ClearLoginEnterTimer()
  local videoDuration = 93
  self.LoginPageEnterTimer = TimerMgr:AddTimeTask(videoDuration, 0, 1, FuncSlot(self.NtfLoginPageEnter, self))
end
function PrefaceStoryPage:NtfLoginPageEnter()
  self.LoginEntered = true
  self:PlayAnimationForward(self.Fadeout)
  GameFacade:SendNotification(NotificationDefines.Login.NotePrefaceStoryPageClose, self.IsReplay)
  self:ClearLoginEnterTimer()
end
function PrefaceStoryPage:ClearLoginEnterTimer()
  if self.LoginPageEnterTimer then
    self.LoginPageEnterTimer:EndTask()
    self.LoginPageEnterTimer = nil
  end
end
function PrefaceStoryPage:ClosePage()
  local loginSubsystem = UE4.UPMLoginSubSystem.GetInstance(self)
  if loginSubsystem then
    loginSubsystem:PrefadeStoryPlayEnd()
  else
    LogInfo("PrefaceStoryPage", "ClosePage, LoginSubsystem is nil")
  end
  ViewMgr:ClosePage(self, UIPageNameDefine.PrefaceStoryPage)
  if not self.LoginEntered then
    GameFacade:SendNotification(NotificationDefines.Login.NotePrefaceStoryPageClose, self.IsReplay)
    self.LoginEntered = true
  end
end
function PrefaceStoryPage:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent ~= UE4.EInputEvent.IE_Released then
    return false
  end
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    self:ClosePage()
    return true
  end
  if "Space Bar" == keyName then
    return true
  end
  return false
end
return PrefaceStoryPage
