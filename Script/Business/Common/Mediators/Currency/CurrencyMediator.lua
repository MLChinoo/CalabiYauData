local CurrencyMediator = class("CurrencyMediator", PureMVC.Mediator)
function CurrencyMediator:ListNotificationInterests()
  return {
    NotificationDefines.OnResPlayerAttrSync
  }
end
function CurrencyMediator:OnRegister()
  self:GetViewComponent().initViewEvent:Add(self.GenerateData, self)
end
function CurrencyMediator:OnRemove()
  self:GetViewComponent().initViewEvent:Remove(self.GenerateData, self)
end
function CurrencyMediator:HandleNotification(notification)
  local noteName = notification:GetName()
  if noteName == NotificationDefines.OnResPlayerAttrSync then
    self:GenerateData()
  end
end
function CurrencyMediator:GenerateData()
  local proxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  if proxy then
    local crystal = proxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emCrystal)
    local Ideal = proxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emIdeal)
    local roleScrap = proxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emRoleScrap)
    local weaponScrap = proxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emWeaponScrap)
    self:GetViewComponent():UpdateView(crystal, Ideal, roleScrap, weaponScrap)
  end
end
return CurrencyMediator
