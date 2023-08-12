local SeasonPrizePage = class("SeasonPrizePage", PureMVC.ViewComponentPage)
local SeasonPrizeMediator = require("Business/Career/Mediators/CareerRank/SeasonPrizeMediator")
function SeasonPrizePage:ListNeededMediators()
  return {SeasonPrizeMediator}
end
function SeasonPrizePage:InitView(prizeInfo)
  self.prizeMap = {}
  local index = 1
  for key, value in pairsByKeys(prizeInfo.prizeList, function(a, b)
    return a < b
  end) do
    if key ~= prizeInfo.firstId then
      self.prizeArray:Get(index):InitView(value, key == prizeInfo.firstId)
      self.prizeMap[key] = self.prizeArray:Get(index)
    end
    index = index + 1
  end
end
function SeasonPrizePage:UpdatePrizeState(prizeId, status)
  if self.prizeMap[prizeId] then
    self.prizeMap[prizeId]:SetPrizeState(status)
  end
end
function SeasonPrizePage:Construct()
  SeasonPrizePage.super.Construct(self)
  if self.Button_Return then
    self.Button_Return.actionOnReturn:Add(self.OnClickReturn, self)
  end
  if self.Grid_PrizeList then
    self.prizeArray = self.Grid_PrizeList:GetAllChildren()
  end
  local seasonId = GameFacade:RetrieveProxy(ProxyNames.CareerRankDataProxy):GetSeasonInfo().season_id
  if seasonId then
    self:InitPageWidget(seasonId)
    GameFacade:SendNotification(NotificationDefines.Career.CareerRank.GetSeasonPrizeCmd, seasonId)
  end
  if self.ComboBox_Season then
    self.ComboBox_Season.OnSelectionChanged:Add(self, self.SelectSeason)
    self.ComboBox_Season.OnMenuOpenChanged:Add(self, self.OnSeasonMenuOpenChanged)
  end
end
function SeasonPrizePage:Destruct()
  if self.Button_Return then
    self.Button_Return.actionOnReturn:Remove(self.OnClickReturn, self)
  end
  if self.ComboBox_Season then
    self.ComboBox_Season.OnSelectionChanged:Remove(self, self.SelectSeason)
    self.ComboBox_Season.OnMenuOpenChanged:Remove(self, self.OnSeasonMenuOpenChanged)
  end
  SeasonPrizePage.super.Destruct(self)
end
function SeasonPrizePage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("SeasonPrizePage", "Lua implement OnOpen")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, true)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar, false)
  self.parentPage = luaOpenData
  if self.parentPage then
    self.parentPage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function SeasonPrizePage:OnClose()
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchIgnoreEsc, false)
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplaySecondNavBar, true)
  ViewMgr:ClosePage(self, UIPageNameDefine.CareerPrizeDisplay)
  if self.parentPage then
    self.parentPage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function SeasonPrizePage:InitPageWidget(seasonId)
  if self.ComboBox_Season and seasonId then
    self.ComboBox_Season:ClearOptions()
    for i = 1, seasonId do
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "SeasonText")
      local stringMap = {
        [0] = i
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.ComboBox_Season:AddOption(text)
    end
    self.ComboBox_Season:SetSelectedIndex(seasonId - 1)
  end
end
function SeasonPrizePage:ShowPage(shouldShow)
  self:SetVisibility(shouldShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
end
function SeasonPrizePage:SelectSeason(seasonStr, selectionType)
  local seasonId = self.ComboBox_Season:FindOptionIndex(seasonStr) + 1
  GameFacade:SendNotification(NotificationDefines.Career.CareerRank.GetSeasonPrizeCmd, seasonId)
end
function SeasonPrizePage:OnSeasonMenuOpenChanged(isOpen)
  if self.Image_Arrow then
    if isOpen then
      self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, 1))
    else
      self.Image_Arrow:SetRenderScale(UE4.FVector2D(1, -1))
    end
  end
end
function SeasonPrizePage:LuaHandleKeyEvent(key, inputEvent)
  if self.Button_Return then
    return self.Button_Return:LuaHandleKeyEvent(key, inputEvent)
  end
  return false
end
function SeasonPrizePage:OnClickReturn()
  ViewMgr:ClosePage(self)
end
return SeasonPrizePage
