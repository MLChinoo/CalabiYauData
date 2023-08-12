local RoomPlayerListPanel = class("RoomPlayerListPanel", PureMVC.ViewComponentPanel)
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local CardEnum = require("Business/Room/Mediators/Card/CardEnum")
local roomDataProxy
local RoomPlayerListPanelMediator = require("Business/Room/Mediators/TeamUpRoom/RoomPlayerListPanelMediator")
function RoomPlayerListPanel:ListNeededMediators()
  return {RoomPlayerListPanelMediator}
end
function RoomPlayerListPanel:Construct()
  RoomPlayerListPanel.super.Construct(self)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  roomDataProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  self:UpdatePlayerListInfo()
end
function RoomPlayerListPanel:Destruct()
  RoomPlayerListPanel.super.Destruct(self)
end
function RoomPlayerListPanel:ResetPlayeListInfo()
  self.PlayerSlots = {}
  local playerSlotNum = self.bp_playerNum
  for index = 1, playerSlotNum do
    local playerSlot = self["PlayerSlot_" .. index]
    local playerMediator = playerSlot:GetCurrentMediator()
    if playerMediator.memberInfo then
      playerMediator.memberInfo = nil
    end
    playerMediator:SetPlayerState(CardEnum.PlayerState.Leave)
    playerMediator:ResetSmallSpeakerPlayerID()
    playerSlot.position = index
    self.PlayerSlots[index] = playerMediator
  end
  local spectorNum = self.bp_spectatorNum
  for index = playerSlotNum + 1, playerSlotNum + spectorNum do
    local playerSlot = self["PlayerSlot_Sectator_" .. index - playerSlotNum]
    local playerMediator = playerSlot:GetCurrentMediator()
    playerMediator:SetPlayerState(CardEnum.PlayerState.Leave)
    playerSlot.position = index
    self.PlayerSlots[index] = playerMediator
  end
end
function RoomPlayerListPanel:UpdatePlayerListInfo()
  self:ResetPlayeListInfo()
  local roomInfo = roomDataProxy:GetTeamInfo()
  local playerList = roomDataProxy:GetTeamMemberList()
  if roomInfo and playerList and roomInfo.leaderId then
    for _, player in ipairs(playerList) do
      for _, slot in ipairs(self.PlayerSlots) do
        if slot:GetPosition() == player.pos then
          if 0 ~= player.playerId then
            if roomDataProxy:GetPlayerID() == player.playerId then
              slot:SetPlayerData(player, true)
            else
              slot:SetPlayerData(player)
            end
            if player.status == RoomEnum.TeamMemberStatusType.NotReady then
              slot:SetPlayerState(CardEnum.PlayerState.Normal)
            elseif player.status == RoomEnum.TeamMemberStatusType.Ready then
              slot:SetPlayerState(CardEnum.PlayerState.Ready)
            end
            slot:SetPlayerHost(player.playerId == roomInfo.leaderId)
          end
          break
        end
      end
    end
  end
end
return RoomPlayerListPanel
