local FlapFacePage = class("FlapFacePage", PureMVC.ViewComponentPage)
local FlapFaceEnum = require("Business/Activities/FlapFace/Proxies/FlapFaceEnum")
function FlapFacePage:ListNeededMediators()
  return {}
end
function FlapFacePage:InitializeLuaEvent()
  self.Btn_close.OnClicked:Add(self, FlapFacePage.OnClickClose)
  self.Btn_buy.OnClicked:Add(self, FlapFacePage.OnClickBuy)
  self.Button_Quit.OnClickEvent:Add(self, FlapFacePage.OnClickClose)
end
function FlapFacePage:OnOpen(luaOpenData, nativeOpenData)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  local FlapFaceProxy = GameFacade:RetrieveProxy(ProxyNames.FlapFaceProxy)
  local currentTime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  FlapFaceProxy:WritePopTimeStamp(currentTime, FlapFaceEnum.FlapFace)
  if luaOpenData and luaOpenData.CloseCallBack then
    self.CloseCallBack = luaOpenData.CloseCallBack
  end
end
function FlapFacePage:OnClickClose()
  ViewMgr:ClosePage(self, UIPageNameDefine.FlapFacePage)
  if self.CloseCallBack then
    self.CloseCallBack()
    self.CloseCallBack = nil
  end
end
function FlapFacePage:OnClickBuy()
  ViewMgr:ClosePage(self, UIPageNameDefine.FlapFacePage)
  GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
    target = UIPageNameDefine.HermesHotListPage,
    pageIndex = 1
  })
end
function FlapFacePage:OnClose()
end
function FlapFacePage:LuaHandleKeyEvent(key, inputEvent)
  return self.Button_Quit:MonitorKeyDown(key, inputEvent)
end
return FlapFacePage
