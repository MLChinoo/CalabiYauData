local KaPhoneMsgItem = class("KaPhoneMsgItem", PureMVC.ViewComponentPanel)
local Collapsed = UE.ESlateVisibility.Collapsed
local Visible = UE.ESlateVisibility.Visible
local SelfHitTestInvisible = UE.ESlateVisibility.SelfHitTestInvisible
local Valid
function KaPhoneMsgItem:Construct()
  KaPhoneMsgItem.super.Construct(self)
  Valid = self.TextButton and self.TextButton.OnClicked:Add(self, self.OnMsgClicked)
end
function KaPhoneMsgItem:Destruct()
  Valid = self.TextButton and self.TextButton.OnClicked:Remove(self, self.OnMsgClicked)
  KaPhoneMsgItem.super.Destruct(self)
end
function KaPhoneMsgItem:Init(TableRow, Idx, InContentIndex)
  self.IsJumpContent = false
  self.InContentIndex = InContentIndex
  self.MsgInfo = {
    IsNpc = not TableRow.bIsPlayer,
    RoleAvatar = TableRow.Avatar,
    PlayerAvatar = TableRow.Avatar,
    IsShowAvatar = TableRow.bNeedShowAvatar,
    OptionType = TableRow.OptionType,
    ContentText = TableRow.TextContentList and TableRow.TextContentList[Idx],
    ContentPicture = TableRow.EmojiList and TableRow.EmojiList[Idx]
  }
  self.RowData = TableRow
  self.Id = Idx
  local ContentLength = FunctionUtil:getByteCount(self.MsgInfo.ContentText)
  ContentLength = ContentLength > self.TextLength and self.TextLength or ContentLength
  local ContentText = FunctionUtil:getSubStringByCount(self.MsgInfo.ContentText, 1, ContentLength)
  Valid = self.Content and self.Content:SetText(ContentText)
  Valid = self.Content_1 and self.Content_1:SetVisibility(FunctionUtil:getByteCount(self.MsgInfo.ContentText) > self.TextLength and SelfHitTestInvisible or Collapsed)
  Valid = self.AnimOpen and self:PlayAnimationForward(self.AnimOpen, 1, false)
end
function KaPhoneMsgItem:OnMsgClicked()
  Valid = GameFacade:RetrieveProxy(ProxyNames.KaChatProxy):ReqSendMsg(self.RowData, self.Id, self.InContentIndex)
end
return KaPhoneMsgItem
