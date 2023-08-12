local FriendProfilePage = class("FriendProfilePage", PureMVC.ViewComponentPage)
local PlayerProfileMediator = require("Business/PlayerProfile/Mediators/PlayerProfileMediator")
function FriendProfilePage:ListNeededMediators()
  return {PlayerProfileMediator}
end
function FriendProfilePage:InitializeLuaEvent()
  LogDebug("FriendProfilePage", "Init lua event")
end
function FriendProfilePage:OnOpen(luaOpenData, nativeOpenData)
  if self.WBP_HotKey_Esc then
    self.WBP_HotKey_Esc.OnClickEvent:Add(self, self.ClosePage)
  end
  if self.Information_Open then
    self:PlayAnimationForward(self.Information_Open)
  end
  if self.Button_Credit then
    self.Button_Credit.OnClicked:Add(self, self.OnClickCredit)
  end
end
function FriendProfilePage:OnClose()
  if self.WBP_HotKey_Esc then
    self.WBP_HotKey_Esc.OnClickEvent:Remove(self, self.ClosePage)
  end
  if self.Button_Credit then
    self.Button_Credit.OnClicked:Remove(self, self.OnClickCredit)
  end
end
function FriendProfilePage:UpdateView(cardInfo, collectionInfo)
  if self.CardPanel then
    self.CardPanel:InitView(cardInfo)
  end
  if self.CollectableDataPanel then
    self.CollectableDataPanel:UpdateView(collectionInfo)
  end
  if cardInfo and cardInfo.playerAttr then
    self.targetPlayerId = cardInfo.playerAttr.playerId
    self.targetPlayerName = cardInfo.playerAttr.nickName
    if self.Text_PlayerID then
      self.Text_PlayerID:SetText(self.targetPlayerId)
    end
  end
end
function FriendProfilePage:OnClickCredit()
  if self.targetPlayerId then
    local TipoffPageParam = {
      TargetUID = self.targetPlayerId,
      TargetName = self.targetPlayerName,
      EnteranceType = UE4.ECyTipoffEntranceType.ENTERANCE_PERSONALINFO,
      SceneType = UE4.ECyTipoffSceneType.PLAYER_INFO
    }
    GameFacade:RetrieveProxy(ProxyNames.CreditProxy):OpenReportPage(TipoffPageParam)
  end
end
function FriendProfilePage:LuaHandleKeyEvent(key, inputEvent)
  if self.WBP_HotKey_Esc then
    return self.WBP_HotKey_Esc:MonitorKeyDown(key, inputEvent)
  end
  return false
end
function FriendProfilePage:ClosePage()
  ViewMgr:ClosePage(self)
end
return FriendProfilePage
