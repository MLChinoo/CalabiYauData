local PlayerCardLevelMapPage = class("PlayerCardLevelMapPage", PureMVC.ViewComponentPage)
function PlayerCardLevelMapPage:InitializeLuaEvent()
  LogDebug("PlayerCardLevelMapPage", "Init lua event")
end
function PlayerCardLevelMapPage:OnOpen(luaOpenData, nativeOpenData)
  if self.Btn_ClosePage then
    self.Btn_ClosePage.OnClickEvent:Add(self, self.OnClickClosePage)
  end
  self:InitPageData()
end
function PlayerCardLevelMapPage:OnClose()
  if self.Btn_ClosePage then
    self.Btn_ClosePage.OnClickEvent:Remove(self, self.OnClickClosePage)
  end
end
function PlayerCardLevelMapPage:LuaHandleKeyEvent(key, inputEvent)
  return self.Btn_ClosePage:MonitorKeyDown(key, inputEvent)
end
function PlayerCardLevelMapPage:InitPageData()
  local arrRows = ConfigMgr:GetPlayerLevelTableRows()
  if arrRows then
    local playerLevelCfg = arrRows:ToLuaTable()
    if playerLevelCfg and table.count(playerLevelCfg) > 0 then
      for index = 1, table.count(playerLevelCfg) do
        if playerLevelCfg[tostring(index)] then
          local item = playerLevelCfg[tostring(index)]
          if item.Levelbox and not item.Levelbox:IsNull() and item.Lv and self.DynamicEntryBox_PlayerLevelMap then
            local widget = self.DynamicEntryBox_PlayerLevelMap:BP_CreateEntry()
            if widget then
              widget:InitInfo(item.Lv, item.Levelbox)
            end
          end
        end
      end
    end
  else
    LogInfo("PlayerCardLevelMapPage InitPageData", "arrRows is nil")
  end
end
function PlayerCardLevelMapPage:OnClickClosePage()
  ViewMgr:ClosePage(self)
end
return PlayerCardLevelMapPage
