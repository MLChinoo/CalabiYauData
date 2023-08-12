local UpdatePhoneChatCmd = class("UpdatePhoneChatCmd", PureMVC.Command)
function UpdatePhoneChatCmd:Execute(notification)
  local KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  local KaChatProxy = GameFacade:RetrieveProxy(ProxyNames.KaChatProxy)
  local KaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local AllChatData = KaChatProxy:GetAllFirstCfgMap()
  local ChatItemListData = {}
  local NewChatItemListData = {}
  for FirstRowName, FirstTableCfg in pairs(AllChatData or {}) do
    if not KaChatProxy:CheckIsLocked(FirstTableCfg.FirstRowName) and not KaNavigationProxy:GetIsFirstEnterRoom(FirstTableCfg.RoleId) then
      local RoleProperties = KaPhoneProxy:GetRoleProperties(FirstTableCfg.RoleId)
      local TempSubChatItemData, bIsNew = self:GetSubListMap(FirstTableCfg.SubListMap, FirstRowName)
      if bIsNew then
        NewChatItemListData[FirstRowName] = {
          FirstRowName = FirstTableCfg.FirstRowName,
          RoleId = FirstTableCfg.RoleId,
          Avatar = FirstTableCfg.ChatAvatar,
          LoveLevel = FirstTableCfg.bNeedShowFavorability and RoleProperties.intimacy_lv or 0,
          Name = FirstTableCfg.ChatNickName,
          SubChatItemData = TempSubChatItemData
        }
      else
        ChatItemListData[FirstRowName] = {
          FirstRowName = FirstTableCfg.FirstRowName,
          RoleId = FirstTableCfg.RoleId,
          Avatar = FirstTableCfg.ChatAvatar,
          LoveLevel = FirstTableCfg.bNeedShowFavorability and RoleProperties.intimacy_lv or 0,
          Name = FirstTableCfg.ChatNickName,
          SubChatItemData = TempSubChatItemData
        }
      end
    end
  end
  GameFacade:SendNotification(NotificationDefines.NtfKaChatList, {NewData = NewChatItemListData, ReadData = ChatItemListData})
end
function UpdatePhoneChatCmd:GetSubListMap(OriMap, InFirstRowName)
  local ResultMap = {}
  local bIsNew = false
  for SortId, SecondListMap in pairs(OriMap) do
    if not GameFacade:RetrieveProxy(ProxyNames.KaChatProxy):CheckIsLocked(InFirstRowName, SortId) then
      ResultMap[SortId], bIsNew = self:GetSubItemTitleData(SecondListMap)
    end
  end
  return ResultMap, bIsNew
end
function UpdatePhoneChatCmd:GetSubItemTitleData(InSecondListMap)
  local ResultMap = {}
  local bIsNew = false
  local EndUniqueMark = InSecondListMap and InSecondListMap.End
  local StartUniqueMark = InSecondListMap and InSecondListMap.Start
  if InSecondListMap then
    local KaChatProxy = GameFacade:RetrieveProxy(ProxyNames.KaChatProxy)
    if KaChatProxy:GetPlayerChose(EndUniqueMark.UniqueMark) then
      ResultMap.bIsFinish = true
    elseif KaChatProxy:GetPlayerChose(StartUniqueMark.UniqueMark) then
      ResultMap.bIsReaded = true
    else
      bIsNew = true
    end
  end
  ResultMap.Content = StartUniqueMark.TextContent
  ResultMap.SecondListMap = InSecondListMap
  return ResultMap, bIsNew
end
return UpdatePhoneChatCmd
