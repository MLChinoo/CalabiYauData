local OperateScreen = class("OperateScreen", PureMVC.ViewComponentPage)
local OperateScreenMediator = require("Business/Lottery/Mediators/OperateScreenMediator")
function OperateScreen:ListNeededMediators()
  return {OperateScreenMediator}
end
function OperateScreen:InitOperationDesk()
  self:HideUWidget(self)
  if self.ShowTask then
    self.ShowTask:EndTask()
  end
  self.ShowTask = TimerMgr:AddTimeTask(1, 0, 1, function()
    self:ShowOperationDesk()
    self.ShowTask = nil
  end)
end
function OperateScreen:ShowOperationDesk()
  if self.Ani_Open then
    self:PlayWidgetAnimationWithCallBack("Ani_Open", {
      self,
      self.EnableInput
    })
  end
  self:ShowUWidget(self)
end
function OperateScreen:Destrcut()
  if self.ShowTask then
    self.ShowTask:EndTask()
    self.ShowTask = nil
  end
  OperateScreen.super.Destrcut(self)
end
function OperateScreen:EnableInput()
  local lotteryProxy = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy)
  if lotteryProxy:GetIsInLottery() then
    lotteryProxy:SetLotteryStatus(UE4.ELotteryState.PlayingBall)
  end
end
return OperateScreen
