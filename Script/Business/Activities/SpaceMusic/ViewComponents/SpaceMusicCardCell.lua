local SpaceMusicCardCell = class("SpaceMusicCardCell", PureMVC.ViewComponentPanel)
function SpaceMusicCardCell:InitializeLuaEvent()
  self.clickEvent = LuaEvent.new()
  self.status = GlobalEnumDefine.EMusicRewardStatus.None
  self.day = 0
  self.itemId = -1
end
function SpaceMusicCardCell:Construct()
  SpaceMusicCardCell.super.Construct(self)
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Add(self, SpaceMusicCardCell.OnOperateBtnClicked)
    self.Btn_Operate.OnHovered:Add(self, SpaceMusicCardCell.OnOperateBtnHovered)
    self.Btn_Operate.OnUnhovered:Add(self, SpaceMusicCardCell.OnOperateBtnUnhovered)
  end
end
function SpaceMusicCardCell:Destruct()
  if self.Btn_Operate then
    self.Btn_Operate.OnClicked:Remove(self, SpaceMusicCardCell.OnOperateBtnClicked)
    self.Btn_Operate.OnHovered:Remove(self, SpaceMusicCardCell.OnOperateBtnHovered)
    self.Btn_Operate.OnUnhovered:Remove(self, SpaceMusicCardCell.OnOperateBtnUnhovered)
  end
  SpaceMusicCardCell.super.Destruct(self)
end
function SpaceMusicCardCell:OnOperateBtnClicked()
  if not self.bSelected then
    self.clickEvent(self.status, self.day, self.itemId)
  end
end
function SpaceMusicCardCell:OnOperateBtnHovered()
  if self.status ~= GlobalEnumDefine.EMusicRewardStatus.Get and self.Img_Hovered then
    self.Img_Hovered:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SpaceMusicCardCell:OnOperateBtnUnhovered()
  if self.status ~= GlobalEnumDefine.EMusicRewardStatus.Get and self.Img_Hovered then
    self.Img_Hovered:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SpaceMusicCardCell:GetClickEvent()
  return self.clickEvent
end
function SpaceMusicCardCell:InitInfo(inData)
  if inData then
    self.day = inData.day
    self.itemId = inData.id
    if self.Img_Icon then
      self:SetImageByTexture2D(self.Img_Icon, inData.image)
    end
    if inData.cnt > 1 and self.Text_Num then
      self.Text_Num:SetText("X" .. inData.cnt)
      self.Text_Num:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if self.WS_Quality then
      self.WS_Quality:SetActiveWidgetIndex(inData.quality - 2)
    end
    if self.Text_Day then
      local strFewDay = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "FewDays")
      local stringMap = {
        day = inData.day
      }
      local outText = ObjectUtil:GetTextFromFormat(strFewDay, stringMap)
      self.Text_Day:SetText(outText)
      self.Text_Day:SetColorAndOpacity(self.TextQualityArray:Get(inData.quality + 1))
    end
    self:SetStatus(inData.status)
  end
end
function SpaceMusicCardCell:SetStatus(inStatus)
  self.status = inStatus
  if inStatus == GlobalEnumDefine.EMusicRewardStatus.Activate then
    if self.Partical_Activate then
      self.Partical_Activate:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.Partical_Activate:SetReactivate(true)
    end
  elseif self.Partical_Activate then
    self.Partical_Activate:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.CP_Get then
    self.CP_Get:SetVisibility(inStatus == GlobalEnumDefine.EMusicRewardStatus.Get and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return SpaceMusicCardCell
