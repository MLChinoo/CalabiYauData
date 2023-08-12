local FriendStruct = require("Business/Friend/Mediators/FriendStruct")
local FriendEnum = require("Business/Friend/Mediators/FriendEnum")
local FriendListPageMediatorMobile = class("FriendListPageMediatorMobile", PureMVC.Mediator)
local firendListDataProxy
function FriendListPageMediatorMobile:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendListPageMediatorMobile:ListNotificationInterests()
  return {
    NotificationDefines.FriendCmd,
    NotificationDefines.OnResPlayerAttrSync,
    NotificationDefines.Career.BattleRecord.NoAvailableRecord,
    NotificationDefines.FriendInfoChange
  }
end
function FriendListPageMediatorMobile:HandleNotification(notify)
  if notify:GetName() == NotificationDefines.FriendCmd then
    if notify:GetType() == NotificationDefines.FriendCmdType.SearchFriendRes then
      if 0 == table.count(notify:GetBody()) then
        self:GetViewComponent().WS_Friend:SetActiveWidgetIndex(2)
        self:GetViewComponent():PlayAnimation(self:GetViewComponent().Tip_pop, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
        local emptyText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "EmptyText")
        emptyText = string.format(emptyText, "\n")
        self:GetViewComponent().emptyText:SetText(emptyText)
      else
        self:SetFriendListView(notify:GetBody())
      end
    elseif notify:GetType() == NotificationDefines.FriendCmdType.FriendDelNtf or notify:GetType() == NotificationDefines.FriendCmdType.FriendChangeNtf or notify:GetType() == NotificationDefines.FriendCmdType.FriendListNtf or notify:GetType() == NotificationDefines.FriendCmdType.SocialFriendListUpdata or notify:GetType() == NotificationDefines.FriendCmdType.FriendReplyRes then
      if self.curButtonIndex == FriendEnum.SelectCheckStatus.AddFriend and self.currentAddFriendPageStatus == FriendEnum.AddFriendPageStatus.search then
        return
      end
      self:UpdataFriendList()
    end
  end
  if notify:GetName() == NotificationDefines.FriendInfoChange then
    if self.curButtonIndex == FriendEnum.SelectCheckStatus.AddFriend and self.currentAddFriendPageStatus == FriendEnum.AddFriendPageStatus.search then
      return
    end
    self:UpdataFriendList()
  end
  if notify:GetName() == NotificationDefines.Career.BattleRecord.NoAvailableRecord then
    local noSearchNearDataTip = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "NoSearchNearDataTip")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, noSearchNearDataTip)
  end
end
function FriendListPageMediatorMobile:OnRegister()
  firendListDataProxy = GameFacade:RetrieveProxy(ProxyNames.FriendDataProxy)
  if self:GetViewComponent().NavigationBar then
    self:GetViewComponent().NavigationBar.OnItemCheckEvent:Add(self.OnNavigationBarClick, self)
  end
  self:GetViewComponent().actionOnRecentPlayerBtnClick:Add(self.OnRecentPlayerBtnClick, self)
  self:GetViewComponent().actionOnSearchBtnClick:Add(self.OnSearchBtnClick, self)
  self:GetViewComponent().actionOnClearTextBtnClick:Add(self.OnClearTextBtnClick, self)
  self:GetViewComponent().actionOnSearchTextChange:Add(self.OnSearchTextChange, self)
  self:GenerateNavbar(UE4.ECYFunctionMobileTypes.Friend, FriendEnum.SelectCheckStatus.GameFriend)
  self:OnNavigationBarClick(FriendEnum.SelectCheckStatus.GameFriend)
  local entry = self:GetViewComponent().NavigationBar:GetBarByIndex(1)
  local dataCenter = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
  if dataCenter:GetLoginType() == UE4.ELoginType.ELT_QQ then
    if entry then
      local GroupQQText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupQQText")
      entry:SetButtonName(GroupQQText)
    end
  elseif entry then
    local GroupWechatText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupWechatText")
    entry:SetButtonName(GroupWechatText)
  end
end
function FriendListPageMediatorMobile:OnNavigationBarClick(index)
  self.curButtonIndex = index
  self.currentAddFriendPageStatus = FriendEnum.AddFriendPageStatus.normal
  local groupNearText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupNearText")
  self:GetViewComponent().BtnText:SetText(groupNearText)
  if self.curButtonIndex == FriendEnum.SelectCheckStatus.PlatformFriend then
    self:OnCheckPlatformFriendCheck()
    firendListDataProxy:FriendSocialListReq(1)
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.GameFriend then
    self:OnCheckGameFriendCheck()
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.ShieldedFriend then
    self:OnCheckShieldedCheck()
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.AddFriend then
    self:OnCheckAddFriendCheck()
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.ViewReq then
    self:OnCheckViewReqCheck()
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.SetState then
    self:OnCheckSetStateCheck()
  end
  self:UpdataFriendList()
  self:CleanSearchText()
end
function FriendListPageMediatorMobile:GenerateNavbar(barType, selectIndex)
  local proxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  if not proxy then
    return
  end
  local funcTableRow = proxy:GetFunctionMobileById(barType)
  if not funcTableRow then
    return
  end
  local subFuncLen = funcTableRow.SubFunction:Length()
  if subFuncLen > 0 then
    local datas = {}
    self.pageNameArray = {}
    self.curButtonIndex = selectIndex
    for index = 1, subFuncLen do
      local subFuncTableRow = proxy:GetFunctionMobileById(funcTableRow.SubFunction:Get(index))
      if subFuncTableRow then
        local data = {}
        data.barIcon = subFuncTableRow.IconItem
        data.barName = subFuncTableRow.Name
        data.customType = index
        datas[index] = data
        self.pageNameArray[index] = subFuncTableRow.BluePrint
      end
    end
    self:GetViewComponent().NavigationBar:UpdateBar(datas)
    self:GetViewComponent().NavigationBar:SetBarCheckStateByCustomType(selectIndex)
  end
end
function FriendListPageMediatorMobile:UpdataFriendList()
  LogDebug("FriendListPageMediatorMobile", "UpdataFriendList")
  local FriendListDatas = {}
  self:GetViewComponent().WS_Friend:SetActiveWidgetIndex(2)
  self:GetViewComponent():PlayAnimation(self:GetViewComponent().Tip_pop, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self:GetViewComponent().LeftBtnRoot:SetVisibility(UE4.ESlateVisibility.Visible)
  if self.curButtonIndex == FriendEnum.SelectCheckStatus.PlatformFriend then
    if firendListDataProxy.PlatformFriendList then
      for key, value in pairs(firendListDataProxy.PlatformFriendList) do
        table.insert(FriendListDatas, value)
      end
    end
    if 0 == table.count(FriendListDatas) then
      local PlatformFriend
      local dataCenter = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
      if dataCenter:GetLoginType() == UE4.ELoginType.ELT_QQ then
        PlatformFriend = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "NoQQFriend")
      else
        PlatformFriend = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "NoWechatFriend")
      end
      self:GetViewComponent().emptyText:SetText(PlatformFriend)
    end
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.GameFriend then
    if firendListDataProxy.onlineList then
      for key, value in pairs(firendListDataProxy.onlineList) do
        table.insert(FriendListDatas, value)
      end
    end
    if firendListDataProxy.offlineList then
      for key, value in pairs(firendListDataProxy.offlineList) do
        table.insert(FriendListDatas, value)
      end
    end
    if 0 == table.count(FriendListDatas) then
      local noGameFriendText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "NoGameFriendText")
      self:GetViewComponent().emptyText:SetText(noGameFriendText)
    end
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.ShieldedFriend then
    if firendListDataProxy.blackList then
      for key, value in pairs(firendListDataProxy.blackList) do
        table.insert(FriendListDatas, value)
      end
    end
    if 0 == table.count(FriendListDatas) then
      local noBlackFriendText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "NoBlackFriendText")
      self:GetViewComponent().emptyText:SetText(noBlackFriendText)
    end
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.AddFriend then
    if self.currentAddFriendPageStatus == FriendEnum.AddFriendPageStatus.RecentPlayers then
      if firendListDataProxy.nearList then
        for key, value in pairs(firendListDataProxy.nearList) do
          table.insert(FriendListDatas, value)
        end
      end
      if 0 == table.count(FriendListDatas) then
        local noNearFriendText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "NoNearFriendText")
        self:GetViewComponent().emptyText:SetText(noNearFriendText)
      end
    elseif self.currentAddFriendPageStatus == FriendEnum.AddFriendPageStatus.normal then
      local inputPlayNameText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "InputPlayNameText")
      inputPlayNameText = string.format(inputPlayNameText, "\n")
      self:GetViewComponent().emptyText:SetText(inputPlayNameText)
    elseif self.currentAddFriendPageStatus == FriendEnum.AddFriendPageStatus.search and firendListDataProxy.searchedFriends then
      for key, value in pairs(firendListDataProxy.searchedFriends) do
        table.insert(FriendListDatas, value)
      end
    end
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.ViewReq then
    if firendListDataProxy.applyList then
      for key, value in pairs(firendListDataProxy.applyList) do
        table.insert(FriendListDatas, value)
      end
    end
    if 0 == table.count(FriendListDatas) then
      local noReqFriendText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "NoReqFriendText")
      self:GetViewComponent().emptyText:SetText(noReqFriendText)
    end
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.SetState then
    self:GetViewComponent().WS_Friend:SetActiveWidgetIndex(1)
    self:GetViewComponent().LeftBtnRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  table.sort(FriendListDatas, function(a, b)
    if a and b then
      return a.status < b.status
    end
    return false
  end)
  if table.count(FriendListDatas) > 0 then
    self:SetFriendListView(FriendListDatas)
  end
end
function FriendListPageMediatorMobile:SetFriendListView(datas)
  self:GetViewComponent().WS_Friend:SetActiveWidgetIndex(0)
  self:GetViewComponent().FriendListView:ClearListItems()
  for key, value in pairs(datas) do
    local obj = ObjectUtil:CreateLuaUObject(self:GetViewComponent())
    obj.data = value
    obj.currentSelect = self.curButtonIndex
    obj.currentAddFriendPageStatus = self.currentAddFriendPageStatus
    self:GetViewComponent().FriendListView:AddItem(obj)
  end
end
function FriendListPageMediatorMobile:OnRemove()
  if self:GetViewComponent().NavigationBar then
    self:GetViewComponent().NavigationBar.OnItemCheckEvent:Remove(self.OnNavigationBarClick, self)
  end
  self:GetViewComponent().actionOnRecentPlayerBtnClick:Remove(self.OnRecentPlayerBtnClick, self)
  self:GetViewComponent().actionOnSearchBtnClick:Remove(self.OnSearchBtnClick, self)
  self:GetViewComponent().actionOnClearTextBtnClick:Remove(self.OnClearTextBtnClick, self)
  self:GetViewComponent().actionOnSearchTextChange:Remove(self.OnSearchTextChange, self)
end
local getByteCount = function(str)
  local realByteCount = #str
  local length = 0
  local curBytePos = 1
  while true do
    local isSingleChar = false
    local step = 1
    local byteVal = string.byte(str, curBytePos)
    if byteVal > 239 then
      step = 4
    elseif byteVal > 223 then
      step = 3
    elseif byteVal > 191 then
      step = 2
    else
      isSingleChar = true
      step = 1
    end
    curBytePos = curBytePos + step
    if isSingleChar then
      length = length + 1
    else
      length = length + 2
    end
    if realByteCount < curBytePos then
      break
    end
  end
  return length
end
function FriendListPageMediatorMobile:OnSearchTextChange(text)
  self:GetViewComponent().searchBtn:SetIsEnabled("" ~= text)
  if "" == text then
    self:UpdataFriendList()
  elseif getByteCount(text) > 15 then
    local limitNumText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "LimitNumText")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, limitNumText)
    self:GetViewComponent().searchText:SetText(self.LastRemark)
  else
    self.LastRemark = text
  end
end
function FriendListPageMediatorMobile:OnCheckPlatformFriendCheck()
  local PlatformFriend
  local dataCenter = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
  if dataCenter:GetLoginType() == UE4.ELoginType.ELT_QQ then
    PlatformFriend = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupQQText")
  else
    PlatformFriend = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupWechatText")
  end
  self:GetViewComponent().StatuText:SetText(PlatformFriend)
end
function FriendListPageMediatorMobile:OnCheckGameFriendCheck()
  local groupNameText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupFriendText")
  self:GetViewComponent().StatuText:SetText(groupNameText)
end
function FriendListPageMediatorMobile:OnCheckShieldedCheck()
  local groupNameText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupBlackText")
  self:GetViewComponent().StatuText:SetText(groupNameText)
end
function FriendListPageMediatorMobile:OnCheckAddFriendCheck()
  local groupNameText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupAddFriendText")
  self:GetViewComponent().StatuText:SetText(groupNameText)
end
function FriendListPageMediatorMobile:OnCheckViewReqCheck()
  local groupNameText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "ViewReqFriendText")
  self:GetViewComponent().StatuText:SetText(groupNameText)
end
function FriendListPageMediatorMobile:OnCheckSetStateCheck()
  local groupNameText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "SetupStateText")
  self:GetViewComponent().StatuText:SetText(groupNameText)
end
function FriendListPageMediatorMobile:OnRecentPlayerBtnClick()
  self:GetViewComponent().NavigationBar:SetBarCheckStateByCustomType(FriendEnum.SelectCheckStatus.AddFriend)
  self.curButtonIndex = FriendEnum.SelectCheckStatus.AddFriend
  local groupNearText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupNearText")
  local groupAddFriendTex = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "GroupAddFriendText")
  if self.currentAddFriendPageStatus == FriendEnum.AddFriendPageStatus.RecentPlayers then
    self:GetViewComponent().StatuText:SetText(groupAddFriendTex)
    self:GetViewComponent().BtnText:SetText(groupNearText)
    self.currentAddFriendPageStatus = FriendEnum.AddFriendPageStatus.normal
  else
    self:GetViewComponent().BtnText:SetText(groupAddFriendTex)
    self:GetViewComponent().StatuText:SetText(groupNearText)
    self.currentAddFriendPageStatus = FriendEnum.AddFriendPageStatus.RecentPlayers
  end
  self:UpdataFriendList()
end
function FriendListPageMediatorMobile:OnSearchBtnClick()
  local FriendListDatas = {}
  local searchText = tostring(self:GetViewComponent().searchText:GetText())
  if FunctionUtil:have_illegal_char(searchText) then
    local tipsMsg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Common, "haveillegalChar")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, tipsMsg)
    return
  end
  if firendListDataProxy:IsStringFullSpacer(searchText) then
    self:CleanSearchText()
    return
  end
  if self.curButtonIndex == FriendEnum.SelectCheckStatus.AddFriend then
    if self.currentAddFriendPageStatus == FriendEnum.AddFriendPageStatus.RecentPlayers then
      if firendListDataProxy.nearList then
        for key, value in pairs(firendListDataProxy.nearList) do
          if string.find(value.nick, searchText) then
            table.insert(FriendListDatas, value)
          end
        end
      end
    else
      local StringTableStore = StringTablePath.ST_FriendName
      self.currentAddFriendPageStatus = FriendEnum.AddFriendPageStatus.search
      if tonumber(searchText, 10) then
        if firendListDataProxy then
          if firendListDataProxy:GetPlayerID() == tonumber(searchText, 10) then
            local showMsg = ConfigMgr:FromStringTable(StringTableStore, "AddSelf_FriendListText")
            GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, showMsg)
          else
            firendListDataProxy:ReqFriendSearch(searchText, tonumber(searchText, 10))
          end
        end
      elseif "string" == type(searchText) then
        firendListDataProxy:ReqFriendSearch(self:GetViewComponent().searchText:GetText(), firendListDataProxy:GetPlayerID())
      end
      return
    end
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.PlatformFriend then
    if firendListDataProxy.PlatformFriendList then
      for key, value in pairs(firendListDataProxy.PlatformFriendList) do
        if string.find(value.nick, searchText) then
          table.insert(FriendListDatas, value)
        end
      end
    end
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.GameFriend then
    if firendListDataProxy.onlineList then
      for key, value in pairs(firendListDataProxy.onlineList) do
        if string.find(value.nick, searchText) then
          table.insert(FriendListDatas, value)
        end
      end
    end
    if firendListDataProxy.offlineList then
      for key, value in pairs(firendListDataProxy.offlineList) do
        if string.find(value.nick, searchText) then
          table.insert(FriendListDatas, value)
        end
      end
    end
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.ShieldedFriend then
    if firendListDataProxy.blackList then
      for key, value in pairs(firendListDataProxy.blackList) do
        if string.find(value.nick, searchText) then
          table.insert(FriendListDatas, value)
        end
      end
    end
  elseif self.curButtonIndex == FriendEnum.SelectCheckStatus.ViewReq and firendListDataProxy.applyList then
    for key, value in pairs(firendListDataProxy.applyList) do
      if string.find(value.nick, searchText) then
        table.insert(FriendListDatas, value)
      end
    end
  end
  if table.count(FriendListDatas) > 0 then
    self:SetFriendListView(FriendListDatas)
  else
    self:GetViewComponent().WS_Friend:SetActiveWidgetIndex(2)
    self:GetViewComponent():PlayAnimation(self:GetViewComponent().Tip_pop, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    local noSearchTipText = ConfigMgr:FromStringTable(StringTablePath.ST_FriendName, "NoSearchTipText")
    noSearchTipText = string.format(noSearchTipText, "\n")
    self:GetViewComponent().emptyText:SetText(noSearchTipText)
  end
end
function FriendListPageMediatorMobile:CleanSearchText()
  self:GetViewComponent().searchText:SetText("")
end
function FriendListPageMediatorMobile:OnClearTextBtnClick()
  self:CleanSearchText()
end
function FriendListPageMediatorMobile:OnClose()
  if firendListDataProxy and firendListDataProxy.msgQue then
    firendListDataProxy.msgQue:Clear()
  end
end
return FriendListPageMediatorMobile
