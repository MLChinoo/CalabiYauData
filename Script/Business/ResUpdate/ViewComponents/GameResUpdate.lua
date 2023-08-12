local GameResUpdatePage = class("GameResUpdatePage", PureMVC.ViewComponentPage)
local GameResUpdateMediator = require("Business/ResUpdate/Mediators/GameResUpdateMediator")
local SpeedCalculatePeriod = 1
function GameResUpdatePage:ListNeededMediators()
  return {GameResUpdateMediator}
end
function GameResUpdatePage:InitializeLuaEvent()
end
function GameResUpdatePage:OnOpen(luaOpenData, nativeOpenData)
  self.CurSize = 0
  self.SpeedBeginSize = 0
  self.TxtStepDetail:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.TxtPercent:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:PlayBgVideo()
end
function GameResUpdatePage:OnClose()
  self:ClearCalSpeedTimer()
  self:CloseMediaPlayer()
end
function GameResUpdatePage:PlayBgVideo()
  if not self.BgMediaPlayer or not self.BgVideoPlaylist then
    return
  end
  if self.BgVideoPlaylist then
    self.BgVideoPlaylist:RemoveAt(0)
  end
  self.BgVideoPlaylist:AddFile(self.BgMediaFile.FilePath)
  self.BgMediaPlayer:OpenPlaylist(self.BgVideoPlaylist)
  self.BgMediaPlayer:SetLooping(true)
  self.BgMediaPlayer:Play()
end
function GameResUpdatePage:CloseMediaPlayer()
  if self.BgMediaPlayer then
    self.BgMediaPlayer:Close()
  end
end
function GameResUpdatePage:ClearCalSpeedTimer()
  if self.DownloadSpeedTimer then
    self.DownloadSpeedTimer:EndTask()
    self.DownloadSpeedTimer = nil
  end
end
function GameResUpdatePage:UpdateVersionInfo(UpdateType, UpdateVersion, UpdateSize, UpdateDesc, CustomDesc)
  local msg = ConfigMgr:FromStringTable(StringTablePath.ST_Login, "ResUpdateGen")
  self.TxtStep:SetText(msg or "正在为您更新游戏资源")
end
function GameResUpdatePage:SetUpdateProgress(curState, totalSize, curSize)
  local deltaSize = curSize - self.CurSize
  if deltaSize < 0 then
    deltaSize = curSize
  end
  self.CurSize = curSize
  self.TotalSize = totalSize
  local progressPct = totalSize > 0 and curSize / totalSize or 0
  self.TxtPercent:SetText(tostring(math.floor(progressPct * 100) .. "%"))
  self.TxtPercent:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.ProgressUpdate:SetPercent(progressPct)
  if not self.DownloadSpeedTimer then
    self.DownloadSpeedTimer = TimerMgr:AddTimeTask(SpeedCalculatePeriod, SpeedCalculatePeriod, 0, FuncSlot(GameResUpdatePage.CalDownloadSpeed, self))
    self:CalDownloadSpeed()
  end
  local detailMsg = ConfigMgr:FromStringTable(StringTablePath.ST_Login, "ResUpdateDetail")
  local totalSizeShow = math.ceil(totalSize / 1048576)
  detailMsg = ObjectUtil:GetTextFromFormat(detailMsg, {
    totalSizeShow,
    self.DownloadSpeed
  })
  self.TxtStepDetail:SetText(detailMsg)
  self.TxtStepDetail:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function GameResUpdatePage:CalDownloadSpeed()
  local deltaSize = self.CurSize - self.SpeedBeginSize
  self.DownloadSpeed = deltaSize / SpeedCalculatePeriod / 1048576
end
function GameResUpdatePage:SetUpdateError(curState, errorCode)
  print("-------- SetUpdateError, curState = ", curState)
  local msg = ""
  if 154140709 == errorCode then
    msg = ConfigMgr:FromStringTable(StringTablePath.ST_Login, "ResUpdateNoInitVersion")
    self:ShowMsgBox(msg)
  else
    msg = ConfigMgr:FromStringTable(StringTablePath.ST_Login, "ResUpdateError")
    msg = UE4.UKismetTextLibrary.Format(msg, errorCode)
  end
  self:ShowMsgBox(msg)
end
function GameResUpdatePage:ShowMsgBox(msg, oneButton)
  local pageData = {}
  pageData.contentTxt = msg or ""
  pageData.source = self
  pageData.cb = GameResUpdatePage.OnMsgBoxCallback
  if oneButton then
    pageData.bIsOneBtn = true
  end
  ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MsgDialogPage, false, pageData)
end
function GameResUpdatePage:OnMsgBoxCallback(isConfirm)
  GameFacade:SendNotification(NotificationDefines.NtfResUpdatePlayerChoice, isConfirm)
end
return GameResUpdatePage
