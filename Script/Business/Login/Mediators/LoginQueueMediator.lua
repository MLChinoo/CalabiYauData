local LoginQueueMediator = class("LoginQueueMediator", PureMVC.Mediator)
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
function LoginQueueMediator:ListNotificationInterests()
  return {
    NotificationDefines.Login.RefreshLoginQueueInfo
  }
end
function LoginQueueMediator:HandleNotification(notification)
  local Name = notification:GetName()
  local Body = notification:GetBody()
  local Type = notification:GetType()
  local LoginQueuePage = self:GetViewComponent()
  if Name == NotificationDefines.Login.RefreshLoginQueueInfo then
    if Body.IsCanIn then
      LoginQueuePage:ClearTimer()
      TimerMgr:AddTimeTask(2, 0, 1, function()
        _G.g_LuaBridgeSubsystem:ReqLobbyLogin()
        LoginQueuePage:ClosePage()
      end)
    elseif Body.info then
      LoginQueuePage:RefreshPage(Body.info)
    end
  end
end
function LoginQueueMediator:OnViewComponentPagePreOpen(luaData, originOpenData)
end
function LoginQueueMediator:OnViewComponentPagePostOpen(luaData, originOpenData)
end
return LoginQueueMediator
