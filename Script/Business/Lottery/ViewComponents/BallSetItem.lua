local BallSetItem = class("BallSetItem", PureMVC.ViewComponentPanel)
local LotteryEnum = require("Business/Lottery/Proxies/LotteryEnumDefine")
function BallSetItem:ListNeededMediators()
  return {}
end
function BallSetItem:InitializeLuaEvent()
  self.actionOnSelectBallItem = LuaEvent.new(itemIndex)
  self.actionOnSetItemTypeFinished = LuaEvent.new(itemIndex)
end
function BallSetItem:Construct()
  BallSetItem.super.Construct(self)
  self.curType = LotteryEnum.ballItemType.Null
  self.isSelected = false
  if self.Button_Select then
    self.Button_Select.OnHovered:Add(self, self.HoverItem)
    self.Button_Select.OnUnhovered:Add(self, self.UnhoverItem)
    self.Button_Select.OnClicked:Add(self, self.ClickItem)
  end
  if self.Button_Select_1 then
    self.Button_Select_1.OnHovered:Add(self, self.HoverItem)
    self.Button_Select_1.OnUnhovered:Add(self, self.UnhoverItem)
    self.Button_Select_1.OnClicked:Add(self, self.ClickItem)
  end
end
function BallSetItem:Destruct()
  if self.Button_Select then
    self.Button_Select.OnHovered:Remove(self, self.HoverItem)
    self.Button_Select.OnUnhovered:Remove(self, self.UnhoverItem)
    self.Button_Select.OnClicked:Remove(self, self.ClickItem)
  end
  if self.Button_Select_1 then
    self.Button_Select_1.OnHovered:Remove(self, self.HoverItem)
    self.Button_Select_1.OnUnhovered:Remove(self, self.UnhoverItem)
    self.Button_Select_1.OnClicked:Remove(self, self.ClickItem)
  end
  if self.notifyNextTask then
    self.notifyNextTask:EndTask()
    self.notifyNextTask = nil
  end
  BallSetItem.super.Destruct(self)
end
function BallSetItem:SetItemIndex(index)
  self.itemIndex = index
end
function BallSetItem:SetItemType(itemType, relaItemType)
  LogDebug("BallSetItem", "Set item:%d type:%d", self.itemIndex, itemType or 0)
  self.curType = itemType
  local activeIndex = 0
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if itemType == LotteryEnum.ballItemType.Line then
    if relaItemType == LotteryEnum.ballItemType.Circle then
      activeIndex = 4
    else
      activeIndex = 1
    end
  elseif itemType == LotteryEnum.ballItemType.Circle then
    if relaItemType == LotteryEnum.ballItemType.Line then
      activeIndex = 2
    else
      activeIndex = 3
    end
  elseif not self.isSelected then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.WS_Type then
    local curActive = self.WS_Type:GetActiveWidgetIndex()
    if curActive ~= activeIndex then
      self.WS_Type:SetActiveWidgetIndex(activeIndex)
      if self.saoguang then
        self:PlayAnimation(self.saoguang)
        if self.notifyNextTask then
          self.notifyNextTask:EndTask()
          self.notifyNextTask = nil
        end
        self.notifyNextTask = TimerMgr:AddTimeTask(0.35, 0, 1, function()
          self.actionOnSetItemTypeFinished(self.itemIndex)
        end)
      end
    end
  end
end
function BallSetItem:GetActiveWidgetIndex()
  if self.WS_Type then
    return self.WS_Type:GetActiveWidgetIndex()
  end
  return 1
end
function BallSetItem:HoverItem()
  if self.curType == LotteryEnum.ballItemType.Null then
    return
  end
  if self.BackPlace then
    self.BackPlace:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BackPlace:SetRenderOpacity(0.2)
  end
end
function BallSetItem:UnhoverItem()
  if self.curType == LotteryEnum.ballItemType.Null then
    return
  end
  if self.BackPlace then
    self.BackPlace:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BackPlace:SetRenderOpacity(0)
  end
end
function BallSetItem:ClickItem()
  if self.curType == LotteryEnum.ballItemType.Null then
    return
  end
  LogDebug("BallSetItem", "On click ball item:%d", self.itemIndex)
  if self.curType == LotteryEnum.ballItemType.Line then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):SetLotteryBallType(self.itemIndex, LotteryEnum.ballItemType.Circle)
  else
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):SetLotteryBallType(self.itemIndex, LotteryEnum.ballItemType.Line)
  end
  self.actionOnSelectBallItem(self.itemIndex)
end
function BallSetItem:SetItemSelected(isSelected)
  LogDebug("BallSetItem", "Set item:%d selected:%s", self.itemIndex, tostring(isSelected))
  if self.chuxian then
    self:RemoveWidgetAnimationFinishedCallback("chuxian")
  end
  self.isSelected = isSelected
  if self.curType ~= LotteryEnum.ballItemType.Null or self.isSelected then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.isSelected then
    if self.xiaoshi then
      self:StopAnimation(self.xiaoshi)
    end
    if self.saoguang then
      self:StopAnimation(self.saoguang)
    end
    if self.daiji then
      self:StopAnimation(self.daiji)
    end
    if self.chuxian then
      self:StopAnimation(self.chuxian)
      self:PlayWidgetAnimationWithCallBack("chuxian", {
        self,
        function()
          if self.daiji then
            self:PlayAnimation(self.daiji, 0, 0)
          end
        end
      })
    end
  else
    if self.chuxian then
      self:StopAnimation(self.chuxian)
    end
    if self.daiji then
      self:StopAnimation(self.daiji)
    end
    if self.xiaoshi then
      self:PlayAnimation(self.xiaoshi, 0, 1)
    end
  end
end
function BallSetItem:SetActiveWidgetIndex(activeIndex)
  if self.WS_Type then
    self.WS_Type:SetActiveWidgetIndex(activeIndex)
  end
end
return BallSetItem
