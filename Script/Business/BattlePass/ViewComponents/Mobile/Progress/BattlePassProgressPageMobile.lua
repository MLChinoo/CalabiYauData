local BattlePassProgressPageMobile = class("BattlePassProgressPageMobile", PureMVC.ViewComponentPage)
local BattlePassProgressMediatorMobile = require("Business/BattlePass/Mediators/Mobile/Progress/BattlePassProgressMediatorMobile")
function BattlePassProgressPageMobile:ListNeededMediators()
  return {BattlePassProgressMediatorMobile}
end
function BattlePassProgressPageMobile:InitializeLuaEvent()
  self.itemSelectEvent = LuaEvent.new()
  self.isPreview = false
end
function BattlePassProgressPageMobile:OnOpen(luaOpenData, nativeOpenData)
  if self.ButtonBuyLv then
    self.ButtonBuyLv.OnClickEvent:Add(self, self.OnBtBuyLvClick)
  end
  if self.ButtonBuyBp then
    self.ButtonBuyBp.OnPMButtonClicked:Add(self.OnBtBuyLvClick, self)
  end
  if self.ListView_Rewards then
    self.ListView_Rewards.BP_OnItemScrolledIntoView:Add(self, self.OnItemScrolledIntoView)
  end
  if self.Button_QuitPre then
    self.Button_QuitPre:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Button_QuitPre.OnClicked:Add(self, self.OnBtQuitPreClick)
  end
  if self.WBP_UI3DModelControlWidget then
    local contrlImg = self.WBP_UI3DModelControlWidget.ControlImage
    if contrlImg then
      contrlImg.OnPressed:Add(self, self.OnCtrImgPressed)
      contrlImg.OnReleased:Add(self, self.OnCtrImgReleased)
    end
  end
end
function BattlePassProgressPageMobile:OnShow(luaOpenData, nativeOpenData)
  self:PlayAnimation(self.Anim_MoveOut, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
end
function BattlePassProgressPageMobile:OnClose()
  if self.ButtonBuyLv then
    self.ButtonBuyLv.OnClickEvent:Remove(self, self.OnBtBuyLvClick)
  end
  if self.ButtonBuyBp then
    self.ButtonBuyBp.OnPMButtonClicked:Remove(self.OnBtBuyLvClick, self)
  end
  if self.ListView_Rewards then
    self.ListView_Rewards.BP_OnItemScrolledIntoView:Remove(self, self.OnItemScrolledIntoView)
  end
  if self.timerHandler then
    self.timerHandler:EndTask()
  end
  if self.Button_QuitPre then
    self.Button_QuitPre.OnClicked:Remove(self, self.OnBtQuitPreClick)
  end
  if self.WBP_UI3DModelControlWidget then
    local contrlImg = self.WBP_UI3DModelControlWidget.ControlImage
    if contrlImg then
      contrlImg.OnPressed:Remove(self, self.OnCtrImgPressed)
      contrlImg.OnReleased:Remove(self, self.OnCtrImgReleased)
    end
  end
end
function BattlePassProgressPageMobile:OnCtrImgPressed()
  if not self.isPreview and self.currentDisplay3dModel then
    self:EnterPreview()
  end
end
function BattlePassProgressPageMobile:OnCtrImgReleased()
end
function BattlePassProgressPageMobile:OnBtQuitPreClick()
  self:QuitPreview()
end
function BattlePassProgressPageMobile:OnBtBuyLvClick()
  ViewMgr:OpenPage(self, UIPageNameDefine.BattlePassProgressLv)
end
function BattlePassProgressPageMobile:OnBtBuyBpClick()
end
function BattlePassProgressPageMobile:EnterPreview()
  if self.currentDisplay3dModel then
    local camera = self.currentDisplay3dModel:RetrieveLobbyCharacterCamera()
    if camera then
      camera:SetPreviewMode(true)
    end
    if self.Button_QuitPre then
      self.Button_QuitPre:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
  self.isPreview = true
  self:PlayAnimation(self.Anim_MoveOut, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function BattlePassProgressPageMobile:QuitPreview()
  if self.currentDisplay3dModel then
    local camera = self.currentDisplay3dModel:RetrieveLobbyCharacterCamera()
    if camera then
      camera:SetPreviewMode(false)
    end
    if self.Button_QuitPre then
      self.Button_QuitPre:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self.isPreview = false
  self:PlayAnimation(self.Anim_MoveOut, 0, 1, UE4.EUMGSequencePlayMode.Reverse, 1, false)
end
function BattlePassProgressPageMobile:UpdateLevel(data)
  if self.Text_Lv then
    self.Text_Lv:SetText(data.curLevel)
  end
  if self.Text_Progress then
    self.Text_Progress:SetText(data.curExp .. "/ " .. data.maxExp)
    if 1 == data.curExp and 1 == data.maxExp then
      self.Text_Progress:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.ProgressBar_Lv then
    self.ProgressBar_Lv:SetPercent(data.curExp / data.maxExp)
  end
  if self.ButtonBuyLv then
    self.ButtonBuyLv:SetVisibility(data.bIsMaxLevel and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function BattlePassProgressPageMobile:UpdateSeasonInfo(data)
  if data then
    if self.Text_SeasonName then
      self.Text_SeasonName:SetText(data.inSeasonName)
    end
    if data.inTime and data.inTime > 0 then
      self.time = data.inTime
      if self.timerHandler then
        self.timerHandler:EndTask()
        self.timerHandler = nil
      end
      self:DrawRemainingTimeTxt()
      self.timerHandler = TimerMgr:AddTimeTask(1, 1, 0, function()
        self:RemainingTimeTxt()
      end)
    end
  end
end
function BattlePassProgressPageMobile:UpdateDesc(data)
  if self.Text_Name then
    self.Text_Name:SetText(data.name)
  end
  if self.Text_Quality then
    self.Text_Quality:SetText(data.qualityName)
  end
  if self.Text_ItemType then
    self.Text_ItemType:SetText(data.intervalName)
  end
  if self.Text_Info then
    self.Text_Info:SetText(data.desc)
  end
  if self.Img_Quality then
    self.Img_Quality:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(data.qualityColor)))
  end
end
function BattlePassProgressPageMobile:UpdateModel(itemId, itemType)
  self.currentDisplay3dModel = self.WBP_UI3DModelControlWidget:DisplayByItemId(itemId, UE4.ELobbyCharacterAnimationStateMachineType.None)
  if self.currentDisplay3dModel then
    GameFacade:SendNotification(NotificationDefines.ItemImageDisplay)
  else
    self.WBP_UI3DModelControlWidget:Display3DEnvBackground()
    GameFacade:SendNotification(NotificationDefines.ItemImageDisplay, itemId)
  end
  if itemType ~= UE4.EItemIdIntervalType.RoleSkin and itemType ~= UE4.EItemIdIntervalType.Weapon then
    self.currentDisplay3dModel = nil
    if self.UI_Menus then
      self.UI_Menus:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  else
    if itemType == UE4.EItemIdIntervalType.RoleSkin then
      local camera = self.currentDisplay3dModel:RetrieveLobbyCharacterCamera()
      if camera then
        camera:QuitPreviewMode()
      end
    end
    if self.UI_Menus then
      self.UI_Menus:SetVisibility(UE4.ESlateVisibility.Visible)
    end
  end
end
function BattlePassProgressPageMobile:InitRewards(data)
  if self.ListView_Rewards then
    for key, value in pairs(data) do
      local itemObj = ObjectUtil:CreateLuaUObject(self, value.Id)
      itemObj.level = key
      itemObj.data = value
      itemObj.parentPage = self
      self.ListView_Rewards:AddItem(itemObj)
    end
  end
end
function BattlePassProgressPageMobile:ScrollToView(data)
  local index = tonumber(data.curLevel) - 1
  if self.ListView_Rewards then
    self.ListView_Rewards:ScrollIndexIntoView(index)
  end
end
function BattlePassProgressPageMobile:UpdateRewards(data)
  if self.ListView_Rewards then
    local listItems = self.ListView_Rewards:GetListItems()
    for index = 1, listItems:Length() do
      local itemObj = listItems:Get(index)
      if data[itemObj.level] then
        itemObj.data = data[itemObj.level]
      end
    end
    self.ListView_Rewards:RegenerateAllEntries()
  end
end
function BattlePassProgressPageMobile:ItemSelect(item, bIsScrolled)
  if self.childItem then
    self.childItem:SetSelect(false)
  end
  self.childItem = item
  self.itemSelectEvent(item.data, bIsScrolled)
end
function BattlePassProgressPageMobile:OnItemScrolledIntoView(item, entryWidget)
  if entryWidget then
    entryWidget:ScrolledIntoItem()
  end
end
function BattlePassProgressPageMobile:RemainingTimeTxt()
  if self.time <= 0 then
    return
  end
  self.time = self.time - 1
  self:DrawRemainingTimeTxt()
end
function BattlePassProgressPageMobile:DrawRemainingTimeTxt()
  local timeTable = FunctionUtil:FormatTime(self.time)
  local outText
  if timeTable.Day > 0 then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_DaysHours1")
    local stringMap = {
      Days = timeTable.Day,
      Hours = timeTable.Hour
    }
    outText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  elseif timeTable.Hour > 0 then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Hours1")
    local stringMap = {
      Hours = timeTable.Hour,
      Minutes = timeTable.Minute <= 0 and 1 or timeTable.Minute
    }
    outText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  else
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "PMGameUtil_Format_Minutes")
    local stringMap = {
      Minutes = timeTable.Minute <= 0 and 1 or timeTable.Minute
    }
    outText = ObjectUtil:GetTextFromFormat(formatText, stringMap)
  end
  if self.Text_Time then
    self.Text_Time:SetText(outText)
  end
end
function BattlePassProgressPageMobile:SeasonIntermission()
  if self.Img_Bg then
    self.Img_Bg:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.WidgetSwitcher_Season then
    self.WidgetSwitcher_Season:SetActiveWidgetIndex(1)
  end
end
return BattlePassProgressPageMobile
