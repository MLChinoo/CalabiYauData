local ItemImageDisplayPanel = class("ItemImageDisplayPanel", PureMVC.ViewComponentPanel)
local ItemImageDisplayMediator = require("Business/Common/Mediators/ItemImageDisplay/ItemImageDisplayMediator")
function ItemImageDisplayPanel:ListNeededMediators()
  return {ItemImageDisplayMediator}
end
function ItemImageDisplayPanel:Construct()
  ItemImageDisplayPanel.super.Construct(self)
  self:ClearImage()
end
function ItemImageDisplayPanel:SetImage(itemId)
  local itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(itemId)
  if self.PlayerCard then
    local bIsCard = false
    if itemType == UE4.EItemIdIntervalType.VCardBg then
      local avatarId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardAvatarID)
      self.PlayerCard:SetPlayerData(avatarId, itemId)
      bIsCard = true
    elseif itemType == UE4.EItemIdIntervalType.VCardAvatar then
      local frameId = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy):GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emVCardFrameId)
      self.PlayerCard:SetPlayerData(itemId, frameId)
      bIsCard = true
    end
    if self.WidgetSwitcher_ImageType and bIsCard then
      self.WidgetSwitcher_ImageType:SetActiveWidgetIndex(2)
      self:ShowUWidget(self.WidgetSwitcher_ImageType)
      return
    end
  end
  if self.RoleVoiceDisplay and itemType == UE4.EItemIdIntervalType.RoleVoice then
    self.RoleVoiceDisplay:SetVoiceImage(itemId)
    self.WidgetSwitcher_ImageType:SetActiveWidgetIndex(3)
    self:ShowUWidget(self.WidgetSwitcher_ImageType)
    return
  end
  self:SetDynamicImage(itemId)
end
function ItemImageDisplayPanel:SetDynamicImage(itemId)
  if itemId and self.DynamicIcon then
    if self.DynamicIcon:InitView(itemId) then
      if self.WidgetSwitcher_ImageType then
        self.WidgetSwitcher_ImageType:SetActiveWidgetIndex(1)
      end
    else
      self:SetNormalImage(GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemDisplayImg(itemId))
    end
  end
  if self.WidgetSwitcher_ImageType then
    self:ShowUWidget(self.WidgetSwitcher_ImageType)
  end
end
function ItemImageDisplayPanel:SetNormalImage(img)
  if img and self.Img_Display then
    self:SetImageByTexture2D_MatchSize(self.Img_Display, img)
  end
  if self.WidgetSwitcher_ImageType then
    self.WidgetSwitcher_ImageType:SetActiveWidgetIndex(0)
  end
end
function ItemImageDisplayPanel:ClearImage()
  if self.WidgetSwitcher_ImageType then
    self:HideUWidget(self.WidgetSwitcher_ImageType)
  end
end
function ItemImageDisplayPanel:PlayRoleVoice()
  if self.RoleVoiceDisplay then
    self.RoleVoiceDisplay:PlayRoleVoice()
  end
end
function ItemImageDisplayPanel:StopRoleVoice()
  if self.RoleVoiceDisplay then
    self.RoleVoiceDisplay:StopRoleVoice()
  end
end
return ItemImageDisplayPanel
