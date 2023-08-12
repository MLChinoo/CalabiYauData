local UpdateMailDetailCmd = class("UpdateMailDetailCmd", PureMVC.Command)
local MailProxy, itemsProxy
function UpdateMailDetailCmd:Execute(notification)
  MailProxy = GameFacade:RetrieveProxy(ProxyNames.KaMailProxy)
  itemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local Body = notification:GetBody()
  GameFacade:SendNotification(NotificationDefines.NtfMailDataDetail, self:GetMailDetailData(Body))
end
function UpdateMailDetailCmd:GetMailDetailData(MailId)
  local MailData = MailProxy:GetMailData(MailId)
  if not MailData then
    return
  end
  local Data = {}
  local AttachList
  if 0 == MailData.attach_state then
    Data.IsAttached = false
  else
    Data.IsAttached = true
  end
  if MailData.attach_items and table.count(MailData.attach_items) > 0 then
    AttachList = {}
    for i, v in pairs(MailData.attach_items or {}) do
      local ItemData = {}
      ItemData.ItemId = v.item_id
      ItemData.ItemImg = itemsProxy:GetAnyItemImg(v.item_id)
      local QualityID = itemsProxy:GetAnyItemQuality(v.item_id)
      local ItemQualityColorCfg = itemsProxy:GetItemQualityConfig(QualityID)
      if ItemQualityColorCfg then
        ItemData.ItemQualityColor = UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(ItemQualityColorCfg.Color))
      else
        LogError("Lua:UpdateMailCmd", "Cant find QualityID By ItemID! Check itemsProxy:GetAnyItemQuality.")
      end
      ItemData.ItemNum = v.item_count
      ItemData.IsAttached = Data.IsAttached
      table.insert(AttachList, ItemData)
    end
  end
  Data.MailId = MailData.mail_id
  local TitleSplit = FunctionUtil:Split(MailData.title, "|")
  Data.Title = TitleSplit[1]
  Data.Content = MailData.content
  Data.MailId = MailData.mail_id
  Data.SendTime = MailData.send_time
  if AttachList then
    table.sort(AttachList, function(a, b)
      if a.ItemId > b.ItemId then
        return true
      end
      return false
    end)
    Data.AttachList = AttachList
  end
  return Data
end
return UpdateMailDetailCmd
