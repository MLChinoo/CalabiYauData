local RankPreparePanelMediator = require("Business/Room/Mediators/RankRoom/RankPreparePanelMediator")
local RankPreparePanel = class("RankPreparePanel", PureMVC.ViewComponentPanel)
local GameModeSelectNum = require("Business/Lobby/Mediators/GameModeSelectEnum")
function RankPreparePanel:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function RankPreparePanel:ListNeededMediators()
  return {RankPreparePanelMediator}
end
function RankPreparePanel:InitializeLuaEvent()
  self.actionOnClickPrepare = LuaEvent.new()
end
function RankPreparePanel:Construct()
  RankPreparePanel.super.Construct(self)
  self.Btn_Prepare.OnClickEvent:Add(self, self.OnClickPrepare)
  self:PlayAnimation(self.ShowPrepareState, 0.0, 1, UE4.EUMGSequencePlayMode.Forward, 1.0, false)
  self:K2_PostAkEvent(self.bp_loopMatchAudio, true)
  local roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local gameMode = roomDataProxy:GetGameMode()
  if gameMode and gameMode ~= GameModeSelectNum.GameModeType.None and (gameMode == GameModeSelectNum.GameModeType.Boomb or gameMode == GameModeSelectNum.GameModeType.RankBomb or gameMode == GameModeSelectNum.GameModeType.RankTeam or gameMode == GameModeSelectNum.GameModeType.Team or gameMode == GameModeSelectNum.GameModeType.CrystalScramble) then
    for index = 11, 15 do
      if self["Card_" .. tostring(index)] then
        self["Card_" .. tostring(index)]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
  if GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetIsInLottery() then
    GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):ReturnEntry()
  end
end
function RankPreparePanel:Destruct()
  RankPreparePanel.super.Destruct(self)
  self.Btn_Prepare.OnClickEvent:Remove(self, self.OnClickPrepare)
end
function RankPreparePanel:OnClickPrepare()
  self.actionOnClickPrepare()
end
function RankPreparePanel:LuaHandleKeyEvent(key, inputEvent)
  local keyDisplayName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyDisplayName and inputEvent == UE4.EInputEvent.IE_Released then
    return true
  end
  if self.Btn_Prepare then
    return self.Btn_Prepare:MonitorKeyDown(key, inputEvent)
  end
  return false
end
return RankPreparePanel
