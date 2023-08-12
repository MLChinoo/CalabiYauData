local UpdateMailListCmd = class("UpdateMailListCmd", PureMVC.Command)
local MailProxy
function UpdateMailListCmd:Execute(notification)
  MailProxy = GameFacade:RetrieveProxy(ProxyNames.KaMailProxy)
  local ConditionProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentConditionProxy)
  local Body = notification:GetBody()
  local NotifyType = NotificationDefines.NtfMailDataList
  if Body then
    NotifyType = NotificationDefines.NtfMailDataNewMail
    ConditionProxy.newEmailFlag = true
  end
  GameFacade:SendNotification(NotifyType, self:GetAllMailData())
end
function UpdateMailListCmd:GetAllMailData()
  local AllMailList = MailProxy:GetMailList()
  local MailListData = {}
  local MailTipsList = {}
  local MailNoTipsList = {}
  if AllMailList then
    for key, value in pairs(AllMailList or {}) do
      local data = {}
      local TitleSplit = FunctionUtil:Split(value.title, " | ")
      data.MainTitle = TitleSplit[1]
      data.ImageURL = TitleSplit[2]
      data.MailId = value.mail_id
      data.SendTime = value.send_time
      if 0 == value.mail_state then
        data.IsReaded = false
      else
        data.IsReaded = true
      end
      if value.attach_items and table.count(value.attach_items) > 0 then
        data.ShowAttach = true
      else
        data.ShowAttach = false
      end
      if data.ShowAttach and 0 == value.attach_state then
        data.IsAttached = false
      else
        data.IsAttached = true
      end
      if 0 == value.attach_state and value.attach_items and table.count(value.attach_items) > 0 then
        data.HasAttach = true
        for i, v in pairs(value.attach_items or {}) do
          data.ItemImg = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemImg(v.item_id)
          break
        end
      else
        data.HasAttach = false
      end
      if 0 == value.attach_state and value.attach_items and table.count(value.attach_items) > 0 or 0 == value.mail_state then
        data.IsShowTip = true
        table.insert(MailTipsList, data)
      else
        data.IsShowTip = false
        table.insert(MailNoTipsList, data)
      end
    end
  end
  table.sort(MailTipsList, function(a, b)
    if a.SendTime > b.SendTime then
      return true
    elseif a.SendTime == b.SendTime and a.MailId < b.MailId then
      return true
    end
    return false
  end)
  table.sort(MailNoTipsList, function(a, b)
    if a.SendTime > b.SendTime then
      return true
    elseif a.SendTime == b.SendTime and a.MailId < b.MailId then
      return true
    end
    return false
  end)
  MailListData = table.extend(MailTipsList, MailNoTipsList)
  return MailListData
end
return UpdateMailListCmd
