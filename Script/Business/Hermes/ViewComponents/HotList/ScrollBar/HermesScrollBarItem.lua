local HermesScrollBarItem = class("HermesScrollBarItem", PureMVC.ViewComponentPanel)
local Valid
function HermesScrollBarItem:InitializeLuaEvent()
  self.clickItemEvent = LuaEvent.new()
  self.TimeUpEvent = LuaEvent.new()
end
function HermesScrollBarItem:Init(ItemIndex)
  self.ItemIndex = ItemIndex
end
function HermesScrollBarItem:SetState(State)
  if State == GlobalEnumDefine.EHermesScrollBarStateType.Default then
    self:SetPercent(0)
    if self.scrollHandle then
      self.scrollHandle:EndTask()
      self.scrollHandle = nil
      self.CurPercent = 0
    end
  elseif State == GlobalEnumDefine.EHermesScrollBarStateType.Working then
    self.CurPercent = 0
    local TimerPeriod = 0.01
    self.scrollHandle = TimerMgr:AddTimeTask(0, TimerPeriod, 0, function()
      if self.CurPercent >= 1 and self.scrollHandle then
        self.scrollHandle:EndTask()
        self.scrollHandle = nil
        self.TimeUpEvent(self.ItemIndex)
        self.CurPercent = 0
      end
      self:SetPercent(self.CurPercent)
      self.CurPercent = self.CurPercent + (self.TimeInterval or 1.0E-4)
    end)
  elseif State == GlobalEnumDefine.EHermesScrollBarStateType.Pause then
    if self.scrollHandle then
      self.scrollHandle:PauseTask()
    end
  elseif State == GlobalEnumDefine.EHermesScrollBarStateType.UnPause and self.scrollHandle then
    self.scrollHandle:UnPauseTask()
  end
end
function HermesScrollBarItem:SetPercent(ProgressValue)
  Valid = self.ProgressBar and self.ProgressBar:SetPercent(ProgressValue)
end
function HermesScrollBarItem:Construct()
  HermesScrollBarItem.super.Construct(self)
  Valid = self.Button and self.Button.OnClicked:Add(self, self.OnClickedBtn)
  Valid = self.Button and self.Button.OnHovered:Add(self, self.OnHoveredBtn)
  Valid = self.Button and self.Button.OnUnhovered:Add(self, self.OnUnhoveredBtn)
  if self.scrollHandle then
    self.scrollHandle:EndTask()
    self.scrollHandle = nil
    self.CurPercent = 0
  end
  Valid = self.Image_Hovered and self.Image_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function HermesScrollBarItem:Destruct()
  Valid = self.Button and self.Button.OnClicked:Remove(self, self.OnClickedBtn)
  Valid = self.Button and self.Button.OnHovered:Remove(self, self.OnHoveredBtn)
  Valid = self.Button and self.Button.OnUnhovered:Remove(self, self.OnUnhoveredBtn)
  if self.scrollHandle then
    self.scrollHandle:EndTask()
    self.scrollHandle = nil
    self.CurPercent = 0
  end
  HermesScrollBarItem.super.Destruct(self)
end
function HermesScrollBarItem:OnClickedBtn()
  self.clickItemEvent(self.ItemIndex)
end
function HermesScrollBarItem:OnHoveredBtn()
  Valid = self.Image_Hovered and self.Image_Hovered:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function HermesScrollBarItem:OnUnhoveredBtn()
  Valid = self.Image_Hovered and self.Image_Hovered:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return HermesScrollBarItem
