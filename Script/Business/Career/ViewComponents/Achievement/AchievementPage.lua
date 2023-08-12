local AchievementMediator = require("Business/Career/Mediators/Achievement/AchievementMediator")
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
local AchievementPage = class("AchievementPage", PureMVC.ViewComponentPage)
function AchievementPage:ListNeededMediators()
  return {AchievementMediator}
end
function AchievementPage:InitializeLuaEvent()
  LogDebug("AchievementPage", "Init lua event")
  self.actionOnRefresh = LuaEvent.new()
end
function AchievementPage:InitView(achievementMap)
  if self.ScrollBox_Achievement then
    self.ScrollBox_Achievement:ClearChildren()
    local showMaxType = CareerEnumDefine.achievementType.hornor
    if achievementMap[CareerEnumDefine.achievementType.glory].lightNum > 0 then
      showMaxType = CareerEnumDefine.achievementType.glory
    end
    for k, v in pairsByKeys(achievementMap) do
      if k <= showMaxType then
        LogDebug("AchievementPage", "Create panel")
        local PanelClass = ObjectUtil:LoadClass(self.AchievementCategoryPanel)
        if PanelClass then
          local AchievementIns = UE4.UWidgetBlueprintLibrary.Create(self, PanelClass)
          if AchievementIns then
            AchievementIns:InitAchievementPanel(k, v)
            self.ScrollBox_Achievement:AddChild(AchievementIns)
          else
            LogError("AchievementPage", "Panel create failed")
          end
        else
          LogError("AchievementPage", "Panel class load failed")
        end
      end
    end
  end
end
function AchievementPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("AchievementPage", "Lua implement OnOpen")
  self.actionOnRefresh()
  if self.bHideChat then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  end
  if self.EnterInto then
    self:PlayAnimation(self.EnterInto, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  end
end
function AchievementPage:OnClose()
  if self.bHideChat then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  end
end
function AchievementPage:ShowAchievementTypeInfo()
  if self.WidgetSwitcher_Achievement then
    self.WidgetSwitcher_Achievement:SetActiveWidgetIndex(1)
  end
end
function AchievementPage:ShowMedalInfo()
  if self.WidgetSwitcher_Achievement then
    self.WidgetSwitcher_Achievement:SetActiveWidgetIndex(2)
  end
end
function AchievementPage:OnEscHotKeyClick()
  LogInfo("AchievementPage", "OnEscHotKeyClick")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
return AchievementPage
