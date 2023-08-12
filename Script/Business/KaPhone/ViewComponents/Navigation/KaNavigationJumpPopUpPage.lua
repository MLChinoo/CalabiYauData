local KaNavigationJumpPopUpPage = class("KaNavigationJumpPopUpPage", PureMVC.ViewComponentPage)
local Valid
function KaNavigationJumpPopUpPage:LuaHandleKeyEvent(key, inputEvent)
  return self.Button_Custom:MonitorKeyDown(key, inputEvent)
end
function KaNavigationJumpPopUpPage:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.Button_Confirm and self.Button_Confirm.OnClicked:Add(self, self.OnClickConfirm)
  Valid = self.Button_Return and self.Button_Return.OnClicked:Add(self, self.OnClickReturn)
  Valid = self.Navigation_Pop and self:PlayAnimationForward(self.Navigation_Pop, 1, false)
  local Body = {
    Page = self,
    RoleId = self.RoleId
  }
  if luaOpenData and luaOpenData.RoleId then
    local Name = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleProfile(luaOpenData.RoleId).NameShortCn
    Valid = Name and self.TextBlock_RoleName and self.TextBlock_RoleName:SetText(Name)
  end
  self.RoleData = luaOpenData
end
function KaNavigationJumpPopUpPage:OnClose()
  Valid = self.Button_Confirm and self.Button_Confirm.OnClicked:Remove(self, self.OnClickConfirm)
  Valid = self.Button_Return and self.Button_Return.OnClicked:Remove(self, self.OnClickReturn)
  self:StopAllAnimations()
end
function KaNavigationJumpPopUpPage:OnClickConfirm()
  GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy):ReqUpdateRole(self.RoleData)
  GameFacade:SendNotification(NotificationDefines.JumpToPageCmd, {
    target = UIPageNameDefine.KaPhonePage
  }, true)
  ViewMgr:ClosePage(self)
end
function KaNavigationJumpPopUpPage:OnClickReturn()
  ViewMgr:ClosePage(self)
end
return KaNavigationJumpPopUpPage
