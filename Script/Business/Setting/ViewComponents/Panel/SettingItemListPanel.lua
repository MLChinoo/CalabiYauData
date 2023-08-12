local SettingItemListPanel = class("SettingItemListPanel", PureMVC.ViewComponentPanel)
local SettingEnum = require("Business/Setting/Proxies/SettingEnum")
local SettingHelper = require("Business/Setting/Proxies/SettingHelper")
local TabStyle = SettingEnum.TabStyle
function SettingItemListPanel:ListNeededMediators()
  return {}
end
function SettingItemListPanel:InitializeLuaEvent()
end
function SettingItemListPanel:InitView(data)
  for _, titleStr in ipairs(data.titleList) do
    if string.find(titleStr, "None") == nil then
      local args = {title = titleStr}
      local view = SettingHelper.CreateTitleItem(args)
      self.VerticalBox_Basic:AddChild(view)
    end
    for _, item in ipairs(data.itemList[titleStr]) do
      if SettingHelper.CheckHideStatus(item.status) == false then
        local viewItem = SettingHelper.CreateInteractItem(item)
        self.VerticalBox_Basic:AddChild(viewItem)
      end
    end
  end
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  local count = self.VerticalBox_Basic:GetChildrenCount()
  if platform == GlobalEnumDefine.EPlatformType.Mobile then
    local margin = UE4.FMargin()
    margin.Right = 20
    self.VerticalBox_Basic.Slot:SetPadding(margin)
    self.ScrollBox_Basic:SetScrollBarVisibility(UE4.ESlateVisibility.HitTestInvisible)
  elseif count < 14 then
    local margin = UE4.FMargin()
    margin.Right = 10
    self.VerticalBox_Basic.Slot:SetPadding(margin)
  end
  self.ScrollBox_Basic.OnUserScrolled:Add(self, self.OnScrolled)
end
function SettingItemListPanel:OnScrolled()
  GameFacade:SendNotification(NotificationDefines.Setting.SettingListScrolled)
end
function SettingItemListPanel:OnClose()
end
return SettingItemListPanel
