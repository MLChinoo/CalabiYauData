local UpdatePhoneChatDetailCmd = class("UpdatePhoneChatDetailCmd", PureMVC.Command)
local KaPhoneProxy, KaChatProxy, KaMailProxy, RoleProxy
function UpdatePhoneChatDetailCmd:Execute(notification)
  KaPhoneProxy = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy)
  KaChatProxy = GameFacade:RetrieveProxy(ProxyNames.KaChatProxy)
  KaMailProxy = GameFacade:RetrieveProxy(ProxyNames.KaMailProxy)
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local Body = notification:GetBody()
  local Type = notification:GetType()
  local ChatDetailName = ""
  if Type then
    self.SecondListMap = KaChatProxy:SecondListCfg(Body.FirstRowName, Body.SortId)
    ChatDetailName = self:GetChatName(Body.FirstRowName)
    GameFacade:SendNotification(NotificationDefines.NtfKaChatNewDetail, self:GetListData(Body.SecondRowName, Type))
  else
    self.SecondListMap = Body
    if self.SecondListMap and self.SecondListMap.Start then
      ChatDetailName = self:GetChatName(self.SecondListMap.Start.FirstRowName)
    end
    GameFacade:SendNotification(NotificationDefines.NtfKaChatDetail, self:GetListData("Start", 1), ChatDetailName)
  end
end
function UpdatePhoneChatDetailCmd:GetListData(StartIndex, InContentIndex)
  if not self.SecondListMap then
    return {}
  end
  local ContentList = {}
  local Index = StartIndex
  local ContentIndex = InContentIndex
  if self.SecondListMap then
    KaChatProxy = GameFacade:RetrieveProxy(ProxyNames.KaChatProxy)
    while self.SecondListMap[Index] do
      local CurTableRow = self.SecondListMap[Index]
      if CurTableRow.Type == UE.ECyCommunicationThirdLevelType.Normal then
        ContentList[ContentIndex] = self:GetNormalContent(CurTableRow)
        Index = CurTableRow.NormalJumpRowName
      elseif CurTableRow.Type == UE.ECyCommunicationThirdLevelType.PlayerOptions then
        if CurTableRow.UniqueMark then
          local OptionIndex = KaChatProxy:GetPlayerChose(CurTableRow.UniqueMark)
          if OptionIndex then
            ContentList[ContentIndex] = self:GetOptionContent(CurTableRow, OptionIndex)
            Index = CurTableRow.OptionalJumpRowNameArray and CurTableRow.OptionalJumpRowNameArray[OptionIndex] or "End"
          else
            ContentList[ContentIndex] = {IsNeedOpenOption = true, OptionData = CurTableRow}
            break
          end
        end
      elseif CurTableRow.Type == UE.ECyCommunicationThirdLevelType.End then
        ContentList[ContentIndex] = {
          IsAddStopTip = true,
          UniqueMark = CurTableRow.UniqueMark
        }
        break
      else
        ContentList[ContentIndex] = {
          IsAddStopTip = true,
          UniqueMark = CurTableRow.UniqueMark
        }
        break
      end
      ContentIndex = ContentIndex + 1
    end
  end
  return ContentList
end
function UpdatePhoneChatDetailCmd:GetNormalContent(RowData)
  local Data = {
    RoleName = RowData.RoleName,
    IsNpc = not RowData.bIsPlayer,
    UniqueMark = RowData.UniqueMark,
    RoleAvatar = RowData.Avatar,
    PlayerAvatar = RowData.Avatar,
    IsShowAvatar = RowData.bNeedShowAvatar,
    ContentType = RowData.ContentType,
    ContentAkEvent = RowData.AkOnEvent,
    ContentText = RowData.TextContent,
    ContentPicture = RowData.TextureContent
  }
  return Data
end
function UpdatePhoneChatDetailCmd:GetOptionContent(RowData, OptionIndex)
  if OptionIndex > 0 then
    local TextContentList = RowData.TextContentList and RowData.TextContentList[OptionIndex]
    local EmojiList = RowData.EmojiList and RowData.EmojiList[OptionIndex]
    local TextureList = RowData.TextureList and RowData.TextureList[OptionIndex]
    local Data = {
      IsNpc = not RowData.bIsPlayer,
      RoleAvatar = RowData.Avatar,
      UniqueMark = RowData.UniqueMark,
      PlayerAvatar = RowData.Avatar,
      IsShowAvatar = RowData.bNeedShowAvatar,
      OptionType = RowData.OptionType,
      ContentText = TextContentList,
      ContentPicture = EmojiList,
      TextContentList = TextContentList,
      EmojiList = EmojiList,
      TextureList = TextureList
    }
    return Data
  end
  return {}
end
function UpdatePhoneChatDetailCmd:GetChatName(FirstRowName)
  local FirstCfg = KaChatProxy:GetFirstCfg(FirstRowName)
  return FirstCfg.ChatNickName
end
return UpdatePhoneChatDetailCmd
