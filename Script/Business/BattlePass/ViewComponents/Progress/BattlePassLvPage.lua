local BattlePassLvPage = class("BattlePassLvPage", PureMVC.ViewComponentPage)
local BattlePassLvMediator = require("Business/BattlePass/Mediators/BattlePassLvMediator")
function BattlePassLvPage:ListNeededMediators()
  return {BattlePassLvMediator}
end
function BattlePassLvPage:InitializeLuaEvent()
  self.lvOperateEvent = LuaEvent.new()
  self.lvBuyEvent = LuaEvent.new()
  self.widgetArray = {}
end
function BattlePassLvPage:OnOpen(luaOpenData, nativeOpenData)
  if self.Button_Buy then
    self.Button_Buy.OnClickEvent:Add(self, self.OnBtBuyLvClick)
  end
  if self.Button_F5 then
    self.Button_F5.OnPMButtonClicked:Add(self, self.OnBtSubFiveClick)
  end
  if self.Button_F1 then
    self.Button_F1.OnPMButtonClicked:Add(self, self.OnBtSubOneClick)
  end
  if self.Button_A1 then
    self.Button_A1.OnPMButtonClicked:Add(self, self.OnBtAddOneClick)
  end
  if self.Button_A5 then
    self.Button_A5.OnPMButtonClicked:Add(self, self.OnBtAddFiveClick)
  end
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Add(self, self.OnBtClose)
  end
  if self.ScrollBox_Item then
    local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ScrollBox_Item)
    self.originSize = canvasSlot:GetSize()
    self.spacing = self.DynamicEntryBox_Items.EntrySpacing
  end
end
function BattlePassLvPage:OnShow(luaOpenData, nativeOpenData)
end
function BattlePassLvPage:OnClose()
  if self.Button_Buy then
    self.Button_Buy.OnClickEvent:Remove(self, self.OnBtBuyLvClick)
  end
  if self.Button_F5 then
    self.Button_F5.OnPMButtonClicked:Remove(self, self.OnBtSubFiveClick)
  end
  if self.Button_F1 then
    self.Button_F1.OnPMButtonClicked:Remove(self, self.OnBtSubOneClick)
  end
  if self.Button_A1 then
    self.Button_A1.OnPMButtonClicked:Remove(self, self.OnBtAddOneClick)
  end
  if self.Button_A5 then
    self.Button_A5.OnPMButtonClicked:Remove(self, self.OnBtAddFiveClick)
  end
  if self.Button_Esc then
    self.Button_Esc.OnClickEvent:Remove(self, self.OnBtClose)
  end
end
function BattlePassLvPage:LuaHandleKeyEvent(key, inputEvent)
  return self.Button_Esc:MonitorKeyDown(key, inputEvent)
end
function BattlePassLvPage:OnBtBuyLvClick()
  self.lvBuyEvent()
  ViewMgr:ClosePage(self)
end
function BattlePassLvPage:OnBtSubFiveClick()
  self.lvOperateEvent(-BattlePassLvMediator.BIG)
end
function BattlePassLvPage:OnBtSubOneClick()
  self.lvOperateEvent(-BattlePassLvMediator.SMALL)
end
function BattlePassLvPage:OnBtAddOneClick()
  self.lvOperateEvent(BattlePassLvMediator.SMALL)
end
function BattlePassLvPage:OnBtAddFiveClick()
  self.lvOperateEvent(BattlePassLvMediator.BIG)
end
function BattlePassLvPage:OnBtClose()
  ViewMgr:ClosePage(self)
end
function BattlePassLvPage:UpdateItemList(data)
  if self.DynamicEntryBox_Items then
    local prizeNum = #data
    local widgetNum = self.DynamicEntryBox_Items:GetNumEntries()
    if prizeNum > widgetNum then
      local extraEntryNum = prizeNum - widgetNum
      for index = 1, extraEntryNum do
        local widget = self.DynamicEntryBox_Items:BP_CreateEntry()
        table.insert(self.widgetArray, widget)
      end
    end
    local found = 0
    for index = 1, prizeNum do
      self.widgetArray[index]:UpdateView(data[index])
      self.widgetArray[index]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      found = index
    end
    for index = found + 1, #self.widgetArray do
      if self.widgetArray[index] then
        self.widgetArray[index]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    if self.ScrollBox_Item then
      local canvasSlot = UE4.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ScrollBox_Item)
      if prizeNum < 6 then
        canvasSlot:SetSize(UE4.FVector2D(self.ChildWidth * prizeNum + (prizeNum - 1) * self.spacing.X, self.originSize.Y))
      else
        canvasSlot:SetSize(self.originSize)
      end
    end
  end
end
function BattlePassLvPage:UpdateCost(data)
  if self.Text_Tip_Num then
    self.Text_Tip_Num:SetText(data.num)
  end
  if self.Button_Buy then
    self.Button_Buy:SetPanelName(data.cost)
  end
  if self.Text_Add then
    self.Text_add:SetText(data.add)
  end
end
function BattlePassLvPage:UpdateButtonState(curLevel, targetLevel, LevelMax)
  if self.Button_F5 then
    self.Button_F5:SetIsEnabled(targetLevel - curLevel > 1 and true or false)
  end
  if self.Button_F1 then
    self.Button_F1:SetIsEnabled(targetLevel - curLevel > 1 and true or false)
  end
  if self.Button_A1 then
    self.Button_A1:SetIsEnabled(targetLevel < LevelMax and true or false)
  end
  if self.Button_A5 then
    self.Button_A5:SetIsEnabled(targetLevel < LevelMax and true or false)
  end
end
return BattlePassLvPage
