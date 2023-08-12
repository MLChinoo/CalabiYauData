local PendingPage = class("PendingPage", PureMVC.ViewComponentPage)
function PendingPage:ListNeededMediators()
  return {}
end
function PendingPage:InitializeLuaEvent()
end
function PendingPage:LuaHandleKeyEvent(key, inputEvent)
  return true
end
function PendingPage:OnOpen(luaOpenData, nativeOpenData)
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, true)
  self:PlayAnimation(self.Anim_TurnCircle, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
  if luaOpenData and luaOpenData.Time and luaOpenData.Time > 0 then
    local Fun = luaOpenData.funcHandle
    if nil == Fun then
      function Fun()
        ViewMgr:ClosePage(self)
        local msgCode = luaOpenData.MsgCode
        if msgCode and msgCode > 0 then
          GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, msgCode)
        end
      end
    end
    self.LoadingTask = TimerMgr:AddTimeTask(luaOpenData.Time, 0.0, 0, Fun)
  end
  if not self.LoadingTask then
    local closeTime = self.DefaultCloseTime or 5
    self.LoadingTask = TimerMgr:AddTimeTask(closeTime, 0.0, 0, function()
      ViewMgr:ClosePage(self)
      local msgCode = 1
      if luaOpenData and luaOpenData.MsgCode then
        msgCode = luaOpenData.MsgCode
      end
      if msgCode > 0 then
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, msgCode)
      end
    end)
  end
end
function PendingPage:OnClose()
  if self.LoadingTask then
    self.LoadingTask:EndTask()
    self.LoadingTask = nil
  end
  self:StopAnimation(self.Anim_TurnCircle)
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, false)
end
return PendingPage
