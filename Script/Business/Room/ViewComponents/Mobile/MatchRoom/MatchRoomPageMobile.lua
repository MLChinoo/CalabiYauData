local RankRoomPageMediator = require("Business/Room/Mediators/RankRoom/RankRoomMediator")
local RankRoomPage = class("RankRoomPage", PureMVC.ViewComponentPage)
function RankRoomPage:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function RankRoomPage:ListNeededMediators()
  return {RankRoomPageMediator}
end
function RankRoomPage:InitializeLuaEvent()
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
function RankRoomPage:Construct()
  RankRoomPage.super.Construct(self)
  self.Btn_ReturnToLobby.OnClickEvent:Add(self, self.OnClickEsc)
  self.Button_Type1.OnReleased:Add(self, self.OnClickButtonStart)
  self.Button_Type2.OnReleased:Add(self, self.OnClickButtonUnStart)
  self.Button_Type3.OnReleased:Add(self, self.OnClickButtonReady)
  self.Button_Type4.OnReleased:Add(self, self.OnClickButtonCancel)
  self.Button_Type5.OnReleased:Add(self, self.OnClickButtonQuitMatch)
  self.Button_QuitRoom.OnReleased:Add(self, self.OnClickButtonQuitRoom)
  self.Button_EntryTrainningMap.OnClicked:Add(self, self.OnClickEntryTrainningMap)
  self.Button_SearchRoomCode.OnClicked:Add(self, self.OnClickSearchRoomCode)
  self.Button_CopyID.OnClicked:Add(self, self.OnClickCopyID)
end
function RankRoomPage:Destruct()
  RankRoomPage.super.Destruct(self)
  self.Btn_ReturnToLobby.OnClickEvent:Remove(self, self.OnClickEsc)
  self.Button_Type1.OnReleased:Remove(self, self.OnClickButtonStart)
  self.Button_Type2.OnReleased:Remove(self, self.OnClickButtonUnStart)
  self.Button_Type3.OnReleased:Remove(self, self.OnClickButtonReady)
  self.Button_Type4.OnReleased:Remove(self, self.OnClickButtonCancel)
  self.Button_Type5.OnReleased:Remove(self, self.OnClickButtonQuitMatch)
  self.Button_QuitRoom.OnReleased:Remove(self, self.OnClickButtonQuitRoom)
  self.Button_EntryTrainningMap.OnClicked:Remove(self, self.OnClickEntryTrainningMap)
  self.Button_SearchRoomCode.OnClicked:Remove(self, self.OnClickSearchRoomCode)
  self.Button_CopyID.OnClicked:Remove(self, self.OnClickCopyID)
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
function RankRoomPage:OnClickEntryTrainningMap()
  self.actionOnClickEntryTrainningMap()
end
function RankRoomPage:OnClickSearchRoomCode()
  self.actionOnClickButtonSearchRoomCode()
end
function RankRoomPage:OnClickCopyID()
  self.actionOnClickCopyRoomCode()
end
return RankRoomPage
