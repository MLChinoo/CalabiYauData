local BattleInfoItem = class("BattleInfoItem", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function BattleInfoItem:SetInfoItemData(battleMode, myId, itemInfo, bCheckAI, drawMVPTeam)
  self.playerId = itemInfo.player_id
  self.nick = itemInfo.nick
  self.isAI = false
  if bCheckAI and self.playerId > 1.0E10 then
    self.isAI = true
  end
  if self.Image_Avatar and itemInfo.final_role_id then
    local roleId = itemInfo.final_role_id
    if roleId > 0 then
      local skinShowId = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleCurrentWearSkinID(roleId)
      local skinConfig = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleSkin(skinShowId)
      if nil == skinConfig then
        LogWarn("BattleInfoItem", "Skin id:%d config does not exist!!!", skinShowId)
        skinConfig = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleDefaultSkin(roleId)
        if nil == skinConfig then
          LogWarn("BattleInfoItem", "Default skin id:%d config does not exist!!!", roleId)
        end
      end
      if skinConfig then
        self:SetImageByTexture2D(self.Image_Avatar, skinConfig.IconRoleHud)
      end
      if self.ScaleBox_Avatar then
        self.ScaleBox_Avatar:SetVisibility(skinConfig and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Hidden)
      end
    end
  end
  if self.WidgetSwitcher_BG then
    self.WidgetSwitcher_BG:SetActiveWidgetIndex(itemInfo.player_id == myId and 1 or 0)
    self.WidgetSwitcher_BG:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Text_Name and itemInfo.nick then
    self.Text_Name:SetText(itemInfo.nick)
    self.Text_Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.WidgetSwitcher_MVP then
    self.WidgetSwitcher_MVP:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local mvp = itemInfo.mvp or false
  if self.WidgetSwitcher_MVP then
    if mvp then
      if itemInfo.win == CareerEnumDefine.winType.win or itemInfo.win == CareerEnumDefine.winType.draw and itemInfo.team_id == drawMVPTeam then
        self.WidgetSwitcher_MVP:SetActiveWidgetIndex(0)
      else
        self.WidgetSwitcher_MVP:SetActiveWidgetIndex(1)
      end
    end
    self.WidgetSwitcher_MVP:SetVisibility(mvp and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  local content = {}
  if battleMode == CareerEnumDefine.BattleMode.Bomb then
    table.insert(content, itemInfo.scores or 0)
    local kill = itemInfo.kill_num or 0
    local dead = itemInfo.dead_num or 0
    local assist = itemInfo.assists_num or 0
    table.insert(content, kill .. "/" .. dead .. "/" .. assist)
    table.insert(content, itemInfo.damage or 0)
    table.insert(content, itemInfo.relive_num or 0)
    table.insert(content, itemInfo.place_bomb_num or 0)
    table.insert(content, itemInfo.remove_bomb_num or 0)
  elseif battleMode == CareerEnumDefine.BattleMode.Team then
    table.insert(content, itemInfo.scores or 0)
    local kill = itemInfo.kill_num or 0
    local dead = itemInfo.dead_num or 0
    local assist = itemInfo.assists_num or 0
    table.insert(content, kill .. "/" .. dead .. "/" .. assist)
    table.insert(content, itemInfo.damage or 0)
  elseif battleMode == CareerEnumDefine.BattleMode.Mine then
    table.insert(content, itemInfo.scores or 0)
    local kill = itemInfo.kill_num or 0
    local dead = itemInfo.dead_num or 0
    local assist = itemInfo.assists_num or 0
    table.insert(content, kill .. "/" .. dead .. "/" .. assist)
    table.insert(content, itemInfo.damage or 0)
    table.insert(content, itemInfo.mine)
  end
  if self.Border_Name and self.Border_Content and self.ContentColor then
    self.Border_Name:SetContentColorAndOpacity(self.ContentColor)
    self.Border_Content:SetContentColorAndOpacity(self.ContentColor)
  end
  self:SetContentText(battleMode, content)
end
function BattleInfoItem:ShowInfo(isShown)
  if self.WidgetSwitcher_ShowInfo then
    if isShown then
      self.WidgetSwitcher_ShowInfo:SetActiveWidgetIndex(0)
    else
      self.WidgetSwitcher_ShowInfo:SetActiveWidgetIndex(1)
    end
  end
end
function BattleInfoItem:Construct()
  BattleInfoItem.super.Construct(self)
  if self.WidgetContainer then
    self.textWidgets = self.WidgetContainer:GetAllChildren()
  end
  if self.Border_Click and self.MenuAnchor_Friend then
    self.Border_Click.OnMouseButtonUpEvent:Bind(self, self.OnRightClick)
    self.MenuAnchor_Friend.OnGetMenuContentEvent:Bind(self, self.InitFriendMenu)
  end
end
function BattleInfoItem:Destruct()
  if self.Border_Click and self.MenuAnchor_Friend then
    self.Border_Click.OnMouseButtonUpEvent:Unbind()
    self.MenuAnchor_Friend.OnGetMenuContentEvent:Unbind()
  end
  BattleInfoItem.super.Destruct(self)
end
function BattleInfoItem:SetTitle(battleMode, titleTexts)
  if titleTexts and titleTexts:Length() > 1 and battleMode then
    local content = {}
    if self.Text_Name then
      self.Text_Name:SetText(titleTexts:Get(1))
      self.Text_Name:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    for i = 2, titleTexts:Length() do
      table.insert(content, titleTexts:Get(i))
    end
    if #content > 0 then
      if self.WidgetSwitcher_BG then
        self.WidgetSwitcher_BG:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if self.ScaleBox_Avatar then
        self.ScaleBox_Avatar:SetVisibility(UE4.ESlateVisibility.Hidden)
      end
      if self.WidgetSwitcher_MVP then
        self.WidgetSwitcher_MVP:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
      if self.Border_Name and self.Border_Content and self.TitleColor then
        self.Border_Name:SetContentColorAndOpacity(self.TitleColor)
        self.Border_Content:SetContentColorAndOpacity(self.TitleColor)
      end
      self:SetContentText(battleMode, content)
    end
  end
end
function BattleInfoItem:SetContentText(contentType, contentList)
  local activeIndex = contentType - 1
  if self.WidgetSwitcher_ContentType and self.textWidgets then
    local contentWidget = self.WidgetSwitcher_ContentType:GetChildAt(activeIndex)
    if contentWidget then
      local textSlots = contentWidget:GetAllChildren()
      for key, value in pairs(contentList) do
        if key <= self.textWidgets:Length() and key <= textSlots:Length() then
          self.textWidgets:Get(key):SetText(value)
          textSlots:Get(key):AddChild(self.textWidgets:Get(key))
        end
      end
    end
    self.WidgetSwitcher_ContentType:SetActiveWidgetIndex(activeIndex)
  end
end
function BattleInfoItem:OnRightClick(inGeometry, inMouseEvent)
  if self.playerId and GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerId() == self.playerId then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  LogDebug("BattleInfoItem", "Click item")
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  local keyName = UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(inMouseEvent).KeyName
  if "RightMouseButton" == keyName or platform == GlobalEnumDefine.EPlatformType.Mobile then
    LogDebug("BattleInfoItem", "Is right click or mobile")
    if self.isAI then
      local hintText = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "NoInfoForAI")
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, hintText)
    else
      self.MenuAnchor_Friend:Open(true)
    end
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function BattleInfoItem:InitFriendMenu()
  local friendMenuIns = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_Friend.MenuClass)
  if friendMenuIns then
    local shortcutMenuData = {}
    shortcutMenuData.bPlayerInfo = true
    shortcutMenuData.bFriend = true
    shortcutMenuData.bMsg = true
    shortcutMenuData.bInviteTeam = true
    shortcutMenuData.bShield = true
    shortcutMenuData.bReport = true
    shortcutMenuData.playerId = self.playerId
    shortcutMenuData.playerNick = self.nick
    shortcutMenuData.bIsBattleInfo = true
    friendMenuIns.actionOnExecute:Add(function()
      self.MenuAnchor_Friend:Close()
    end, self)
    friendMenuIns:Init(shortcutMenuData)
    return friendMenuIns
  end
  return nil
end
return BattleInfoItem
