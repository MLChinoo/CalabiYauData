local SpaceTimePage = class("SpaceTimePage", PureMVC.ViewComponentPage)
local SpaceTimeMediator = require("Business/Activities/SpaceTime/Mediators/SpaceTimeMediator")
function SpaceTimePage:ListNeededMediators()
  return {SpaceTimeMediator}
end
function SpaceTimePage:InitializeLuaEvent()
  self.updateViewEvent = LuaEvent.new()
  self.spaceTimeStage = GlobalEnumDefine.ESpaceTimeStages.None
  self.spaceTimeDay = -1
  self.cardWidgets = {}
  self.currentSelectDay = -1
  self.playSendAnim = false
  self:InitializeWidgets()
  self.strLocked = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "SpaceTimeLocked")
  self.strExpire = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "SpaceTimeExpire")
end
function SpaceTimePage:OnOpen(luaOpenData, nativeOpenData)
  self:updateViewEvent()
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Add(self, self.OnEscBtnClick)
  end
  if self.Bt_Info then
    self.Bt_Info.OnHovered:Add(self, SpaceTimePage.OnHovered)
  end
  if self.Bt_Info then
    self.Bt_Info.OnUnhovered:Add(self, SpaceTimePage.OnUnhovered)
  end
  if self.Bt_Send then
    self.Bt_Send.OnClickEvent:Add(self, SpaceTimePage.OnSendBtClick)
  end
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):PauseStateMachine()
end
function SpaceTimePage:OnClose()
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Remove(self, self.OnEscBtnClick)
  end
  if self.Bt_Info then
    self.Bt_Info.OnHovered:Remove(self, SpaceTimePage.OnHovered)
  end
  if self.Bt_Info then
    self.Bt_Info.OnUnhovered:Remove(self, SpaceTimePage.OnUnhovered)
  end
  if self.Bt_Send then
    self.Bt_Send.OnClickEvent:Remove(self, SpaceTimePage.OnSendBtClick)
  end
  local animName = "Anim_Day_" .. self.currentSelectDay
  if self[animName] then
    self:UnbindAllFromAnimationFinished(self[animName])
  end
  GameFacade:RetrieveProxy(ProxyNames.ApartmentStateMachineProxy):ReStartStateMachine()
end
function SpaceTimePage:OnHovered()
  if self.CP_Info then
    self.CP_Info:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SpaceTimePage:OnUnhovered()
  if self.CP_Info then
    self.CP_Info:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SpaceTimePage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnEscBtnClick()
  end
  if UE4.UKismetInputLibrary.Key_IsMouseButton(key) then
    return false
  end
  return true
end
function SpaceTimePage:SetSpaceTimeStage(inStage)
  self.spaceTimeStage = inStage
end
function SpaceTimePage:SetSpaceTimeDay(inDay, sendDay)
  self.spaceTimeDay = inDay
  if inDay < sendDay then
    self.Pyramid:PlayPyramidAnimation(inDay)
  else
    self.Pyramid:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Img_Hero:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if inDay == sendDay and self.PS_BlackHole_1 then
      self.PS_BlackHole_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.PS_BlackHole_1:SetReactivate(true)
    end
  end
end
function SpaceTimePage:InitializeWidgets()
  self.cardWidgets = {}
  if self.CP_CardList then
    for index = 1, self.CP_CardList:GetChildrenCount() do
      local widget = self.CP_CardList:GetChildAt(index - 1)
      if widget then
        widget:GetClickEvent():Add(self.CardClick, self)
        self.cardWidgets[index] = widget
      end
    end
  end
end
function SpaceTimePage:InitCardWidget(inCardDatas, inSendCard)
  self:SetWidgetDisplay(inSendCard)
  if inSendCard then
    if self.Card_Send then
      self.Card_Send:InitCard(inSendCard, self.spaceTimeStage)
    end
    if self.PS_BlackHole_1 then
      self.PS_BlackHole_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
    return
  end
  if inCardDatas then
    for index, value in ipairs(inCardDatas) do
      local widget = self.cardWidgets[index]
      if widget then
        widget:InitCard(value, self.spaceTimeStage)
      end
    end
  end
end
function SpaceTimePage:FlipCardWidget(inCardData)
  local widget = self.cardWidgets[inCardData.day]
  if widget then
    widget:FlipCard(inCardData)
  end
end
function SpaceTimePage:SendCardWidget(inCardDatas)
  if self.Card_Send then
    self.Card_Send:SendCard(inCardDatas)
  end
  for index, widget in ipairs(self.cardWidgets) do
    if widget then
      widget:CollapsedEmitter()
    end
  end
  self.playSendAnim = true
  local animName = "Anim_Day_" .. self.currentSelectDay
  if self[animName] then
    self:BindToAnimationFinished(self[animName], {
      self,
      self.FlyAnimFinished
    })
    self:PlayAnimation(self[animName], 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
end
function SpaceTimePage:UpdateCardWidget(currentCardData)
  if currentCardData then
    local widget = self.cardWidgets[currentCardData.day]
    if widget then
      widget:UpdateCard(currentCardData, self.spaceTimeStage)
    end
  end
end
function SpaceTimePage:SetWidgetDisplay(inSend)
  if self.Img_BG_SignIn then
    self.Img_BG_SignIn:SetVisibility(not inSend and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.Img_BG_Complete then
    self.Img_BG_Complete:SetVisibility(inSend and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.CP_SignIn then
    self.CP_SignIn:SetVisibility(not inSend and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.CP_Complete then
    self.CP_Complete:SetVisibility(inSend and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function SpaceTimePage:CardClick(inStatus, inDay, inItemId)
  if self.playSendAnim then
    return
  end
  if inStatus == GlobalEnumDefine.ECardStatus.Activate then
    GameFacade:SendNotification(NotificationDefines.Activities.SpaceTime.SpaceTimeOperatorCmd, {day = inDay}, NotificationDefines.Activities.SpaceTime.CardOpenReqType)
  elseif inStatus == GlobalEnumDefine.ECardStatus.Opened then
    if self.spaceTimeStage == GlobalEnumDefine.ESpaceTimeStages.Flip then
      ViewMgr:OpenPage(self, UIPageNameDefine.SpaceTimeCardDetailPage, false, {itemId = inItemId})
    elseif self.spaceTimeStage == GlobalEnumDefine.ESpaceTimeStages.Send then
      if self.cardWidgets[self.currentSelectDay] then
        self.cardWidgets[self.currentSelectDay]:SetIsSelect(false)
      end
      self.currentSelectDay = inDay
      if self.cardWidgets[self.currentSelectDay] then
        self.cardWidgets[self.currentSelectDay]:SetIsSelect(true)
        if self.Bt_Send then
          self.Bt_Send:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        end
      end
    end
  elseif inStatus == GlobalEnumDefine.ECardStatus.Expire then
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, self.strExpire)
  elseif inStatus == GlobalEnumDefine.ECardStatus.Locked then
    local lockDay = inDay - self.spaceTimeDay
    local str = lockDay .. self.strLocked
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, str)
  end
end
function SpaceTimePage:OnSendBtClick()
  if self.playSendAnim then
    return
  end
  if self.spaceTimeStage == GlobalEnumDefine.ESpaceTimeStages.Send and -1 ~= self.currentSelectDay then
    GameFacade:SendNotification(NotificationDefines.Activities.SpaceTime.SpaceTimeOperatorCmd, {
      day = self.currentSelectDay
    }, NotificationDefines.Activities.SpaceTime.CardSendReqType)
  end
end
function SpaceTimePage:FlyAnimFinished()
  self:PlayAnimation(self.Anim_Complete, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self:UnbindAllFromAnimationFinished(self["Anim_Day_" .. self.currentSelectDay])
end
function SpaceTimePage:OnEscBtnClick()
  ViewMgr:ClosePage(self)
end
function SpaceTimePage:UpdateBlackHole()
end
return SpaceTimePage
