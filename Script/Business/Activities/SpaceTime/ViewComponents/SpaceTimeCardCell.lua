local SpaceTimeCardCell = class("SpaceTimeCardCell", PureMVC.ViewComponentPanel)
function SpaceTimeCardCell:InitializeLuaEvent()
  self.clickEvent = LuaEvent.new()
  self.mouseEnterOrleaveEvent = LuaEvent.new()
  self.bSelected = false
  self.status = GlobalEnumDefine.ECardStatus.None
  self.day = 0
  self.itemId = -1
end
function SpaceTimeCardCell:Construct()
  SpaceTimeCardCell.super.Construct(self)
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Add(self, SpaceTimeCardCell.OnOperateBtnClicked)
    self.Btn_Operate.OnHovered:Add(self, SpaceTimeCardCell.OnOperateBtnHovered)
    self.Btn_Operate.OnUnhovered:Add(self, SpaceTimeCardCell.OnOperateBtnUnhovered)
  end
end
function SpaceTimeCardCell:Destruct()
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Remove(self, SpaceTimeCardCell.OnOperateBtnClicked)
    self.Btn_Operate.OnHovered:Remove(self, SpaceTimeCardCell.OnOperateBtnHovered)
    self.Btn_Operate.OnUnhovered:Remove(self, SpaceTimeCardCell.OnOperateBtnUnhovered)
  end
  SpaceTimeCardCell.super.Destruct(self)
end
function SpaceTimeCardCell:OnOperateBtnClicked()
  if not self.bSelected then
    self.clickEvent(self.status, self.day, self.itemId)
  end
end
function SpaceTimeCardCell:SetIsSelect(bSelect)
  self.bSelected = bSelect
  if not self.PS_Mouse or bSelect then
  else
    self.PS_Mouse:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SpaceTimeCardCell:OnOperateBtnHovered()
  if not self.bSelected and self.status == GlobalEnumDefine.ECardStatus.Opened and self.PS_Mouse then
    self.PS_Mouse:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.PS_Mouse:SetReactivate(true)
  end
end
function SpaceTimeCardCell:OnOperateBtnUnhovered()
  if not self.bSelected and self.status == GlobalEnumDefine.ECardStatus.Opened and self.PS_Mouse then
    self.PS_Mouse:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SpaceTimeCardCell:GetClickEvent()
  return self.clickEvent
end
function SpaceTimeCardCell:GetMouseEnterOrLeaveEvent()
end
function SpaceTimeCardCell:InitCard(data, stage)
  self:SetInfo(data, stage)
  if data.quality == GlobalEnumDefine.EItemQuality.Perfect and self.PS_Yellow then
    self.PS_Yellow:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.PS_Yellow:SetReactivate(true)
  end
end
function SpaceTimeCardCell:FlipCard(data)
  if data.quality == GlobalEnumDefine.EItemQuality.Exquisite then
    self:PlayAnimation(self.Anim_Blue, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  elseif data.quality == GlobalEnumDefine.EItemQuality.Superior then
    self:PlayAnimation(self.Anim_Purple, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  elseif data.quality == GlobalEnumDefine.EItemQuality.Perfect then
    self:PlayAnimation(self.Anim_Yellow, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
  self:SetInfo(data)
end
function SpaceTimeCardCell:UpdateCard(data, stage)
  self:SetInfo(data, stage)
end
function SpaceTimeCardCell:SendCard(data)
  self:SetInfo(data)
  self.WidgetSwitcher_State:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function SpaceTimeCardCell:SetInfo(data, stage)
  if data then
    self.status = data.status
    self.day = data.day
    self.itemId = data.itemId
    if self.status == GlobalEnumDefine.ECardStatus.Opened then
      self:UpdateFrontView(data)
    else
      self:UpdateBackView(data)
    end
    self:UpdateWidgetSwitcher(self.status, stage)
    self:SetRedDot(self.status == GlobalEnumDefine.ECardStatus.Activate)
    self:UpdateAnimations(self.status)
  end
end
function SpaceTimeCardCell:UpdateWidgetSwitcher(InStatus, inStage)
  if self.WidgetSwitcher_State then
    if inStage == GlobalEnumDefine.ESpaceTimeStages.Send then
      self.WidgetSwitcher_State:SetVisibility(UE4.ESlateVisibility.Collapsed)
      return
    end
    self.WidgetSwitcher_State:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if InStatus == GlobalEnumDefine.ECardStatus.Opened then
      self.WidgetSwitcher_State:SetActiveWidgetIndex(0)
    elseif InStatus == GlobalEnumDefine.ECardStatus.Expire then
      self.WidgetSwitcher_State:SetActiveWidgetIndex(1)
    else
      self.WidgetSwitcher_State:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
function SpaceTimeCardCell:UpdateFrontView(data)
  if self.CP_CardBack then
    self.CP_CardBack:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.CP_CardFront then
    self.CP_CardFront:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Img_Icon then
    self:SetImageByTexture2D(self.Img_Icon, data.image)
  end
  if self.Text_Name then
    self.Text_Name:SetText(data.name)
  end
  if self.Img_FrontQuality_1 then
    self.Img_FrontQuality_1:SetColorAndOpacity(self.ImageFrontQualityArray:Get(data.quality + 1))
  end
  if self.Img_FrontQuality_2 then
    self.Img_FrontQuality_2:SetColorAndOpacity(self.ImageQualityArray:Get(data.quality + 1))
  end
  if self.Img_FlushQuality then
    self.Img_FlushQuality:SetColorAndOpacity(self.FlushQualityArray:Get(data.quality + 1))
  end
  if self.Text_Front_Day then
    self.Text_Front_Day:SetText("0" .. data.day)
    self.Text_Front_Day:SetColorAndOpacity(self.TextQualityArray:Get(data.quality + 1))
  end
  if self.Text_Name then
    self.Text_Name:SetText(data.name)
  end
  if self.WS_Quality then
    self.WS_Quality:SetActiveWidgetIndex(data.quality)
  end
end
function SpaceTimeCardCell:UpdateBackView(data)
  if self.CP_CardBack then
    self.CP_CardBack:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.CP_CardFront then
    self.CP_CardFront:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.Img_BackQuality_1 then
    self.Img_BackQuality_1:SetColorAndOpacity(self.ImageQualityArray:Get(data.quality + 1))
  end
  if self.Img_BackQuality_2 then
    self.Img_BackQuality_2:SetColorAndOpacity(self.ImageQualityArray:Get(data.quality + 1))
  end
  if self.Text_Back_Day then
    self.Text_Back_Day:SetText("DAY.0" .. data.day)
  end
  if self.Img_Gray then
    local expire = data.status == GlobalEnumDefine.ECardStatus.Expire
    self.Img_Gray:SetVisibility(expire and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function SpaceTimeCardCell:SetRedDot(show)
  if self.RedDot then
    self.RedDot:SetVisibility(show and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function SpaceTimeCardCell:UpdateAnimations(status)
  if status == GlobalEnumDefine.ECardStatus.Activate then
    if self.PS_Kelingqu then
      self.PS_Kelingqu:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PS_Kelingqu:SetReactivate(true)
    end
  elseif self.PS_Kelingqu then
    self.PS_Kelingqu:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SpaceTimeCardCell:CollapsedEmitter()
  if self.PS_Mouse then
    self.PS_Mouse:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.PS_Yellow then
    self.PS_Yellow:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return SpaceTimeCardCell
