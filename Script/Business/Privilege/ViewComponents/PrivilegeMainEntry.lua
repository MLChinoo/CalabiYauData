local PrivilegeMainEntry = class("PrivilegeMainEntry", PureMVC.ViewComponentPanel)
function PrivilegeMainEntry:Construct()
  self.super.Construct(self)
  self.LoginDC = UE4.UPMLoginDataCenter.Get(LuaGetWorld())
  self.LoginType = UE4.ELoginType.ELT_None
  if self.LoginDC then
    self.LoginType = self.LoginDC:GetLoginType()
  end
  if self.LoginType == UE4.ELoginType.ELT_QQ and self.BtnQQEntry then
    self.BtnQQEntry.OnClicked:Add(self, self.EnterQQPrivilegeCenter)
    self.BtnQQEntry:SetVisibility(UE4.ESlateVisibility.Visible)
  end
end
function PrivilegeMainEntry:Destruct()
  self.super.Destruct(self)
end
function PrivilegeMainEntry:EnterQQPrivilegeCenter()
  local GCloudSdkSubSystem = UE4.UPMGCloudSdkSubSystem.GetInst(LuaGetWorld())
  if GCloudSdkSubSystem then
    GCloudSdkSubSystem:OpenWebView(self.QQGameCenterUrl, 2, 1)
  end
end
return PrivilegeMainEntry
