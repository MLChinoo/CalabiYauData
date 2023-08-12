local ShowCommonTipCmd = class("ShowCommonTipCmd", PureMVC.Command)
local DefaultTipMsg
function _G.ShowCommonTip(msg)
  if nil == DefaultTipMsg then
    DefaultTipMsg = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "DefaultTipMsg")
  end
  msg = msg or DefaultTipMsg
  GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, msg)
end
function ShowCommonTipCmd:GetRealShowMsg(data)
  local msg
  local _GetRealShowMsg = function(_msg)
    if type(_msg) == "string" then
      return _msg
    elseif type(_msg) == "number" and 0 ~= _msg then
      local errorCodeLuaTable = ConfigMgr:GetErrorCodeTableRows()
      if errorCodeLuaTable[tostring(_msg)] then
        return errorCodeLuaTable[tostring(_msg)].ErrorDesc
      else
        local s = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "UnknownError")
        return ObjectUtil:GetTextFromFormat(s, {
          tostring(_msg)
        })
      end
    end
  end
  if type(data) == "table" then
    msg = _GetRealShowMsg(data.showMsg)
  else
    msg = _GetRealShowMsg(data)
  end
  return msg
end
function ShowCommonTipCmd:Execute(notification)
  if notification.body then
    local data = notification.body
    if 3074 == data or "3074" == data then
      LogDebug("ShowCommonTipCmd", "notification.body is 3074 CreditScorePage, Dont Show Tip!")
      return nil
    end
    local realMsg = self:GetRealShowMsg(data)
    if type(realMsg) == "string" then
      local PopUpPromptProxy = GameFacade:RetrieveProxy(ProxyNames.PopUpPromptProxy)
      if PopUpPromptProxy:GetPrompUIExistFlag() then
        GameFacade:SendNotification(NotificationDefines.ShowCommonTip, {msg = realMsg, oriData = data})
      else
        ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.PopUpPromptPage, false, {realMsg = realMsg, oriData = data})
      end
    else
      LogDebug("ShowCommonTipCmd", "Execute ShowCommonTipCmd Error, the data is invalid, please check data!")
    end
  else
    LogDebug("ShowCommonTipCmd", "notification.body is nil")
  end
end
return ShowCommonTipCmd
