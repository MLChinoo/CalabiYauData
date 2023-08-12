local LoginQueuePage = class("LoginQueuePage", PureMVC.ViewComponentPage)
local LoginQueueMediator = require("Business/Login/Mediators/LoginQueueMediator")
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function LoginQueuePage:RefreshPage(Data)
  if Data then
    self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    Valid = self.Text_QueueNum and self.Text_QueueNum:SetText(Data.rank)
    local TimeTable = FunctionUtil:FormatTime(tonumber(Data.left_time))
    local SignVisibility = Collapsed
    local SignLessVisibility = Collapsed
    local QueueTime = TimeTable.Minute
    if TimeTable.Hours >= 1 then
      QueueTime = 60
      SignVisibility = SelfHitTestInvisible
    elseif TimeTable.Minute <= 0 and TimeTable.Second then
      QueueTime = 1
      SignLessVisibility = SelfHitTestInvisible
    end
    Valid = self.Text_QueueTime and self.Text_QueueTime:SetText(QueueTime)
    Valid = self.Text_QueueSign and self.Text_QueueSign:SetVisibility(SignVisibility)
    Valid = self.Text_QueueSign_Less and self.Text_QueueSign_Less:SetVisibility(SignLessVisibility)
  end
end
function LoginQueuePage:ClearTimer()
  if self.RefreshQueueInfoTimer then
    self.RefreshQueueInfoTimer:EndTask()
    self.RefreshQueueInfoTimer = nil
  end
  if self.RefreshTextContentTimer then
    self.RefreshTextContentTimer:EndTask()
    self.RefreshTextContentTimer = nil
  end
end
function LoginQueuePage:ClosePage()
  GameFacade:SendNotification(NotificationDefines.Login.NtfClearHint)
  ViewMgr:ClosePage(self)
end
function LoginQueuePage:ListNeededMediators()
  return {LoginQueueMediator}
end
function LoginQueuePage:LuaHandleKeyEvent(key, inputEvent)
  return self.Button_Return:MonitorKeyDown(key, inputEvent)
end
function LoginQueuePage:OnOpen(luaOpenData, nativeOpenData)
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  Valid = self.Button_Return and self.Button_Return.OnClickEvent:Add(self, self.OnClickReturn)
  local LoginDataProxy = GameFacade:RetrieveProxy(ProxyNames.LoginData)
  if TimerMgr then
    if self.RefreshQueueInfoTimer then
      self.RefreshQueueInfoTimer:EndTask()
      self.RefreshQueueInfoTimer = nil
    end
    self.RefreshQueueInfoTimer = TimerMgr:AddTimeTask(0, self.ReqLoginTime or 2, 0, function()
      LoginDataProxy:ReqLoginQueue()
    end)
    if self.RefreshTextContentTimer then
      self.RefreshTextContentTimer:EndTask()
      self.RefreshTextContentTimer = nil
    end
    local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
    local AllRoleCfgs = roleProxy:GetAllRoleCfgs()
    local TipsNum = 0
    local TextContentTable = {}
    for k, v in pairs(AllRoleCfgs) do
      if v.LoginQueueText and v.LoginQueueText ~= "" then
        LogDebug("LoginQueuePage", v.LoginQueueText)
        TextContentTable[TipsNum] = v.LoginQueueText
        TipsNum = TipsNum + 1
      end
    end
    self.RefreshTextContentTimer = TimerMgr:AddTimeTask(0, self.RefreshTipsTime or 1, 0, function()
      local Seed = math.random(1, TipsNum)
      Valid = TextContentTable[Seed] and self.Text_Content and self.Text_Content:SetText(TextContentTable[Seed])
    end)
  end
end
function LoginQueuePage:OnClose()
  if self.RefreshQueueInfoTimer then
    self.RefreshQueueInfoTimer:EndTask()
    self.RefreshQueueInfoTimer = nil
  end
  if self.RefreshTextContentTimer then
    self.RefreshTextContentTimer:EndTask()
    self.RefreshTextContentTimer = nil
  end
  Valid = self.Button_Return and self.Button_Return.OnClickEvent:Remove(self, self.OnClickReturn)
end
function LoginQueuePage:OnClickReturn()
  GameFacade:SendNotification(NotificationDefines.Login.NtfPlayerCloseLoginQueuePage)
  self:ClearTimer()
  self:ClosePage()
end
return LoginQueuePage
