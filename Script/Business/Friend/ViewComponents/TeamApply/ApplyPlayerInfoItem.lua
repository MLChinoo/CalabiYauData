local ApplyPlayerInfoItem = class("ApplyPlayerInfoItem", PureMVC.ViewComponentPanel)
function ApplyPlayerInfoItem:InitializeLuaEvent()
  ApplyPlayerInfoItem.super.InitializeLuaEvent(self)
  self.bStartTime = false
  self.removeTime = 15
  self.bRead = false
  self.bIgnore = false
  self.bSelect = false
  self.countDownFunc = nil
  self:HideUWidget(self.CanvasPanel_Select)
end
function ApplyPlayerInfoItem:UpdatePlayerInfo(infoData)
  self.infoData = infoData
  if self.TextBlock_Name then
    self.TextBlock_Name:SetText(infoData.PlayerNickName)
  end
  if self.TextBlock_Name_1 then
    self.TextBlock_Name_1:SetText(infoData.PlayerNickName)
  end
  if self.Image_Rank and self.Image_RankLevel and self.Text_Rank then
    if infoData.stars then
      local _, divisionCfg = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivision(infoData.stars)
      if divisionCfg then
        self:SetImageByPaperSprite(self.Image_Rank, divisionCfg.IconDivisionS)
        self:SetImageByPaperSprite(self.Image_RankLevel, divisionCfg.IconDivisionLevel)
        self.Text_Rank:SetText(divisionCfg.Name)
      else
        LogError("GroupMemberItem", "Division config error")
      end
    elseif infoData.RankName and infoData.RankIcon then
      self.Text_Rank:SetText(infoData.RankName)
      if not infoData.RankIcon:IsNull() then
        self:SetImageByPaperSprite(self.Image_Rank, infoData.RankIcon)
        self.Image_Rank:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Image_Rank:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if infoData.RankLevelIcon and not infoData.RankLevelIcon:IsNull() then
        self:SetImageByPaperSprite(self.Image_RankLevel, infoData.RankLevelIcon)
        self.Image_RankLevel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        self.Image_RankLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
  self:UpdateReadStatus()
  self:StartRemoveTime()
  self:PlayAnimation(self.PopUp, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function ApplyPlayerInfoItem:SwitchPlayerInfo(index)
  self.WS_PlayerInfo:SetActiveWidgetIndex(index)
end
function ApplyPlayerInfoItem:GetPlayerInfo()
  return self.infoData
end
function ApplyPlayerInfoItem:SetPlayerHeadIcon(icon)
  if self.Img_Icon then
    self:SetImageByTexture2D(self.Img_Icon, icon)
  end
end
function ApplyPlayerInfoItem:SetSelectState(bSelect)
  if self.CanvasPanel_Select == nil then
    return
  end
  if self.bSelect == bSelect then
  elseif bSelect then
    self:PlayAnimation(self.Selected, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    self:ShowUWidget(self.CanvasPanel_Select)
    self:ShowUWidget(self.CanvasPanel_Select_1)
    self.bRead = true
  else
    self:StopAnimation(self.Selected)
    self.ImageBg:SetRenderOpacity(1)
    self:HideUWidget(self.CanvasPanel_Select)
    self:HideUWidget(self.CanvasPanel_Select_1)
  end
  self.bSelect = bSelect
  self:UpdateReadStatus()
end
function ApplyPlayerInfoItem:SetButtonUpFunc(func)
  self.buttonUpFunc = func
end
function ApplyPlayerInfoItem:OnMouseButtonUp(MyGeometry, MouseEvent)
  if self.bSelect == false and type(self.buttonUpFunc) == "function" then
    self.buttonUpFunc(self)
  end
end
function ApplyPlayerInfoItem:SetSelfBeClick()
  if type(self.buttonUpFunc) == "function" then
    self.buttonUpFunc(self)
  end
end
function ApplyPlayerInfoItem:UpdateReadStatus()
  if self.bRead then
    self:HideUWidget(self.Img_Tip)
  else
    self:ShowUWidget(self.Img_Tip)
  end
  if self.Slot then
    local offset = 16
    local margin = UE4.FMargin()
    margin.Right = offset
    margin.Top = 28
    self.Slot:SetPadding(margin)
  end
end
function ApplyPlayerInfoItem:StartRemoveTime()
  if self.bStartTime then
    return
  end
  self.removeTimer = TimerMgr:AddTimeTask(1, 1, 0, function()
    self:PerSecondHandle()
  end)
  self.bStartTime = true
end
function ApplyPlayerInfoItem:PerSecondHandle()
  if self.removeTime <= 0 and self.removeTimer then
    self.removeTimer:EndTask()
    self.bStartTime = false
    GameFacade:SendNotification(NotificationDefines.TeamApply.RemoveItemNtf, self)
    return
  end
  if self.bSelect and self.countDownFunc and type(self.countDownFunc) == "function" then
    self.countDownFunc(self.removeTime)
  end
  self.removeTime = self.removeTime - 1
end
function ApplyPlayerInfoItem:StopRemoveTimer()
  if self.removeTimer then
    self.removeTimer:EndTask()
    self.removeTimer = nil
  end
end
function ApplyPlayerInfoItem:SetIgnoreState(bIgnore)
  self.bIgnore = bIgnore
end
function ApplyPlayerInfoItem:GetIgnoreState()
  return self.bIgnore
end
function ApplyPlayerInfoItem:SetCountDownFunc(countDownFunc)
  self.countDownFunc = countDownFunc
end
function ApplyPlayerInfoItem:OnLuaItemHovered()
  if self.Img_Hovered then
    self:ShowUWidget(self.Img_Hovered)
  end
end
function ApplyPlayerInfoItem:OnLuaItemUnhovered()
  if self.Img_Hovered then
    self:HideUWidget(self.Img_Hovered)
  end
end
function ApplyPlayerInfoItem:OnLuaItemClick()
end
return ApplyPlayerInfoItem
