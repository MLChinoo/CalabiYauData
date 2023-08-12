local FriendMsgMediator = require("Business/Friend/Mediators/FriendMsgMediator")
local FriendMsgPage = class("FriendMsgPage", PureMVC.ViewComponentPage)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function FriendMsgPage:ListNeededMediators()
  return {FriendMsgMediator}
end
function FriendMsgPage:InitializeLuaEvent()
end
function FriendMsgPage:OnOpen(luaOpenData, nativeOpenData)
  self:ShowMsg()
end
function FriendMsgPage:Construct()
  FriendMsgPage.super.Construct(self)
  self.Border_InputClick.OnMouseButtonDownEvent:Bind(self, self.OnClickInputClick)
end
function FriendMsgPage:ShowMsg()
  LogDebug("FriendMsgPage", "Show new message")
  if self:IsAnimationPlaying(self.FriendMsn_Widget_Open) then
    return
  end
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if friendDataProxy and friendDataProxy.msgQue then
    if friendDataProxy.msgQue:IsEmpty() then
      ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.FriendMsgNtfPage)
      return
    else
      local curMsg = friendDataProxy.msgQue:PopFront()
      if curMsg then
        if self:SetNtfInfo(curMsg) then
          self:PlayWidgetAnimationWithCallBack("FriendMsn_Widget_Open", {
            self,
            function()
              self:ShowMsg()
            end
          })
        else
          self:ShowMsg()
        end
      end
    end
  end
end
function FriendMsgPage:Destruct()
  local friendDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  friendDataProxy.friendMsgPage = nil
  self.Border_InputClick.OnMouseButtonDownEvent:Unbind()
  FriendMsgPage.super.Destruct(self)
end
function FriendMsgPage:SetNtfInfo(inMsg)
  self.curMsgType = inMsg.msgType
  local arg1 = UE4.FFormatArgumentData()
  arg1.ArgumentName = "0"
  arg1.ArgumentValue = inMsg.playerName
  arg1.ArgumentValueType = 4
  local inArgsTarry = UE4.TArray(UE4.FFormatArgumentData)
  inArgsTarry:Add(arg1)
  local WS_IconIndex, TextBlock, textAddNtf
  if inMsg.msgType == FriendEnum.FriendMsgType.AddFriend then
    if not inMsg.playerName or inMsg.playerName == "" then
      return false
    end
    textAddNtf = UE4.UKismetTextLibrary.Format(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "AddNtfText"), inArgsTarry)
    TextBlock = self.Text_AddNtf
    WS_IconIndex = 1
  elseif inMsg.msgType == FriendEnum.FriendMsgType.FriendRequest then
    textAddNtf = UE4.UKismetTextLibrary.Format(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "FriendApplyText"), inArgsTarry)
    TextBlock = self.Text_Apply
    WS_IconIndex = 1
  elseif inMsg.msgType == FriendEnum.FriendMsgType.NotFound then
    textAddNtf = UE4.UKismetTextLibrary.Format(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "NotFoundText"), inArgsTarry)
    TextBlock = self.Text_NotFound
    WS_IconIndex = 2
  elseif inMsg.msgType == FriendEnum.FriendMsgType.IsFriend then
    textAddNtf = UE4.UKismetTextLibrary.Format(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "IsFriendText"), inArgsTarry)
    TextBlock = self.Text_IsFriend
    WS_IconIndex = 0
  elseif inMsg.msgType == FriendEnum.FriendMsgType.RecvFriendApply then
    textAddNtf = UE4.UKismetTextLibrary.Format(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "RecvFriendApplyText"), inArgsTarry)
    TextBlock = self.Text_RecvFriendApply
    WS_IconIndex = 0
  elseif inMsg.msgType == FriendEnum.FriendMsgType.FriendIsLimit then
    WS_IconIndex = 1
  elseif inMsg.msgType == FriendEnum.FriendMsgType.IsBlack then
    textAddNtf = UE4.UKismetTextLibrary.Format(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "IsInBlackListText"), inArgsTarry)
    TextBlock = self.Text_RecvFriendApply
    WS_IconIndex = 2
    GameFacade:SendNotification(NotificationDefines.Chat.AddSystemMsg, textAddNtf)
  elseif inMsg.msgType == FriendEnum.FriendMsgType.SearchSelf then
    WS_IconIndex = 2
  elseif inMsg.msgType == FriendEnum.FriendMsgType.ApplyIsLimit then
    WS_IconIndex = 2
  elseif inMsg.msgType == FriendEnum.FriendMsgType.NewMsg then
    WS_IconIndex = 1
  elseif inMsg.msgType == FriendEnum.FriendMsgType.OtherFriendListFull then
    WS_IconIndex = 2
  elseif inMsg.msgType == FriendEnum.FriendMsgType.AlreadySendFriendRequest then
    textAddNtf = UE4.UKismetTextLibrary.Format(ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "AlreadySendFriendRequestText"), inArgsTarry)
    TextBlock = self.Text_AlreadyAddFriendRequest
    WS_IconIndex = 1
  elseif inMsg.msgType == FriendEnum.FriendMsgType.NewMail then
    WS_IconIndex = 3
  end
  local Valid = inMsg.msgType and self.WS_Msg:SetActiveWidgetIndex(inMsg.msgType)
  Valid = WS_IconIndex and self.WS_Icon:SetActiveWidgetIndex(WS_IconIndex)
  Valid = textAddNtf and TextBlock and TextBlock:SetText(textAddNtf)
  return true
end
function FriendMsgPage:OnClickInputClick()
  if self:IsAnimationPlayingForward(self.FriendMsn_Widget_Open) then
    self:ReverseAnimation(self.FriendMsn_Widget_Open)
    self:SetPlaybackSpeed(self.FriendMsn_Widget_Open, 4)
  end
  if self.curMsgType == FriendEnum.FriendMsgType.RecvFriendApply then
    GameFacade:SendNotification(NotificationDefines.OpenFriendApplyCmd)
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
return FriendMsgPage
