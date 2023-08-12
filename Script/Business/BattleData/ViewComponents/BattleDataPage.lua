local BattleDataPage = class("BattleDataPage", PureMVC.ViewComponentPage)
local BattleDataMediator = require("Business/BattleData/Mediators/BattleDataMediator")
local Valid
function BattleDataPage:ListNeededMediators()
  return {BattleDataMediator}
end
function BattleDataPage:Construct()
  BattleDataPage.super.Construct(self)
  local SettingCombatProxy = GameFacade:RetrieveProxy(ProxyNames.SettingCombatProxy)
  local isInGame = SettingCombatProxy:CheckIsInGame()
  if not isInGame or self.IsOpened then
    return nil
  end
  local settingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    self.BattleDataText = ""
    self.ShowMouseText = ""
    self.ShowTabText = ""
    Valid = self.Image_Button and self.Image_Button:SetRenderTransformAngle(0)
    self:CleanCollapsedTimer()
    self.CollapsedTimer = TimerMgr:AddTimeTask(self.DelayCollapsedTime or 3, 0, 1, function()
      self:CollapsedBattleData()
      self.CollapsedTimer = nil
    end)
  else
    self.BattleDataText = settingInputUtilProxy:GetKeyByInputName("BattleData")
    self.ShowMouseText = settingInputUtilProxy:GetKeyByInputName("ShowMouse")
    self.ShowTabText = settingInputUtilProxy:GetKeyByInputName("Scoreboard")
  end
  Valid = self.Text_ButtonTip_BattleData and self.Text_ButtonTip_BattleData:SetText(self.BattleDataText)
  Valid = self.Text_ButtonTip_ShowMouse and self.Text_ButtonTip_ShowMouse:SetText(self.ShowMouseText)
  GameFacade:SendNotification(NotificationDefines.BattleData.UpdatePanelReqCmd, self)
  Valid = self.CanvasPanel_BattleData and self.CanvasPanel_BattleData:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  Valid = self.Button and self.Button.OnClicked:Add(self, self.ButtonOnClicked)
end
function BattleDataPage:Destruct()
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  self.IsOpened = nil
  Valid = self.Button and self.Button.OnClicked:Remove(self, self.ButtonOnClicked)
  self:CleanCollapsedTimer()
  BattleDataPage.super.Destruct(self)
end
function BattleDataPage:CleanCollapsedTimer()
  if self.CollapsedTimer then
    self.CollapsedTimer:EndTask()
    self.CollapsedTimer = nil
  end
end
function BattleDataPage:ButtonOnClicked()
  self:CleanCollapsedTimer()
  if self.CanvasPanel_BattleData:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
    Valid = self.CanvasPanel_BattleData and self.CanvasPanel_BattleData:SetVisibility(UE4.ESlateVisibility.Collapsed)
    Valid = self.Image_Button and self.Image_Button:SetRenderTransformAngle(180)
  else
    Valid = self.CanvasPanel_BattleData and self.CanvasPanel_BattleData:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    Valid = self.Image_Button and self.Image_Button:SetRenderTransformAngle(0)
  end
end
function BattleDataPage:CollapsedBattleData()
  Valid = self.CanvasPanel_BattleData and self.CanvasPanel_BattleData:SetVisibility(UE4.ESlateVisibility.Collapsed)
  Valid = self.Image_Button and self.Image_Button:SetRenderTransformAngle(180)
end
function BattleDataPage:LuaHandleKeyEvent(key, inputEvent)
  if UE4.UKismetInputLibrary.Key_GetDisplayName(key) == self.BattleDataText and inputEvent == UE4.EInputEvent.IE_Pressed then
    if self.CanvasPanel_BattleData and self.CanvasPanel_BattleData:GetVisibility() == UE4.ESlateVisibility.SelfHitTestInvisible then
      self.CanvasPanel_BattleData:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.CanvasPanel_BattleData:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    return true
  end
  return false
end
function BattleDataPage:Init(AllBattleDataInfo)
  if self.IsOpened then
    return nil
  end
  self.IsOpened = true
  Valid = self.DynamicEntryBox and self.DynamicEntryBox:Reset(true)
  local BDItem
  for index, BattleDataInfo in pairs(AllBattleDataInfo or {}) do
    BDItem = nil
    BDItem = self.DynamicEntryBox and self.DynamicEntryBox:BP_CreateEntry()
    Valid = BDItem and BDItem:Init(BattleDataInfo)
  end
end
return BattleDataPage
