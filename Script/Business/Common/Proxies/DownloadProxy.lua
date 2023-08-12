local DownloadProxy = class("DownloadProxy", PureMVC.Proxy)
local DownRetEnum = require("Business/Common/Proxies/DownloadEnum")
function DownloadProxy:OnRegister()
  DownloadProxy.super.OnRegister(self)
  self.downloadMap = {}
  self.downloadUrlSize = {}
end
function DownloadProxy:downloadUrl(url, savepath, callfunc, progfunc, bcustomTip)
  if "" == url then
    LogInfo("DownloadProxy", "url is empty")
    return
  end
  if "" == savepath then
    LogInfo("DownloadProxy", "savepath: is empty")
    return
  end
  if type(callfunc) ~= "function" then
    LogInfo("DownloadProxy", "callfunc: is error")
    return
  end
  if self.downloadMap[url] then
    LogInfo("DownloadProxy", string.format("url: %s is downloading!", url))
    return
  end
  local downloadInst = UE4.UPMHttpFileDown.CreateHttpFileDown()
  local handler = DelegateMgr:AddDelegate(downloadInst.DownCompleteCb, self, "DownloadCallFunc")
  self.downloadMap[url] = {
    savepath = savepath,
    callfunc = callfunc,
    handler = handler,
    inst = downloadInst,
    bCustomTip = bcustomTip
  }
  if type(progfunc) == "function" then
    local progressHandler = DelegateMgr:AddDelegate(downloadInst.DownProgressCb, self, "ProgressCallFunc")
    self.downloadMap[url].progressHandler = progressHandler
    self.downloadMap[url].progfunc = progfunc
  end
  self.downloadMap[url].timeoutId = self:CreateTimeoutTimer(url)
  self.downloadMap[url].receivedBytes = 0
  self.downloadMap[url].totalBytes = 0
  downloadInst:StartHttpDown(url, savepath)
end
function DownloadProxy:DownloadCallFunc(url, ret, code)
  if self.downloadMap[url] == nil then
    LogInfo("DownloadProxy", "url " .. tostring(url) .. "is not exists")
    return
  end
  local restbl = self.downloadMap[url]
  self:RemoveDownloadUrl(url)
  restbl.callfunc(ret, url, restbl.savepath, code)
end
function DownloadProxy:ProgressCallFunc(url, receivedBytes, totalBytes)
  self:DestoryTimeoutTimer(url)
  if self.downloadUrlSize[url] ~= totalBytes then
    self.downloadUrlSize[url] = totalBytes
  end
  if self.downloadMap[url] == nil then
    LogInfo("DownloadProxy", "url " .. tostring(url) .. " is not exists")
    return
  end
  self.downloadMap[url].receivedBytes = receivedBytes
  self.downloadMap[url].totalBytes = totalBytes
  local restbl = self.downloadMap[url]
  restbl.progfunc(url, receivedBytes, totalBytes)
end
function DownloadProxy:RemoveDownloadUrl(url)
  local restbl = self.downloadMap[url]
  local inst = restbl.inst
  if restbl.handler then
    DelegateMgr:RemoveDelegate(inst.DownCompleteCb, restbl.handler)
    restbl.handler = nil
  end
  if restbl.progressHandler then
    DelegateMgr:RemoveDelegate(inst.DownProgressCb, restbl.progressHandler)
    restbl.progressHandler = nil
  end
  self:DestoryTimeoutTimer(url)
  self.downloadMap[url] = nil
end
function DownloadProxy:GetTotalSizeByUrl(url)
  return self.downloadUrlSize[url]
end
function DownloadProxy:GetDownloadMapByUrl(url)
  return self.downloadMap[url]
end
function DownloadProxy:CreateTimeoutTimer(url)
  local TimeoutTimer = TimerMgr:AddTimeTask(10, 0, 1, function()
    print("url timeout " .. url)
    local restbl = self.downloadMap[url]
    self:RemoveDownloadUrl(url)
    restbl.callfunc(DownRetEnum.TimeOut, url)
  end)
  return TimeoutTimer
end
function DownloadProxy:DestoryTimeoutTimer(url)
  if self.downloadMap[url].timeoutId then
    self.downloadMap[url].timeoutId:EndTask()
    self.downloadMap[url].timeoutId = nil
  end
end
function DownloadProxy:OnRemove()
  local urlList = {}
  for url, _ in pairs(self.downloadMap) do
    urlList[#urlList + 1] = url
  end
  for i, url in ipairs(urlList) do
    self:RemoveDownloadUrl(url)
  end
  self.downloadMap = {}
  self.downloadUrlSize = {}
  DownloadProxy.super.OnRemove(self)
end
return DownloadProxy
