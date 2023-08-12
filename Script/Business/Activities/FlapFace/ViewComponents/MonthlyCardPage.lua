local MonthlyCardPage = class("MonthlyCardPage", PureMVC.ViewComponentPage)
local FlapFaceEnum = require("Business/Activities/FlapFace/Proxies/FlapFaceEnum")
function MonthlyCardPage:ListNeededMediators()
  return {}
end
function MonthlyCardPage:InitializeLuaEvent()
  self.Button_Get.OnClicked:Add(self, MonthlyCardPage.OnClickClose)
end
function MonthlyCardPage:OnOpen(luaOpenData, nativeOpenData)
  local FlapFaceProxy = GameFacade:RetrieveProxy(ProxyNames.FlapFaceProxy)
  FlapFaceProxy:SendLoginPictureReq({
    FlapFaceEnum.MonthlyCard
  })
  if luaOpenData and luaOpenData.CloseCallBack then
    self.CloseCallBack = luaOpenData.CloseCallBack
  end
  local HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  local data = HermesProxy:GetMonthCardData()
  if data then
    self.TextDay:SetText(data.left_count)
  end
end
function MonthlyCardPage:OnClickClose()
  ViewMgr:ClosePage(self, UIPageNameDefine.MonthlyCardPage)
  if self.CloseCallBack then
    self.CloseCallBack()
    self.CloseCallBack = nil
  end
  local obtainData = {}
  obtainData.overflowItemList = {}
  obtainData.itemList = {}
  local info = {}
  info.itemId = 3
  info.itemCnt = 0
  local HermesProxy = GameFacade:RetrieveProxy(ProxyNames.HermesProxy)
  local data = HermesProxy:GetMonthCardData()
  if data and data.crystal then
    info.itemCnt = data.crystal
  end
  table.insert(obtainData.itemList, info)
  ViewMgr:OpenPage(self, UIPageNameDefine.RewardDisplayPage, false, obtainData)
end
function MonthlyCardPage:OnClose()
end
return MonthlyCardPage
