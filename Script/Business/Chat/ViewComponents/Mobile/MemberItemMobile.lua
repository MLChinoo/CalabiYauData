local MemberItemMobile = class("MemberItemMobile", PureMVC.ViewComponentPanel)
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
function MemberItemMobile:ListNeededMediators()
  return {}
end
function MemberItemMobile:InitializeLuaEvent()
end
function MemberItemMobile:OnListItemObjectSet(itemObj)
  self.itemInfo = itemObj
  if itemObj.parent then
    itemObj.parent.actionOnUpdatePlayer:Add(self.UpdatePlayer, self)
    itemObj.parent.actionOnSearchPlayer:Add(self.SearchPlayer, self)
  end
  self:UpdateView()
end
function MemberItemMobile:UpdateView()
  if self.itemInfo then
    local player = self.itemInfo.data
    if self.Img_PlayerIcon then
      local avatarIcon = GameFacade:RetrieveProxy(ProxyNames.BusinessCardDataProxy):GetIconTexture(player.icon)
      if avatarIcon then
        self:SetImageByTexture2D(self.Img_PlayerIcon, avatarIcon)
      else
        LogError("MemberItemMobile", "Player icon or config error")
      end
    end
    if self.Image_Rank then
      local rankIcon = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetDivisionConfigRow(player.rank).IconDivisions
      if rankIcon then
        self:SetImageByPaperSprite(self.Image_Rank, rankIcon)
      else
        LogError("MemberItemMobile", "Rank icon or config error")
      end
    end
    if self.Text_Name then
      self.Text_Name:SetText(player.nick)
    end
    if self.WS_PlayerState then
      if player.status ~= nil then
        if player.status ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_NONE and player.status ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_OFFLINE and player.status ~= Pb_ncmd_cs.EOnlineStatus.OnlineStatus_INVISIBLE then
          self.WS_PlayerState:SetActiveWidgetIndex(0)
        else
          self.WS_PlayerState:SetActiveWidgetIndex(1)
        end
      else
        self.WS_PlayerState:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    if self.Image_Selected then
      self.Image_Selected:SetVisibility(self.itemInfo.isActive and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Hidden)
    end
    if self.Image_Line then
      self.Image_Line:SetVisibility(self.itemInfo.isActive and UE4.ESlateVisibility.Hidden or UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    self:UpdateRedDotNewMsg()
  end
end
function MemberItemMobile:UpdatePlayer(playerInfo)
  if playerInfo and playerInfo.playerId ~= self.itemInfo.data.playerId then
    return
  end
  if playerInfo then
    self.itemInfo.data = playerInfo
  end
  self:UpdateView()
end
function MemberItemMobile:SearchPlayer(nameText)
  if nil == nameText or string.find(self.itemInfo.data.nick, nameText) then
    self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function MemberItemMobile:UpdateRedDotNewMsg()
  if self.RedDot_NewMsg then
    self.RedDot_NewMsg:SetVisibility(self.itemInfo.hasMsg and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
return MemberItemMobile
