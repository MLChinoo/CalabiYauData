local CustomRoomPageMobile = class("CustomRoomPageMobile", PureMVC.ViewComponentPage)
local CustomRoomPageMobileMediator = require("Business/Room/Mediators/Mobile/CustomRoom/CustomRoomMobilePageMediator")
function CustomRoomPageMobile:ListNeededMediators()
  return {CustomRoomPageMobileMediator}
end
function CustomRoomPageMobile:OnInitialized()
  CustomRoomPageMobile.super.OnInitialized(self)
end
function CustomRoomPageMobile:InitializeLuaEvent()
  self.actionOnShow = LuaEvent.new()
  self.actionOnClickRandom = LuaEvent.new()
  self.actionOnClickMapSelect = LuaEvent.new()
  self.actionOnClickButtonStart = LuaEvent.new()
  self.actionOnClickButtonUnStart = LuaEvent.new()
  self.actionOnClickButtonReady = LuaEvent.new()
  self.actionOnClickButtonCancel = LuaEvent.new()
  self.actionOnClickButtonQuitMatch = LuaEvent.new()
  self.actionOnClickButtonQuitRoom = LuaEvent.new()
  self.actionOnClickCyAI = LuaEvent.new()
  self.actionOnClickEntryTrainningMap = LuaEvent.new()
  self.actionOnClickAiLevel = LuaEvent.new()
  self.actionOnClickButtonSearchRoomCode = LuaEvent.new()
  self.actionOnClickCopyRoomCode = LuaEvent.new()
end
function CustomRoomPageMobile:Construct()
  CustomRoomPageMobile.super.Construct(self)
  self:OnInit()
end
function CustomRoomPageMobile:Destruct()
  CustomRoomPageMobile.super.Destruct(self)
  self.Button_Random.OnClicked:Remove(self, self.OnClickRandom)
  self.Button_MapSelect.OnClicked:Remove(self, self.OnClickMapSelect)
  self.Button_Type1.OnReleased:Remove(self, self.OnClickButtonStart)
  self.Button_Type3.OnReleased:Remove(self, self.OnClickButtonReady)
  self.Button_Type4.OnReleased:Remove(self, self.OnClickButtonCancel)
  self.Button_Type5.OnReleased:Remove(self, self.OnClickButtonQuitMatch)
  self.Button_CyAI.OnClicked:Remove(self, self.OnClickCyAI)
  self.Btn_ReturnToLobby.OnClickEvent:Remove(self, self.OnClickEsc)
  self.Button_QuitRoom.OnClicked:Remove(self, self.OnClickButtonQuitRoom)
  self.Button_AiLevel.OnClicked:Remove(self, self.OnClickAiLevel)
  self.Button_EntryTrainningMap.OnClicked:Remove(self, self.OnClickEntryTrainningMap)
  self.Button_SearchRoomCode.OnClicked:Remove(self, self.OnClickSearchRoomCode)
  self.MenuAnchor_RoomAiLevel.OnMenuOpenChanged:Remove(self, self.OnMenuAnchorRoomAiLevelOpenChanged)
  self.Button_CopyID.OnClicked:Remove(self, self.OnClickCopyRoomCode)
end
function CustomRoomPageMobile:OnInit()
  self.Button_Random.OnClicked:Add(self, self.OnClickRandom)
  self.Button_MapSelect.OnClicked:Add(self, self.OnClickMapSelect)
  self.Button_Type1.OnReleased:Add(self, self.OnClickButtonStart)
  self.Button_Type3.OnReleased:Add(self, self.OnClickButtonReady)
  self.Button_Type4.OnReleased:Add(self, self.OnClickButtonCancel)
  self.Button_Type5.OnReleased:Add(self, self.OnClickButtonQuitMatch)
  self.Button_CyAI.OnClicked:Add(self, self.OnClickCyAI)
  self.Btn_ReturnToLobby.OnClickEvent:Add(self, self.OnClickEsc)
  self.Button_QuitRoom.OnClicked:Add(self, self.OnClickButtonQuitRoom)
  self.Button_AiLevel.OnClicked:Add(self, self.OnClickAiLevel)
  self.Button_EntryTrainningMap.OnClicked:Add(self, self.OnClickEntryTrainningMap)
  self.Button_SearchRoomCode.OnClicked:Add(self, self.OnClickSearchRoomCode)
  self.MenuAnchor_RoomAiLevel.OnMenuOpenChanged:Add(self, self.OnMenuAnchorRoomAiLevelOpenChanged)
  self.Button_CopyID.OnClicked:Add(self, self.OnClickCopyRoomCode)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function CustomRoomPageMobile:OnShow()
  self.actionOnShow()
end
function CustomRoomPageMobile:OnClickEsc()
  GameFacade:SendNotification(NotificationDefines.GameModeSelect, false, NotificationDefines.GameModeSelect.QuitRoomByEsc)
end
function CustomRoomPageMobile:OnClickRandom()
  self.actionOnClickRandom()
end
function CustomRoomPageMobile:OnClickMapSelect()
  self.actionOnClickMapSelect()
end
function CustomRoomPageMobile:OnClickButtonStart()
  self.actionOnClickButtonStart()
end
function CustomRoomPageMobile:OnClickButtonUnStart()
  self.actionOnClickButtonUnStart()
end
function CustomRoomPageMobile:OnClickButtonReady()
  self.actionOnClickButtonReady()
end
function CustomRoomPageMobile:OnClickButtonCancel()
  self.actionOnClickButtonCancel()
end
function CustomRoomPageMobile:OnClickButtonQuitMatch()
  self.actionOnClickButtonQuitMatch()
end
function CustomRoomPageMobile:OnClickButtonQuitRoom()
  self.actionOnClickButtonQuitRoom()
end
function CustomRoomPageMobile:OnClickCyAI()
  self.actionOnClickCyAI()
end
function CustomRoomPageMobile:OnClickAiLevel()
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if roomDataProxy:IsTeamLeader() then
    self.actionOnClickAiLevel()
  end
end
function CustomRoomPageMobile:OnClickEntryTrainningMap()
  self.actionOnClickEntryTrainningMap()
end
function CustomRoomPageMobile:OnClickSearchRoomCode()
  self.actionOnClickButtonSearchRoomCode()
end
function CustomRoomPageMobile:OnMenuAnchorRoomAiLevelOpenChanged(bIsOpen)
  if bIsOpen then
    self.MenuAnchor_RoomAiLevel:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.MenuAnchor_RoomAiLevel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function CustomRoomPageMobile:OnClickCopyRoomCode()
  self.actionOnClickCopyRoomCode()
end
function CustomRoomPageMobile:SetUIVisibilityOfRoomMasterOrMember(bRoomMaster)
  if bRoomMaster then
    self.UI_MapSelect:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.UI_Random:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.UI_CyAI:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.UI_MapSelect:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UI_Random:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.UI_CyAI:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
return CustomRoomPageMobile
