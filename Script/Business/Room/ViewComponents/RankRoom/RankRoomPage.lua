local RankRoomPageMediator = require("Business/Room/Mediators/RankRoom/RankRoomMediator")
local RankRoomPage = class("RankRoomPage", PureMVC.ViewComponentPage)
function RankRoomPage:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function RankRoomPage:ListNeededMediators()
  return {RankRoomPageMediator}
end
function RankRoomPage:InitializeLuaEvent()
  self.actionLuaHandleKeyEvent = LuaEvent.new()
  self.actionOnClickEsc = LuaEvent.new()
  self.actionOnClickButtonStart = LuaEvent.new()
  self.actionOnClickButtonUnStart = LuaEvent.new()
  self.actionOnClickButtonReady = LuaEvent.new()
  self.actionOnClickButtonCancel = LuaEvent.new()
  self.actionOnClickButtonQuitMatch = LuaEvent.new()
  self.actionOnClickButtonQuitRoom = LuaEvent.new()
  self.actionOnClickEntryTrainningMap = LuaEvent.new()
  self.actionOnClickButtonSearchRoomCode = LuaEvent.new()
  self.actionOnClickCopyRoomCode = LuaEvent.new()
end
function RankRoomPage:LuaHandleKeyEvent(key, inputEvent)
  self.actionLuaHandleKeyEvent(key, inputEvent)
  return false
end
function RankRoomPage:Construct()
  RankRoomPage.super.Construct(self)
  self:UIOperateBind()
  self:PlayAnimation(self.BackgrounAnim, 0, 0, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function RankRoomPage:Destruct()
  RankRoomPage.super.Destruct(self)
  self:UIOperateUnBind()
end
function RankRoomPage:UIOperateBind()
  self.Button_Type1.OnReleased:Add(self, self.OnClickButtonStart)
  self.Button_Type2.OnReleased:Add(self, self.OnClickButtonUnStart)
  self.Button_Type3.OnReleased:Add(self, self.OnClickButtonReady)
  self.Button_Type4.OnReleased:Add(self, self.OnClickButtonCancel)
  self.Button_Type5.OnReleased:Add(self, self.OnClickButtonQuitMatch)
  self.Button_QuitRoom.OnReleased:Add(self, self.OnClickButtonQuitRoom)
  self.Button_EntryTrainningMap.OnClicked:Add(self, self.OnClickEntryTrainningMap)
  self.Button_EntryTrainningMap.OnHovered:Add(self, self.OnHoveredEntryTrainningMap)
  self.Button_EntryTrainningMap.OnUnHovered:Add(self, self.OnUnHoveredEntryTrainningMap)
  self.Button_SearchRoomCode.OnClicked:Add(self, self.OnClickSearchRoomCode)
  self.Button_SearchRoomCode.OnHovered:Add(self, self.OnHoveredSearchRoomCode)
  self.Button_SearchRoomCode.OnUnHovered:Add(self, self.OnUnHoveredSearchRoomCode)
  self.HotKeyButton.OnClickEvent:Add(self, self.OnClickEsc)
  self.HotKeyButton:SetHotKeyIsEnable(true)
  self.Button_CopyID.OnClicked:Add(self, self.OnClickCopyID)
  if self.Button_RankHint then
    self.Button_RankHint.OnHovered:Add(self, self.OnHoverRankScope)
    self.Button_RankHint.OnUnHovered:Add(self, self.OnUnHoverRankScope)
  end
  if self.NetworkInfoBtn then
    self.NetworkInfoBtn.OnHovered:Add(self, self.OnHoveredNetworkInfoBtn)
    self.NetworkInfoBtn.OnUnhovered:Add(self, self.OnUnHoveredNetworkInfoBtn)
  end
end
function RankRoomPage:UIOperateUnBind()
  self.Button_Type1.OnReleased:Remove(self, self.OnClickButtonStart)
  self.Button_Type2.OnReleased:Remove(self, self.OnClickButtonUnStart)
  self.Button_Type3.OnReleased:Remove(self, self.OnClickButtonReady)
  self.Button_Type4.OnReleased:Remove(self, self.OnClickButtonCancel)
  self.Button_Type5.OnReleased:Remove(self, self.OnClickButtonQuitMatch)
  self.Button_QuitRoom.OnReleased:Remove(self, self.OnClickButtonQuitRoom)
  self.Button_EntryTrainningMap.OnClicked:Remove(self, self.OnClickEntryTrainningMap)
  self.Button_EntryTrainningMap.OnHovered:Remove(self, self.OnHoveredEntryTrainningMap)
  self.Button_EntryTrainningMap.OnUnHovered:Remove(self, self.OnUnHoveredEntryTrainningMap)
  self.Button_SearchRoomCode.OnClicked:Remove(self, self.OnClickSearchRoomCode)
  self.Button_SearchRoomCode.OnHovered:Remove(self, self.OnHoveredSearchRoomCode)
  self.Button_SearchRoomCode.OnUnHovered:Remove(self, self.OnUnHoveredSearchRoomCode)
  self.HotKeyButton.OnClickEvent:Remove(self, self.OnClickEsc)
  self.Button_CopyID.OnClicked:Remove(self, self.OnClickCopyID)
  if self.Button_RankHint then
    self.Button_RankHint.OnHovered:Remove(self, self.OnHoverRankScope)
    self.Button_RankHint.OnUnHovered:Remove(self, self.OnUnHoverRankScope)
  end
  if self.NetworkInfoBtn then
    self.NetworkInfoBtn.OnHovered:Remove(self, self.OnHoveredNetworkInfoBtn)
    self.NetworkInfoBtn.OnUnhovered:Remove(self, self.OnUnHoveredNetworkInfoBtn)
  end
end
function RankRoomPage:OnHoveredNetworkInfoBtn()
  LogDebug("RankRoomPage", "OnHoveredNetworkInfoBtn")
  self.NetworkInfoRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.WhiteFrame:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end
function RankRoomPage:OnUnHoveredNetworkInfoBtn()
  LogDebug("RankRoomPage", "OnUnHoveredNetworkInfoBtn")
  self.NetworkInfoRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.WhiteFrame:SetVisibility(UE4.ESlateVisibility.Collapsed)
end
function RankRoomPage:OnClickEntryTrainningMap()
  self.actionOnClickEntryTrainningMap()
end
function RankRoomPage:OnClickEsc()
  self.actionOnClickEsc()
end
function RankRoomPage:OnClickButtonStart()
  self.actionOnClickButtonStart()
end
function RankRoomPage:OnClickButtonUnStart()
  self.actionOnClickButtonUnStart()
end
function RankRoomPage:OnClickButtonReady()
  self.actionOnClickButtonReady()
end
function RankRoomPage:OnClickButtonCancel()
  self.actionOnClickButtonCancel()
end
function RankRoomPage:OnClickButtonQuitMatch()
  self.actionOnClickButtonQuitMatch()
end
function RankRoomPage:OnClickButtonQuitRoom()
  self.actionOnClickButtonQuitRoom()
end
function RankRoomPage:OnHoveredEntryTrainningMap()
  self.Text_EntryTrainningMap:SetColorAndOpacity(self.bp_txtUnHoveredColorEntryTrainningMap)
  self.Img_EntryTrainningMap:SetBrush(self.bp_imgHoveredStyleEntryTrainningMap)
end
function RankRoomPage:OnUnHoveredEntryTrainningMap()
  self.Text_EntryTrainningMap:SetColorAndOpacity(self.bp_txtHoveredColorEntryTrainningMap)
  self.Img_EntryTrainningMap:SetBrush(self.bp_imgUnHoveredStyleEntryTrainningMap)
end
function RankRoomPage:OnClickSearchRoomCode()
  self.actionOnClickButtonSearchRoomCode()
end
function RankRoomPage:OnHoveredSearchRoomCode()
  self.Text_SearchRoomCode:SetColorAndOpacity(self.bp_txtUnHoveredColorSearchRoomCode)
  self.Img_SearchRoomCode:SetBrush(self.bp_imgHoveredStyleSearchRoomCode)
end
function RankRoomPage:OnUnHoveredSearchRoomCode()
  self.Text_SearchRoomCode:SetColorAndOpacity(self.bp_txtHoveredColorSearchRoomCode)
  self.Img_SearchRoomCode:SetBrush(self.bp_imgUnHoveredStyleSearchRoomCode)
end
function RankRoomPage:OnHoverRankScope()
  if self.Overlay_RankScope then
    self.Overlay_RankScope:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function RankRoomPage:OnUnHoverRankScope()
  if self.Overlay_RankScope then
    self.Overlay_RankScope:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function RankRoomPage:OnClickCopyID()
  self.actionOnClickCopyRoomCode()
end
return RankRoomPage
