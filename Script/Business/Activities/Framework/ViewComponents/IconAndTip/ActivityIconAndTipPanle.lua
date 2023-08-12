local ActivityIconAndTipPanle = class("ActivityIconAndTipPanle", PureMVC.ViewComponentPanel)
function ActivityIconAndTipPanle:InitializeLuaEvent()
  self.clickEvent = LuaEvent.new()
  self.mouseEnterOrleaveEvent = LuaEvent.new()
  self.bSelected = false
  self.status = GlobalEnumDefine.ECardStatus.None
  self.day = 0
end
function ActivityIconAndTipPanle:Construct()
  ActivityIconAndTipPanle.super.Construct(self)
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Add(self, ActivityIconAndTipPanle.OnMouseClick)
    self.Btn_Operate.OnHovered:Add(self, ActivityIconAndTipPanle.OnMouseEnter)
    self.Btn_Operate.OnUnhovered:Add(self, ActivityIconAndTipPanle.OnMouseLeave)
  end
end
function ActivityIconAndTipPanle:Destruct()
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Remove(self, ActivityIconAndTipPanle.OnMouseClick)
    self.Btn_Operate.OnHovered:Remove(self, ActivityIconAndTipPanle.OnMouseEnter)
    self.Btn_Operate.OnUnhovered:Remove(self, ActivityIconAndTipPanle.OnMouseLeave)
  end
  ActivityIconAndTipPanle.super.Destruct(self)
end
function ActivityIconAndTipPanle:OnMouseClick()
  if not self.bSelected then
    self.clickEvent(self.day)
  end
end
function ActivityIconAndTipPanle:OnMouseEnter()
end
function ActivityIconAndTipPanle:OnMouseLeave()
end
function ActivityIconAndTipPanle:GetClickEvent()
end
function ActivityIconAndTipPanle:GetMouseEnterOrLeaveEvent()
end
function ActivityIconAndTipPanle:InitInfo(data)
end
return ActivityIconAndTipPanle
