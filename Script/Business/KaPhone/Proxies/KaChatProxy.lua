local KaChatProxy = class("KaChatProxy", PureMVC.Proxy)
local CommunicationCfg = {}
function KaChatProxy:ReqReadMsg(RowData)
  if RowData and not self.UniqueMarkMap[RowData.UniqueMark] then
    self.UniqueMarkMap[RowData.UniqueMark] = true
    self:SetFirstRowNameTime(RowData.FirstRowName)
    GameFacade:SendNotification(NotificationDefines.NtfKaChatSubItemState)
    local ChapterId = RowData.FirstRowName .. "&" .. RowData.SortId
    SendRequest(Pb_ncmd_cs.NCmdId.NID_SALON_SAVE_MESSAGE_REQ, pb.encode(Pb_ncmd_cs_lobby.salon_save_message_req, {
      chapter_id = ChapterId,
      select_ids = {
        {
          key = RowData.UniqueMark,
          value = 1
        }
      },
      status = 0
    }))
  end
end
function KaChatProxy:ReqSendMsg(RowData, OptionIndex, InContentIndex)
  if RowData then
    self.UniqueMarkMap[RowData.UniqueMark] = OptionIndex
    self:SetFirstRowNameTime(RowData.FirstRowName)
    GameFacade:SendNotification(NotificationDefines.UpdateKaChatDetail, RowData, InContentIndex)
    local ChapterId = RowData.FirstRowName .. "&" .. RowData.SortId
    SendRequest(Pb_ncmd_cs.NCmdId.NID_SALON_SAVE_MESSAGE_REQ, pb.encode(Pb_ncmd_cs_lobby.salon_save_message_req, {
      chapter_id = ChapterId,
      select_ids = {
        {
          key = RowData.UniqueMark,
          value = OptionIndex
        }
      },
      status = 0
    }))
  end
end
function KaChatProxy:ReqChatEnd(UniqueMark)
  if UniqueMark then
    self.UniqueMarkMap[UniqueMark] = true
  end
  GameFacade:SendNotification(NotificationDefines.NtfKaChatSubItemState)
  local MarkSplit = FunctionUtil:Split(UniqueMark, "&")
  if MarkSplit then
    local FirstRowName, SortId = MarkSplit[1], MarkSplit[2]
    self.UnLockSortId[SortId] = self.UnLockSortId[SortId] and math.max(self.UnLockSortId[SortId], os.time())
    local ChapterId = FirstRowName .. "&" .. SortId
    SendRequest(Pb_ncmd_cs.NCmdId.NID_SALON_SAVE_MESSAGE_REQ, pb.encode(Pb_ncmd_cs_lobby.salon_save_message_req, {
      chapter_id = ChapterId,
      select_ids = {},
      is_over = true
    }))
  end
end
function KaChatProxy:GetClickedJumpButtonStatus()
  local ButtonStatus = false
  ButtonStatus = self.ClickedJumpButton
  self.ClickedJumpButton = false
  return ButtonStatus
end
function KaChatProxy:OnRegister()
  KaChatProxy.super.OnRegister(self)
  self.UnLockFirstRowNames = {}
  self.UnLockSortId = {}
  self.UniqueMarkMap = {}
  self.MessageData = {}
  CommunicationCfg = ConfigMgr:GetCommunicationCfgTableRows()
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_INIT_STATE_SYNC_FINISH_NTF, FuncSlot(self.OnReceiveLoginRes, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_GET_MESSAGE_RES, FuncSlot(self.OnRcvGetMsgRes, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_GET_MESSAGE_NTF, FuncSlot(self.OnRcvGetMsgNtf, self))
    lobbyService:RegistResponse(Pb_ncmd_cs.NCmdId.NID_SALON_SAVE_MESSAGE_RES, FuncSlot(self.OnRcvSaveMsgRes, self))
  end
end
function KaChatProxy:OnRemove()
  KaChatProxy.super.OnRemove(self)
  local lobbyService = GetLobbyServiceHandle()
  if lobbyService then
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_INIT_STATE_SYNC_FINISH_NTF, FuncSlot(self.OnReceiveLoginRes, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_GET_MESSAGE_RES, FuncSlot(self.OnRcvGetMsgRes, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_GET_MESSAGE_NTF, FuncSlot(self.OnRcvGetMsgNtf, self))
    lobbyService:UnregistNty(Pb_ncmd_cs.NCmdId.NID_SALON_SAVE_MESSAGE_RES, FuncSlot(self.OnRcvSaveMsgRes, self))
  end
end
function KaChatProxy:OnReceiveLoginRes()
  SendRequest(Pb_ncmd_cs.NCmdId.NID_SALON_GET_MESSAGE_REQ, pb.encode(Pb_ncmd_cs_lobby.salon_get_message_req, {chapter_id = "0"}))
end
function KaChatProxy:OnRcvGetMsgRes(ServerData)
  local MessageData = DeCode(Pb_ncmd_cs_lobby.salon_get_message_res, ServerData)
  if MessageData then
    if 0 ~= MessageData.code then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, MessageData.code)
    end
    for _, v in pairs(MessageData.msg or {}) do
      self.MessageData[v.chapter_id] = v
    end
    self:UpdateUniqueMarkMap()
  end
  self:InitCommunicationMap()
  self:UpdateRedDotNum()
end
function KaChatProxy:OnRcvGetMsgNtf(ServerData)
  local MessageData = DeCode(Pb_ncmd_cs_lobby.salon_get_message_ntf, ServerData)
  if MessageData then
    for _, v in pairs(MessageData.msg or {}) do
      self.MessageData[v.chapter_id] = v
    end
    self:UpdateUniqueMarkMap()
  end
  self:UpdateRedDotNum()
end
function KaChatProxy:OnRcvSaveMsgRes(ServerData)
  local MessageData = DeCode(Pb_ncmd_cs_lobby.salon_save_message_res, ServerData)
  if MessageData then
    if 0 ~= MessageData.code then
      GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, MessageData.code)
    else
      self:UpdateRedDotNum()
    end
  end
end
function KaChatProxy:UpdateUniqueMarkMap()
  if not self.MessageData then
    return
  end
  for _, v in pairs(self.MessageData) do
    local ChapterSplit = FunctionUtil:Split(v.chapter_id, "&")
    if ChapterSplit then
      local TempTime = v.flush_time
      for _, v1 in pairs(v.select_ids or {}) do
        self.UniqueMarkMap[v1.key] = v1.value
      end
      local FirstRowName = ChapterSplit[1]
      local SortId = ChapterSplit[2]
      self.UnLockFirstRowNames[FirstRowName] = math.max(self.UnLockFirstRowNames[FirstRowName] or 0, TempTime)
      self.UnLockSortId[SortId] = math.max(self.UnLockSortId[SortId] or 0, TempTime)
      if 1 == v.status then
        self.UniqueMarkMap[v.chapter_id .. "&End"] = true
      end
    end
  end
end
function KaChatProxy:UpdateRedDotNum()
  local RedCount = 0
  for FirstRowName, v in pairs(self.FirstCfgMap or {}) do
    if not GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):GetIsFirstEnterRoom(v.RoleId) then
      for SortId, v in pairs(v.SubListMap) do
        if not self:CheckIsLocked(FirstRowName, SortId) and not self:GetPlayerChose(FirstRowName .. "&" .. SortId .. "&Start") then
          RedCount = RedCount + 1
        end
      end
    end
  end
  RedDotTree:SetRedDotCnt(RedDotModuleDef.ModuleName.KaChatSubItem, RedCount)
end
function KaChatProxy:CheckIsLocked(InFirstRowName, InSortId, InUniqueMark)
  if not InFirstRowName then
    return true
  end
  local bUnLockRoles = self.UnLockFirstRowNames[InFirstRowName]
  if bUnLockRoles then
    if InSortId then
      local bLoveLevelEnough = self.UnLockSortId[tostring(InSortId)]
      if bLoveLevelEnough then
        if InUniqueMark then
          return not self.UniqueMarkMap[InUniqueMark]
        end
        return false
      end
      return true
    end
    return false
  end
  return true
end
function KaChatProxy:InitCommunicationMap()
  if self.FirstCfgMap then
    return nil
  else
    self.FirstCfgMap = {}
  end
  for FirstRowName, FirstTableRow in pairs(CommunicationCfg) do
    local SubListMap = {}
    local SubList = FirstTableRow.CommunicationList and FirstTableRow.CommunicationList:ToTable()
    for SortId, TablePtr in pairs(SubList or {}) do
      local SecondListMap = {}
      local NameArray = UE.UDataTableFunctionLibrary.GetDataTableRowNames(TablePtr)
      for i = 1, NameArray:Length() do
        local SecondRowName = NameArray:Get(i)
        local SecondTableRow = UE.UDataTableFunctionLibrary.GetRowDataStructure(TablePtr, SecondRowName)
        SecondListMap[SecondRowName] = self:GetSecondLevelConfig(SecondTableRow, FirstRowName, SortId, SecondRowName)
      end
      SubListMap[SortId] = SecondListMap
    end
    self.FirstCfgMap[FirstRowName] = self:GetFirstLevelConfig(FirstRowName, FirstTableRow, SubListMap)
  end
end
function KaChatProxy:GetFirstLevelConfig(FirstRowName, FirstTableRow, InSubListMap)
  if not FirstTableRow then
    return {}
  end
  return {
    FirstRowName = FirstRowName,
    bNeedShowFavorability = FirstTableRow.bNeedShowFavorability,
    ChatAvatar = FirstTableRow.ChatAvatar,
    ChatNickName = FirstTableRow.ChatNickName,
    RoleId = FirstTableRow.RoleId,
    SubListMap = InSubListMap
  }
end
function KaChatProxy:GetSecondLevelConfig(SecondTableRow, FirstRowName, SortId, SecondRowName)
  if not SecondTableRow then
    return {}
  end
  local InTextContent, InTextureContent, InAkOnEvent
  local InTextContentList = {}
  local InTextureList = {}
  local InEmojiList = {}
  local InOptionalJumpRowNameArray = {}
  if SecondTableRow.Type == UE.ECyCommunicationThirdLevelType.Normal then
    if SecondTableRow.ContentType == UE.ECyCommunicationContentType.Text then
      InTextContent = SecondTableRow.TextContent
    elseif SecondTableRow.ContentType == UE.ECyCommunicationContentType.Texture then
      InTextureContent = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(SecondTableRow.TextureContent)
    elseif SecondTableRow.ContentType == UE.ECyCommunicationContentType.Voice then
      InAkOnEvent = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(SecondTableRow.AkOnEvent)
    end
  elseif SecondTableRow.Type == UE.ECyCommunicationThirdLevelType.PlayerOptions then
    for idx = 1, SecondTableRow.OptionalJumpRowNameArray:Length() do
      InOptionalJumpRowNameArray[idx] = SecondTableRow.OptionalJumpRowNameArray:Get(idx)
      if SecondTableRow.OptionType == UE.ECyCommunicationOptionType.Text then
        InTextContentList[idx] = SecondTableRow.TextContentList:Get(idx)
      elseif SecondTableRow.OptionType == UE.ECyCommunicationOptionType.Texture then
        InTextureList[idx] = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(SecondTableRow.TextureList:Get(idx))
      elseif SecondTableRow.OptionType == UE.ECyCommunicationOptionType.Emoji then
        InEmojiList[idx] = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(SecondTableRow.EmojiList:Get(idx))
      end
    end
  end
  local roleProp = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleProfile(SecondTableRow.FromId)
  return {
    UniqueMark = FirstRowName .. "&" .. SortId .. "&" .. SecondRowName,
    FirstRowName = FirstRowName,
    RoleName = roleProp and roleProp.NameShortCn,
    SortId = SortId,
    SecondRowName = SecondRowName,
    Avatar = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(SecondTableRow.Avatar),
    bIsPlayer = SecondTableRow.bIsPlayer,
    bNeedShowAvatar = SecondTableRow.bNeedShowAvatar,
    FromId = SecondTableRow.FromId,
    TextContent = InTextContent,
    TextureContent = InTextureContent,
    AkOnEvent = InAkOnEvent,
    NormalJumpRowName = SecondTableRow.NormalJumpRowName,
    TextContentList = InTextContentList,
    TextureList = InTextureList,
    EmojiList = InEmojiList,
    OptionalJumpRowNameArray = InOptionalJumpRowNameArray,
    Type = SecondTableRow.Type,
    ContentType = SecondTableRow.ContentType,
    OptionType = SecondTableRow.OptionType
  }
end
function KaChatProxy:GetAllFirstCfgMap()
  return self.FirstCfgMap
end
function KaChatProxy:GetFirstCfg(FirstRowName)
  if FirstRowName and self.FirstCfgMap then
    return self.FirstCfgMap[FirstRowName]
  end
  return {}
end
function KaChatProxy:SecondListCfg(FirstRowName, SortId)
  if FirstRowName and SortId and self.FirstCfgMap and self.FirstCfgMap[FirstRowName] and self.FirstCfgMap[FirstRowName].SubListMap then
    return self.FirstCfgMap[FirstRowName].SubListMap[SortId]
  end
  return {}
end
function KaChatProxy:GetSubItemList(FirstRowName)
  if self.FirstCfgMap and self.FirstCfgMap[FirstRowName] then
    return self.FirstCfgMap[FirstRowName].SubListMap
  end
  return {}
end
function KaChatProxy:GetPlayerChose(InUniqueMark)
  if self.UniqueMarkMap then
    return self.UniqueMarkMap[InUniqueMark]
  end
  return nil
end
function KaChatProxy:GetLatestFirstRowName(InFirstRowName)
  if self.UnLockFirstRowNames and self.UnLockFirstRowNames[InFirstRowName] then
    return self.UnLockFirstRowNames[InFirstRowName]
  end
end
function KaChatProxy:SetFirstRowNameTime(InFirstRowName)
  if self.UnLockFirstRowNames and self.UnLockFirstRowNames[InFirstRowName] then
    self.UnLockFirstRowNames[InFirstRowName] = os.time()
  end
end
return KaChatProxy
