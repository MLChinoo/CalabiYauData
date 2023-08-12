local LotteryTransitionPage = class("LotteryTransitionPage", PureMVC.ViewComponentPage)
local LotteryTransitionMediator = require("Business/Lottery/Mediators/LotteryTransitionMediator")
function LotteryTransitionPage:ListNeededMediators()
  return {LotteryTransitionMediator}
end
function LotteryTransitionPage:InitializeLuaEvent()
  self.actionOnStartTransition = LuaEvent.new(seqId)
  self.actionOnReachCircle = LuaEvent.new()
  self.actionOnSkip = LuaEvent.new()
end
function LotteryTransitionPage:Destruct()
  LotteryTransitionPage.super.Destruct(self)
end
function LotteryTransitionPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("LotteryTransitionPage", "Lua implement OnOpen")
  if self.Button_Skip then
    self.Button_Skip.OnClickEvent:Add(self, self.OnClickSkip)
  end
  if self.Button_Continue then
    self.Button_Continue.OnClicked:Add(self, self.OnClickContinue)
  end
  if self.LotteryCircleTagName then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):SetPrintGuardBar(self.LotteryCircleTagName)
  end
  if self.TransSequenceId then
    self.hasEnd = false
    self.actionOnStartTransition(self.TransSequenceId)
  end
  self.bLotteryEffectFinish = false
end
function LotteryTransitionPage:OnClose()
  if self.Button_Skip then
    self.Button_Skip.OnClickEvent:Remove(self, self.OnClickSkip)
  end
  if self.Button_Continue then
    self.Button_Continue.OnClicked:Remove(self, self.OnClickContinue)
  end
  self:ClearHandle()
end
function LotteryTransitionPage:EnterEndProcess()
  LogDebug("LotteryTransitionPage", "Start end process")
  self.bLotteryEffectFinish = true
  if self.Finished then
    self:PlayWidgetAnimationWithCallBack("Finished", {
      self,
      function()
        if self.Finished_last then
          self:PlayAnimation(self.Finished_last, 0, 0)
        end
      end
    })
  end
end
function LotteryTransitionPage:OnClickSkip()
  LogInfo("LotteryTransitionPage", "On click skip")
  self.actionOnSkip()
  ViewMgr:ClosePage(self)
end
function LotteryTransitionPage:OnClickContinue()
  LogInfo("LotteryTransitionPage", "On click continue")
  if self.bLotteryEffectFinish then
    self.actionOnSkip()
    ViewMgr:ClosePage(self)
  end
end
function LotteryTransitionPage:ClearHandle()
  if self.ballShowTask then
    self.ballShowTask:EndTask()
    self.ballShowTask = nil
  end
end
function LotteryTransitionPage:LuaHandleKeyEvent(key, inputEvent)
  local ret = false
  if self.Button_Skip and not ret then
    ret = self.Button_Skip:MonitorKeyDown(key, inputEvent)
  end
  return ret
end
return LotteryTransitionPage
