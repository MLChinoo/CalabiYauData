local ReplayDownloadButton = class("ReplayDownloadButton", PureMVC.ViewComponentPanel)
local DownRetEnum = require("Business/Common/Proxies/DownloadEnum")
local downlaod
local Status = {
  NotExists = 1,
  Downloading = 2,
  Play = 3,
  OutOfData = 4,
  NotPrepare = 5
}
local ReplayMediator = require("Business/Common/Mediators/Replay/ReplayMediator")
function ReplayDownloadButton:ListNeededMediators()
  return {ReplayMediator}
end
function ReplayDownloadButton:OnInitialized()
  ReplayDownloadButton.super.OnInitialized(self)
  self.Button_download.OnClicked:Add(self, ReplayDownloadButton.OnClickDownload)
  self.Button_Play.OnClicked:Add(self, ReplayDownloadButton.OnClickPlay)
  if self.Button_Prepare then
    self.Button_Prepare.OnClicked:Add(self, ReplayDownloadButton.OnClickPrepare)
  end
end
function ReplayDownloadButton:InitView(args, bFromBattelInfo)
  local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
  local PlayerAttrProxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  self.filePath = nil
  self.filename = nil
  self.roomid = args.room_id
  self.endtime = args.end_time
  self.mapid = args.map_id
  self.url = nil
  self.bFromBatteleInfo = bFromBattelInfo
  self.playerid = PlayerAttrProxy:GetPlayerId()
  if nil == self.bFromBatteleInfo then
    if not ReplayProxy:CheckReplayWell(self.roomid) then
      self:SetPlayStatus(Status.NotPrepare)
    else
      self:RefreshView()
    end
  else
    local filename = ReplayProxy:GetFileNameByRoomId(tostring(self.roomid))
    local url = ReplayProxy:GetUrlByRoomId(tostring(self.roomid))
    if nil ~= filename then
      self.filePath = ReplayProxy:getFilePath(filename .. ".replay", self.playerid)
      self.filename = filename
    elseif nil ~= url then
      self:SetUrlAndFileName(url)
      local DownloadProxy = GameFacade:RetrieveProxy(ProxyNames.DownloadProxy)
      local downloadMap = DownloadProxy:GetDownloadMapByUrl(url)
      if downloadMap then
        local callbackTbl = self:GetDownloadCallBack()
        downloadMap.progfunc = callbackTbl.downloadProgress
        downloadMap.callfunc = callbackTbl.downloadComplete
      end
    end
    self:RefreshView()
  end
end
function ReplayDownloadButton:CheckFileOutOfDate()
  if self.endtime then
    local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
    return ReplayProxy:CheckOutofData(tonumber(self.endtime))
  else
    return false
  end
end
function ReplayDownloadButton:CheckFileNotCompatible()
  local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
  if self.filename then
    local info = ReplayProxy:SolveReplayFilename(self.filename)
    return ReplayProxy:CheckFileNotCompatible(info.version)
  end
  return false
end
function ReplayDownloadButton:OnClickDownload()
  local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
  ReplayProxy:ReqBattleReplay(self.roomid)
end
function ReplayDownloadButton:OnClickPrepare()
  local tip = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "NoReplayFile")
  GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tip)
end
function ReplayDownloadButton:SetPlayStatus(status)
  local index = status - 1
  self.WidgetSwitcher_Download:SetActiveWidgetIndex(index)
end
function ReplayDownloadButton:CheckFileExist()
  if self.filePath == nil or not UE.UBlueprintPathsLibrary.FileExists(self.filePath) then
    return false
  end
  return true
end
function ReplayDownloadButton:RefreshView()
  if not self:CheckFileExist() then
    if self:CheckFileOutOfDate() then
      self:SetPlayStatus(Status.OutOfData)
    else
      local DownloadProxy = GameFacade:RetrieveProxy(ProxyNames.DownloadProxy)
      local downloadMap = DownloadProxy:GetDownloadMapByUrl(self.url)
      if self.url and downloadMap then
        self:SetPlayStatus(Status.Downloading)
        self.Progress:SetPercent(downloadMap.receivedBytes / downloadMap.totalBytes)
      else
        self:SetPlayStatus(Status.NotExists)
      end
    end
  elseif self:CheckFileOutOfDate() or self:CheckFileNotCompatible() then
    self:SetPlayStatus(Status.OutOfData)
  else
    self:SetPlayStatus(Status.Play)
  end
end
function ReplayDownloadButton:OnClickPlay()
  local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
  ReplayProxy:ReqBattleReplay(self.roomid)
end
function ReplayDownloadButton:PlayVideo()
  local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
  local gameInstance = UE4.UGameplayStatics.GetGameInstance(self)
  local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local teamInfo = roomProxy:GetTeamInfo()
  local pageData = {}
  pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "PlayReplayAndQuitRoom")
  pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "Enter")
  pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "Cancel")
  function pageData.cb(bConfirm)
    if bConfirm then
      if self.bFromBatteleInfo then
        ReplayProxy:SetBattleInfoFlag(true, self.roomid)
      end
      UE4.UPMLuaBridgeBlueprintLibrary.PlayReplayFile(gameInstance, self.filename, self.mapid)
      ReplayProxy.bPlayReplaying = true
      ReplayProxy:ReqEnterReplay()
    end
  end
  ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
end
function ReplayDownloadButton:SetUrlAndFileName(url)
  self.url = url
  LogDebug("ReplayDownloadButton", tostring(url))
  local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
  if self.filePath == nil then
    local tbl = string.split(url, "/")
    local filenamewithext = tbl[#tbl]
    local s, e = string.find(filenamewithext, ".replay")
    local filename = string.format("%s_%s", tostring(self.playerid), string.sub(filenamewithext, 1, s - 1))
    self.filePath = ReplayProxy:getFilePath(filename .. ".replay", self.playerid)
    self.filename = filename
  end
end
function ReplayDownloadButton:BeginDownloadUrl(downloadurl)
  local retTbl = {}
  local ReplayProxy = GameFacade:RetrieveProxy(ProxyNames.ReplayProxy)
  local DownloadProxy = GameFacade:RetrieveProxy(ProxyNames.DownloadProxy)
  LogDebug("ReplayDownloadButton", tostring(downloadurl))
  self:SetUrlAndFileName(downloadurl)
  LogDebug("ReplayDownloadButton", tostring(self.filename))
  local info = ReplayProxy:SolveReplayFilename(self.filename)
  local _roomid = info.roomid
  local _filename = self.filename
  local _fullfilepath = self.filePath
  local _datestr = info.datestr
  local successFunc = function()
    ReplayProxy:PushFilePathByRoomId(_roomid, {
      filename = _filename,
      fullfilepath = _fullfilepath,
      datestr = _datestr
    })
  end
  local ret = self:GetDownloadCallBack()
  DownloadProxy:downloadUrl(self.url, self.filePath, ret.downloadComplete, ret.downloadProgress)
  self:SetPlayStatus(Status.Downloading)
  self.Progress:SetPercent(0)
end
function ReplayDownloadButton:GetDownloadCallBack()
  local downloadComplete = function(ret, url, savepath, code)
    code = code or 0
    savepath = savepath or ""
    if 0 == ret and successFunc and type(successFunc) == "function" then
      successFunc()
      successFunc = nil
    end
    if url == self.url then
      if ret == DownRetEnum.TimeOut then
        LogDebug("ReplayDownloadButton", "timeout")
        local tip = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "NoReplayFile")
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tip)
      elseif ret == DownRetEnum.RespStatusErr and 404 == code then
        LogDebug("ReplayDownloadButton", "404")
        local tip = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "NoReplayFile")
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tip)
      elseif ret == DownRetEnum.WriteDataErr then
        local urlsize = DownloadProxy:GetTotalSizeByUrl(url)
        local filesize = UE4.UPMLuaBridgeBlueprintLibrary.GetFileSize(savepath)
        if urlsize and urlsize > filesize then
          LogDebug("DownloadProxy", "ret  is " .. tostring(ret) .. " code is " .. tostring(code))
          local tip = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "DiskSizeNotFull")
          GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tip)
          UE4.UBlueprintFileUtilsBPLibrary.DeleteFile(savepath)
        end
      elseif ret ~= DownRetEnum.Success then
        LogDebug("ReplayDownloadButton", "not success")
        LogDebug("DownloadProxy", "ret  is " .. tostring(ret) .. " code is " .. tostring(code))
        local tip = ConfigMgr:FromStringTable(StringTablePath.ST_Replay, "NoReplayFile")
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tip)
      end
      self:RefreshView()
    end
  end
  local downloadProgress = function(url, receiveBytes, totalBytes)
    if self.url == url and self.filePath ~= nil then
      self:SetPlayStatus(Status.Downloading)
      self.Progress:SetPercent(receiveBytes / totalBytes)
    end
  end
  return {downloadProgress = downloadProgress, downloadComplete = downloadComplete}
end
function ReplayDownloadButton:PrepareDownload(roomid)
  if self.roomid == roomid and self.bFromBatteleInfo == nil then
    self:RefreshView()
  end
end
function ReplayDownloadButton:Destruct()
  ReplayDownloadButton.super.Destruct(self)
  self.url = nil
end
return ReplayDownloadButton
