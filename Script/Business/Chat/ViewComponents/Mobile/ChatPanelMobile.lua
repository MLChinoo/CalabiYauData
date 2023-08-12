local ChatPanelMobile = class("ChatPanelMobile", PureMVC.ViewComponentPanel)
local ChatPanelMobileMediator = require("Business/Chat/Mediators/Mobile/ChatPanelMobileMediator")
function ChatPanelMobile:ListNeededMediators()
  return {ChatPanelMobileMediator}
end
function ChatPanelMobile:InitializeLuaEvent()
  self.actionOnDeleteMsg = LuaEvent.new(ChatPanelMobilePanel)
end
function ChatPanelMobile:Construct()
  ChatPanelMobile.super.Construct(self)
  if RedDotTree then
    RedDotTree:Bind(RedDotModuleDef.ModuleName.GameChat, function(cnt)
      self:UpdateRedDotGameChat(cnt)
    end)
  end
  self.bChatOpen = false
  if self.Btn_Chat then
    self.Btn_Chat.OnPressed:Add(self, self.OnClickChat)
  end
  local GameplayDelegate = GetGamePlayDelegateManager()
  if GameplayDelegate and DelegateMgr then
    self.OnEnabledGameFunctionHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnEnabledGameFunction, self, "OnGameFunctionUpdate")
    self.OnDisableGameFunctionHandle = DelegateMgr:AddDelegate(GameplayDelegate.OnDisableGameFunction, self, "OnGameFunctionUpdate")
  end
end
function ChatPanelMobile:Desctruct()
  if RedDotTree then
    RedDotTree:Unbind(RedDotModuleDef.ModuleName.GameChat)
  end
  if self.timeHandle then
    self.timeHandle:EndTask()
    self.timeHandle = nil
  end
  if self.Btn_Chat then
    self.Btn_Chat.OnPressed:Remove(self, self.OnClickChat)
  end
  local GameplayDelegate = GetGamePlayDelegateManager()
  if GameplayDelegate and DelegateMgr then
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnEnabledGameFunction, self.OnEnabledGameFunctionHandle)
    DelegateMgr:RemoveDelegate(GameplayDelegate.OnDisableGameFunction, self.OnDisableGameFunctionHandle)
  end
  ChatPanelMobile.super.Desctruct(self)
end
function ChatPanelMobile:OnClickChat()
  GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Switch)
end
function ChatPanelMobile:ChangeChatState(isOpen)
  self.bChatOpen = isOpen
  if self.WidgetSwitcher_State then
    self.WidgetSwitcher_State:SetActiveWidgetIndex(self.bChatOpen and 1 or 0)
  end
end
function ChatPanelMobile:GetPanelLoc()
  local location = UE4.USlateBlueprintLibrary.GetLocalTopLeft(self:GetCachedGeometry())
  local size = self:GetDesiredSize()
  local scale = self.RenderTransform.Scale
  return location - (scale - 1) * size / 2, size * scale
end
function ChatPanelMobile:ShowChatCD(duration)
  if self.ChatButtonCD then
    self.ChatButtonCD:StartButtonCD(duration, true)
  end
  if self.WidgetSwitcher_State then
    self.WidgetSwitcher_State:SetRenderOpacity(0.5)
    self.timeHandle = TimerMgr:AddTimeTask(duration, 0, 0, function()
      self.WidgetSwitcher_State:SetRenderOpacity(1.0)
      self.timeHandle = nil
    end)
  end
end
function ChatPanelMobile:UpdateRedDotGameChat(cnt)
  if self.RedDot_Main then
    self.RedDot_Main:SetVisibility(cnt > 0 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ChatPanelMobile:OnGameFunctionUpdate(InOwnerPlayerState, InDiffGameFunctionConfig)
  local PlayerState = self:K2_GetOwningPlayerState()
  if PlayerState then
    local CastPlayerState = PlayerState:Cast(UE4.APMPlayerState)
    if CastPlayerState == InOwnerPlayerState then
      local bDisable = CastPlayerState:IsDisableGameUIFunction(UE4.ECyGameUIFunctionType.GameChat)
      if bDisable then
        self:SetVisibilityPriority(UE4.ESlateVisibilityPriority.Function, UE4.ESlateVisibility.Collapsed)
      else
        self:SetVisibilityPriority(UE4.ESlateVisibilityPriority.Function, UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end
return ChatPanelMobile
