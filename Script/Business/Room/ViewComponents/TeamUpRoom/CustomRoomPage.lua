local CustomRoomPage = class("CustomRoomPage", PureMVC.ViewComponentPage)
local roomDataProxy
local CustomRoomPageMediator = require("Business/Room/Mediators/TeamUpRoom/CustomRoomPageMediator")
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
function CustomRoomPage:ListNeededMediators()
  return {CustomRoomPageMediator}
end
function CustomRoomPage:OnInitialized()
  CustomRoomPage.super.OnInitialized(self)
end
function CustomRoomPage:InitializeLuaEvent()
  self.actionOnShow = LuaEvent.new()
  self.actionOnClickEsc = LuaEvent.new()
  self.actionOnClickRandom = LuaEvent.new()
  self.actionOnClickMapSelect = LuaEvent.new()
  self.actionOnClickButtonStart = LuaEvent.new()
  self.actionOnClickButtonUnStart = LuaEvent.new()
  self.actionOnClickButtonReady = LuaEvent.new()
  self.actionOnClickButtonCancel = LuaEvent.new()
  self.actionOnClickButtonQuitMatch = LuaEvent.new()
  self.actionOnClickCyAI = LuaEvent.new()
  self.actionOnClickEntryTrainningMap = LuaEvent.new()
  self.actionOnClickAiLevel = LuaEvent.new()
  self.actionOnClickButtonSearchRoomCode = LuaEvent.new()
  self.actionOnClickCopyRoomCode = LuaEvent.new()
end
function CustomRoomPage:Construct()
  CustomRoomPage.super.Construct(self)
  self:OnInit()
end
function CustomRoomPage:Destruct()
  CustomRoomPage.super.Destruct(self)
  self.Button_Switch.OnClicked:Remove(self, self.OnClickRandom)
  self.Button_MapSelect.OnClicked:Remove(self, self.OnClickMapSelect)
  self.Button_Type1.OnReleased:Remove(self, self.OnClickButtonStart)
  self.Button_Type2.OnReleased:Remove(self, self.OnClickButtonUnStart)
  self.Button_Type3.OnReleased:Remove(self, self.OnClickButtonReady)
  self.Button_Type4.OnReleased:Remove(self, self.OnClickButtonCancel)
  self.Button_Type5.OnReleased:Remove(self, self.OnClickButtonQuitMatch)
  self.Button_CyAI.OnClicked:Remove(self, self.OnClickCyAI)
  self.HotKeyButton.OnClickEvent:Remove(self, self.OnClickEsc)
  self.Button_Switch.OnHovered:Remove(self, self.OnHoveredBtnSwitch)
  self.Button_Switch.OnUnhovered:Remove(self, self.OnUnHoveredBtnSwitch)
  self.Button_MapSelect.OnHovered:Remove(self, self.OnHoveredBtnMapSelect)
  self.Button_MapSelect.OnUnhovered:Remove(self, self.OnUnHoveredBtnMapSelect)
  self.Button_CyAI.OnHovered:Remove(self, self.OnHoveredBtnSelectAI)
  self.Button_CyAI.OnUnhovered:Remove(self, self.OnUnHoveredBtnSelectAI)
  self.Button_AiLevel.OnHovered:Remove(self, self.OnHoveredBtnAiLevel)
  self.Button_AiLevel.OnUnhovered:Remove(self, self.OnUnHoveredBtnAiLevel)
  self.Button_AiLevel.OnClicked:Remove(self, self.OnClickAiLevel)
  self.Button_EntryTrainningMap.OnClicked:Remove(self, self.OnClickEntryTrainningMap)
  self.Button_EntryTrainningMap.OnHovered:Remove(self, self.OnHoveredEntryTrainningMap)
  self.Button_EntryTrainningMap.OnUnHovered:Remove(self, self.OnUnHoveredEntryTrainningMap)
  self.Button_SearchRoomCode.OnClicked:Remove(self, self.OnClickSearchRoomCode)
  self.Button_SearchRoomCode.OnHovered:Remove(self, self.OnHoveredSearchRoomCode)
  self.Button_SearchRoomCode.OnUnHovered:Remove(self, self.OnUnHoveredSearchRoomCode)
  self.MenuAnchor_RoomAiLevel.OnMenuOpenChanged:Remove(self, self.OnMenuAnchorRoomAiLevelOpenChanged)
  self.Button_CopyID.OnClicked:Remove(self, self.OnClickCopyRoomCode)
  if self.NetworkInfoBtn then
    self.NetworkInfoBtn.OnHovered:Remove(self, self.OnHoveredNetworkInfoBtn)
    self.NetworkInfoBtn.OnUnhovered:Remove(self, self.OnUnHoveredNetworkInfoBtn)
  end
  self:ClearupdateSwitchPositionCDTimeHandle()
  self:ClearUpdateAddAiCDTimeHandle()
end
function CustomRoomPage:OnInit()
  self.Button_Switch.OnClicked:Add(self, self.OnClickRandom)
  self.Button_MapSelect.OnClicked:Add(self, self.OnClickMapSelect)
  self.Button_Type1.OnReleased:Add(self, self.OnClickButtonStart)
  self.Button_Type2.OnReleased:Add(self, self.OnClickButtonUnStart)
  self.Button_Type3.OnReleased:Add(self, self.OnClickButtonReady)
  self.Button_Type4.OnReleased:Add(self, self.OnClickButtonCancel)
  self.Button_Type5.OnReleased:Add(self, self.OnClickButtonQuitMatch)
  self.Button_CyAI.OnClicked:Add(self, self.OnClickCyAI)
  self.HotKeyButton.OnClickEvent:Add(self, self.OnClickEsc)
  self.HotKeyButton:SetHotKeyIsEnable(true)
  self.Button_Switch.OnHovered:Add(self, self.OnHoveredBtnSwitch)
  self.Button_Switch.OnUnhovered:Add(self, self.OnUnHoveredBtnSwitch)
  self.Button_MapSelect.OnHovered:Add(self, self.OnHoveredBtnMapSelect)
  self.Button_MapSelect.OnUnhovered:Add(self, self.OnUnHoveredBtnMapSelect)
  self.Button_CyAI.OnHovered:Add(self, self.OnHoveredBtnSelectAI)
  self.Button_CyAI.OnUnhovered:Add(self, self.OnUnHoveredBtnSelectAI)
  self.Button_AiLevel.OnHovered:Add(self, self.OnHoveredBtnAiLevel)
  self.Button_AiLevel.OnUnhovered:Add(self, self.OnUnHoveredBtnAiLevel)
  self.Button_AiLevel.OnClicked:Add(self, self.OnClickAiLevel)
  self.Button_EntryTrainningMap.OnClicked:Add(self, self.OnClickEntryTrainningMap)
  self.Button_EntryTrainningMap.OnHovered:Add(self, self.OnHoveredEntryTrainningMap)
  self.Button_EntryTrainningMap.OnUnHovered:Add(self, self.OnUnHoveredEntryTrainningMap)
  self.Button_EntryTrainningMap.OnPressed:Add(self, self.OnUnHoveredEntryTrainningMap)
  self.Button_EntryTrainningMap.OnReleased:Add(self, self.OnHoveredEntryTrainningMap)
  self.Button_SearchRoomCode.OnClicked:Add(self, self.OnClickSearchRoomCode)
  self.Button_SearchRoomCode.OnHovered:Add(self, self.OnHoveredSearchRoomCode)
  self.Button_SearchRoomCode.OnUnHovered:Add(self, self.OnUnHoveredSearchRoomCode)
  self.Button_SearchRoomCode.OnPressed:Add(self, self.OnUnHoveredSearchRoomCode)
  self.Button_SearchRoomCode.OnReleased:Add(self, self.OnHoveredSearchRoomCode)
  self.MenuAnchor_RoomAiLevel.OnMenuOpenChanged:Add(self, self.OnMenuAnchorRoomAiLevelOpenChanged)
  self.Button_CopyID.OnClicked:Add(self, self.OnClickCopyRoomCode)
  if self.NetworkInfoBtn then
    self.NetworkInfoBtn.OnHovered:Add(self, self.OnHoveredNetworkInfoBtn)
    self.NetworkInfoBtn.OnUnhovered:Add(self, self.OnUnHoveredNetworkInfoBtn)
  end
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self.curSwitchPositionTimes = 0
  self.curAddAiTimes = 0
end
function CustomRoomPage:OnHoveredNetworkInfoBtn()
  LogDebug("CustomRoomPage", "OnHoveredNetworkInfoBtn")
  self.NetworkInfoRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.WhiteFrame:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function CustomRoomPage:OnUnHoveredNetworkInfoBtn()
  LogDebug("CustomRoomPage", "OnUnHoveredNetworkInfoBtn")
  self.NetworkInfoRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.WhiteFrame:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function CustomRoomPage:OnShow()
  self.actionOnShow()
end
function CustomRoomPage:OnClickEsc()
  self.actionOnClickEsc()
end
function CustomRoomPage:OnClickRandom()
  if self.curSwitchPositionTimes < self.bp_switchPositonMaxTimePerCD then
    self.curSwitchPositionTimes = self.curSwitchPositionTimes + 1
    if not self.updateSwitchPositionCDTimeHandle then
      self.updateSwitchPositionCDTimeHandle = TimerMgr:AddTimeTask(self.bp_switchPositionCD, 0, 1, function()
        self.curSwitchPositionTimes = 0
        self:ClearupdateSwitchPositionCDTimeHandle()
      end)
    end
    self.actionOnClickRandom()
  else
    self:SendBtnIsInCd()
  end
end
function CustomRoomPage:OnClickMapSelect()
  self.actionOnClickMapSelect()
end
function CustomRoomPage:OnClickButtonStart()
  self.actionOnClickButtonStart()
end
function CustomRoomPage:OnClickButtonUnStart()
  self.actionOnClickButtonUnStart()
end
function CustomRoomPage:OnClickButtonReady()
  self.actionOnClickButtonReady()
end
function CustomRoomPage:OnClickButtonCancel()
  self.actionOnClickButtonCancel()
end
function CustomRoomPage:OnClickButtonQuitMatch()
  self.actionOnClickButtonQuitMatch()
end
function CustomRoomPage:OnClickCyAI()
  local roomInfo = roomDataProxy:GetTeamInfo()
  if roomInfo then
    local mapPlayMode = roomDataProxy:GetMapType(roomInfo.mapID)
    if mapPlayMode and mapPlayMode > RoomEnum.MapType.None then
      local maxPlayerNumber = roomDataProxy:GetCustomRoomMaxPlayerNumberByMapType(mapPlayMode)
      local curRoomPlayerNumber = roomDataProxy:GetPlayerFightPositionNumberInCustomRoom()
      if maxPlayerNumber <= curRoomPlayerNumber then
        local roomPositionIsFullTips = ConfigMgr:FromStringTable(StringTablePath.ST_RoomName, "RoomPositionIsFull")
        GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, roomPositionIsFullTips)
        return
      end
    else
      LogInfo("PC ClickCyAI", "mapPlayMode is invalid")
      return
    end
  else
    LogInfo("PC ClickCyAI", "roomInfo is nil")
  end
  if self.curAddAiTimes < self.bp_addAiMaxTimePerCD then
    self.curAddAiTimes = self.curAddAiTimes + 1
    if not self.updateAddAiCDTimeHandle then
      self.updateAddAiCDTimeHandle = TimerMgr:AddTimeTask(self.bp_addAiCD, 0, 1, function()
        self.curAddAiTimes = 0
        self:ClearUpdateAddAiCDTimeHandle()
      end)
    end
    self.actionOnClickCyAI()
  else
    self:SendBtnIsInCd()
  end
end
function CustomRoomPage:OnClickEntryTrainningMap()
  self.actionOnClickEntryTrainningMap()
end
function CustomRoomPage:OnHoveredBtnSwitch()
  self.TipsImg_Switch:SetVisibility(UE4.ESlateVisibility.Visible)
end
function CustomRoomPage:OnUnHoveredBtnSwitch()
  self.TipsImg_Switch:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function CustomRoomPage:OnHoveredBtnMapSelect()
  self.TipsImg_MapSelect:SetVisibility(UE4.ESlateVisibility.Visible)
end
function CustomRoomPage:OnUnHoveredBtnMapSelect()
  self.TipsImg_MapSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function CustomRoomPage:OnHoveredBtnSelectAI()
  self.TipsImg_SelectAI:SetVisibility(UE4.ESlateVisibility.Visible)
end
function CustomRoomPage:OnUnHoveredBtnSelectAI()
  self.TipsImg_SelectAI:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function CustomRoomPage:OnHoveredBtnAiLevel()
  if roomDataProxy:IsTeamLeader() then
    self.TipsImg_AiLevel:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function CustomRoomPage:OnUnHoveredBtnAiLevel()
  if roomDataProxy:IsTeamLeader() then
    self.TipsImg_AiLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function CustomRoomPage:OnClickAiLevel()
  if roomDataProxy:IsTeamLeader() then
    self.actionOnClickAiLevel()
  end
end
function CustomRoomPage:OnHoveredEntryTrainningMap()
  self.Text_EntryTrainningMap:SetColorAndOpacity(self.bp_txtHoveredColorEntryTrainningMap)
  self.Img_EntryTrainningMap:SetBrush(self.bp_imgHoveredStyleEntryTrainningMap)
end
function CustomRoomPage:OnUnHoveredEntryTrainningMap()
  self.Text_EntryTrainningMap:SetColorAndOpacity(self.bp_txtUnHoveredColorEntryTrainningMap)
  self.Img_EntryTrainningMap:SetBrush(self.bp_imgUnHoveredStyleEntryTrainningMap)
end
function CustomRoomPage:OnClickSearchRoomCode()
  self.actionOnClickButtonSearchRoomCode()
end
function CustomRoomPage:OnHoveredSearchRoomCode()
  self.Text_SearchRoomCode:SetColorAndOpacity(self.bp_txtUnHoveredColorSearchRoomCode)
  self.Img_SearchRoomCode:SetBrush(self.bp_imgHoveredStyleSearchRoomCode)
end
function CustomRoomPage:OnUnHoveredSearchRoomCode()
  self.Text_SearchRoomCode:SetColorAndOpacity(self.bp_txtHoveredColorSearchRoomCode)
  self.Img_SearchRoomCode:SetBrush(self.bp_imgUnHoveredStyleSearchRoomCode)
end
function CustomRoomPage:OnMenuAnchorRoomAiLevelOpenChanged(bIsOpen)
  if bIsOpen then
    self.MenuAnchor_RoomAiLevel:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.MenuAnchor_RoomAiLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function CustomRoomPage:LuaHandleKeyEvent(key, inputEvent)
  local keyDisplayName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyDisplayName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnClickEsc()
    return true
  end
  return false
end
function CustomRoomPage:OnClickCopyRoomCode()
  self.actionOnClickCopyRoomCode()
end
function CustomRoomPage:SetUIVisibilityOfRoomMasterOrMember(bRoomMaster)
  if bRoomMaster then
    self.HB_TopButtons:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.HB_TopButtons:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function CustomRoomPage:SendBtnIsInCd()
  local frequentTips = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "FrequentTips")
  GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, frequentTips)
end
function CustomRoomPage:ClearupdateSwitchPositionCDTimeHandle()
  if self.updateSwitchPositionCDTimeHandle then
    self.updateSwitchPositionCDTimeHandle:EndTask()
    self.updateSwitchPositionCDTimeHandle = nil
  end
end
function CustomRoomPage:ClearUpdateAddAiCDTimeHandle()
  if self.updateAddAiCDTimeHandle then
    self.updateAddAiCDTimeHandle:EndTask()
    self.updateAddAiCDTimeHandle = nil
  end
end
return CustomRoomPage
