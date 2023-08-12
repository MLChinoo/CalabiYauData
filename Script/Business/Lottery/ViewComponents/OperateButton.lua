local OperateButton = class("OperateButton", PureMVC.ViewComponentPage)
local PlaceBallMediator = require("Business/Lottery/Mediators/PlaceBallMediator")
local LotteryEnum = require("Business/Lottery/Proxies/LotteryEnumDefine")
function OperateButton:ListNeededMediators()
  return {PlaceBallMediator}
end
function OperateButton:InitOperationDesk()
  if self.ButtonName then
    self:CancelTask()
    if self.AppearDelay then
      self.showButtonTask = TimerMgr:AddTimeTask(self.AppearDelay, 0, 1, function()
        self:ShowButton()
      end)
    end
  end
  if self.Btn_Operate then
    self.Btn_Operate:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  end
end
function OperateButton:ShowButton()
  GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):PlayButtonEffect(self.ButtonName, UE4.EFXButtonState.Appear)
  self:CancelTask()
end
function OperateButton:SetInputEnabled(bEnabled)
  if self.Btn_Operate then
    self.Btn_Operate:SetVisibility(bEnabled and UE4.ESlateVisibility.Visible or UE4.ESlateVisibility.HitTestInvisible)
  end
end
function OperateButton:UpdateButtonState(ballNum)
end
function OperateButton:CancelTask()
  if self.showButtonTask then
    self.showButtonTask:EndTask()
    self.showButtonTask = nil
  end
end
function OperateButton:Construct()
  OperateButton.super.Construct(self)
  self.isHovered = false
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Add(self, self.OnClick)
    self.Btn_Operate.OnHovered:Add(self, self.OnHover)
    self.Btn_Operate.OnUnhovered:Add(self, self.OnUnhover)
    self.Btn_Operate.OnPressed:Add(self, self.OnPress)
    self.Btn_Operate.OnReleased:Add(self, self.OnRelease)
  end
end
function OperateButton:Destruct()
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Remove(self, self.OnClick)
    self.Btn_Operate.OnHovered:Remove(self, self.OnHover)
    self.Btn_Operate.OnUnhovered:Remove(self, self.OnUnhover)
    self.Btn_Operate.OnPressed:Remove(self, self.OnPress)
    self.Btn_Operate.OnReleased:Remove(self, self.OnRelease)
  end
  self:CancelTask()
  OperateButton.super.Destruct(self)
end
function OperateButton:OnClickQuickPlace()
  LogDebug("OperateButton", "On click quick place")
  GameFacade:SendNotification(NotificationDefines.Lottery.SetBallType, LotteryEnum.ballItemType.Null)
end
function OperateButton:OnClickStart()
  LogDebug("OperateButton", "On click Start")
  self:SetInputEnabled(false)
  GameFacade:SendNotification(NotificationDefines.Lottery.TryLotteryCmd)
end
function OperateButton:OnClickClear()
  LogDebug("OperateButton", "On click clear")
  GameFacade:SendNotification(NotificationDefines.Lottery.ClearTypeSet)
end
function OperateButton:OnClickLine()
  LogDebug("OperateButton", "On click line")
  GameFacade:SendNotification(NotificationDefines.Lottery.SetBallType, LotteryEnum.ballItemType.Line)
end
function OperateButton:OnClickCircle()
  LogDebug("OperateButton", "On click circle")
  GameFacade:SendNotification(NotificationDefines.Lottery.SetBallType, LotteryEnum.ballItemType.Circle)
end
function OperateButton:OnClick()
  if self.ButtonName then
    if self.ButtonName == LotteryEnum.operationButtonName.QuickPlace then
      self:OnClickQuickPlace()
    end
    if self.ButtonName == LotteryEnum.operationButtonName.Clear then
      self:OnClickClear()
    end
    if self.ButtonName == LotteryEnum.operationButtonName.Confirm then
      self:OnClickStart()
    end
    if self.ButtonName == LotteryEnum.operationButtonName.Place1 then
      self:OnClickLine()
    end
    if self.ButtonName == LotteryEnum.operationButtonName.Place2 then
      self:OnClickCircle()
    end
  end
end
function OperateButton:OnHover()
  self.isHovered = true
end
function OperateButton:OnUnhover()
  self.isHovered = false
end
function OperateButton:OnPress()
end
function OperateButton:OnRelease()
end
return OperateButton
