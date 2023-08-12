local KaMailPanelMobile = class("KaMailPanelMobile", PureMVC.ViewComponentPanel)
local kaMailMediator = require("Business/KaPhone/Mediators/KaMailMediator")
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function KaMailPanelMobile:GetIsActive()
  return self.IsActive
end
function KaMailPanelMobile:SetIsActive(IsActive)
  self.IsActive = IsActive
end
function KaMailPanelMobile:Update(MailData)
  self.ImageMap = {}
  self.AttachMail = {}
  self.ReadedMail = {}
  self.MailItemList:ClearListItems()
  for key, value in pairs(MailData or {}) do
    self:GenerateItem(value)
  end
  self.MailItemList:ScrollToTop()
end
function KaMailPanelMobile:UpdateMailDetail(DetailData)
  self.BackgroundLogo:SetVisibility(Collapsed)
  self.MailDetail:Update(DetailData)
end
function KaMailPanelMobile:SetSwitcher(index)
end
function KaMailPanelMobile:AddImageMap(key, value)
  self.ImageMap[key] = value
end
function KaMailPanelMobile:GetImageMap()
  return self.ImageMap
end
function KaMailPanelMobile:GenerateItem(Data)
  local obj = ObjectUtil:CreateLuaUObject(self)
  obj.data = Data
  obj.Parent = self
  self.MailItemList:AddItem(obj)
  Valid = Data.IsShowTip or table.insert(self.ReadedMail, Data.MailId)
  Valid = Data.HasAttach and table.insert(self.AttachMail, Data.MailId)
end
function KaMailPanelMobile:ListNeededMediators()
  return {kaMailMediator}
end
function KaMailPanelMobile:Construct()
  KaMailPanelMobile.super.Construct(self)
  self:BindEvent()
end
function KaMailPanelMobile:Destruct()
  KaMailPanelMobile.super.Destruct(self)
  self:RemoveEvent()
end
function KaMailPanelMobile:BindEvent()
  Valid = self.Button_DeleteReaded and self.Button_DeleteReaded.OnClicked:Add(self, self.OnClickDeleteReaded)
  Valid = self.Button_AttachAll and self.Button_AttachAll.OnClicked:Add(self, self.OnClickAttatchAll)
end
function KaMailPanelMobile:RemoveEvent()
  Valid = self.Button_DeleteReaded and self.Button_DeleteReaded.OnClicked:Remove(self, self.OnClickDeleteReaded)
  Valid = self.Button_AttachAll and self.Button_AttachAll.OnClicked:Remove(self, self.OnClickAttatchAll)
end
function KaMailPanelMobile:OnClickDeleteReaded()
  if self.ReadedMail and table.count(self.ReadedMail) >= 1 then
    local pageData = {
      contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_KaPhone, "Text_DeleteReadMail"),
      confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_KaPhone, "ButtonText_Confirm"),
      returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_KaPhone, "ButtonText_Return"),
      source = self,
      cb = self.ConfirmDeleteReaded
    }
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.MsgDialogPage, false, pageData)
  else
    local TipText = ConfigMgr:FromStringTable(StringTablePath.ST_KaPhone, "DeleteReadMailTip")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipText)
  end
end
function KaMailPanelMobile:ConfirmDeleteReaded(bIsConfirm)
  Valid = bIsConfirm and GameFacade:RetrieveProxy(ProxyNames.KaMailProxy):ReqDeleteMail(self.ReadedMail)
end
function KaMailPanelMobile:OnClickAttatchAll()
  Valid = self.AttachMail and table.count(self.AttachMail) >= 1 and GameFacade:RetrieveProxy(ProxyNames.KaMailProxy):ReqTakeAttachMail(self.AttachMail, false)
end
return KaMailPanelMobile
