local LotteryHistoryPage = class("LotteryHistoryPage", PureMVC.ViewComponentPage)
local LotteryHistoryMediator = require("Business/Lottery/Mediators/LotteryHistoryMediator")
function LotteryHistoryPage:ListNeededMediators()
  return {LotteryHistoryMediator}
end
function LotteryHistoryPage:InitView(bHasData)
  ViewMgr:ClosePage(self, UIPageNameDefine.PendingPage)
  if 1 == self.curPage then
    if false == bHasData then
      self:NoDataAvailable()
      return
    end
    self:UpdateView()
  end
end
function LotteryHistoryPage:UpdateView()
  if self.itemArray and self.curPage > 0 then
    local numPerPage = table.count(self.itemArray)
    local startPos = (self.curPage - 1) * numPerPage + 1
    local endPos = self.curPage * numPerPage
    local resultItem, bHasMore = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryHistory(startPos, endPos)
    local lotteryId = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotterySelected()
    if self.Btn_Last then
      self.Btn_Last:SetIsEnabled(1 ~= self.curPage)
    end
    if self.Btn_Next then
      self.Btn_Next:SetIsEnabled(bHasMore)
    end
    if self.Text_Page then
      self.Text_Page:SetText(self.curPage)
    end
    for key, value in pairs(self.itemArray) do
      if resultItem[key] then
        value:UpdateView(resultItem[key], lotteryId)
        value:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        value:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    if self.WidgetSwitcher_HasData then
      self.WidgetSwitcher_HasData:SetActiveWidgetIndex(0)
    end
  end
end
function LotteryHistoryPage:NoDataAvailable()
  LogInfo("LotteryHistoryPage", "Has no available data")
  if self.WidgetSwitcher_HasData then
    self.WidgetSwitcher_HasData:SetActiveWidgetIndex(1)
  end
end
function LotteryHistoryPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("LotteryHistoryPage", "Lua implement OnOpen")
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.HoldOn)
  if self.Btn_Last then
    self.Btn_Last.OnClicked:Add(self, self.OnClickLast)
  end
  if self.Btn_Next then
    self.Btn_Next.OnClicked:Add(self, self.OnClickNext)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Add(self, self.OnClickReturn)
  end
  self.curPage = 1
  if self.VB_ItemArray then
    self.itemArray = {}
    for i = 1, self.VB_ItemArray:GetAllChildren():Length() do
      table.insert(self.itemArray, self.VB_ItemArray:GetAllChildren():Get(i))
    end
  end
  if self.itemArray then
    ViewMgr:OpenPage(self, UIPageNameDefine.PendingPage)
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):ReqLotteryHistory(1, table.count(self.itemArray) * 5)
  end
end
function LotteryHistoryPage:OnClose()
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.CancelHoldOn)
  if self.Btn_Last then
    self.Btn_Last.OnClicked:Remove(self, self.OnClickLast)
  end
  if self.Btn_Next then
    self.Btn_Next.OnClicked:Remove(self, self.OnClickNext)
  end
  if self.Button_Return then
    self.Button_Return.OnClickEvent:Remove(self, self.OnClickReturn)
  end
end
function LotteryHistoryPage:LuaHandleKeyEvent(key, inputEvent)
  if self.Button_Return then
    return self.Button_Return:MonitorKeyDown(key, inputEvent)
  end
  return false
end
function LotteryHistoryPage:OnClickReturn()
  LogInfo("LotteryHistoryPage", "On click return")
  ViewMgr:ClosePage(self)
end
function LotteryHistoryPage:OnClickLast()
  LogInfo("LotteryHistoryPage", "On click last")
  self.curPage = self.curPage - 1
  self:UpdateView()
end
function LotteryHistoryPage:OnClickNext()
  LogInfo("LotteryHistoryPage", "On click next")
  self.curPage = self.curPage + 1
  self:UpdateView()
end
return LotteryHistoryPage
