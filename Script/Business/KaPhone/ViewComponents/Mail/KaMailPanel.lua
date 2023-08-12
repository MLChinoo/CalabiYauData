local KaMailPanel = class("KaMailPanel", PureMVC.ViewComponentPanel)
local kaMailMediator = require("Business/KaPhone/Mediators/KaMailMediator")
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function KaMailPanel:GetIsActive()
  return self.IsActive
end
function KaMailPanel:SetIsActive(IsActive)
  self.IsActive = IsActive
end
function KaMailPanel:Update(MailData)
  self.ImageMap = {}
  self.AttachMail = {}
  self.ReadedMail = {}
  local bIsEmpty = true
  Valid = self.MailItemList and self.MailItemList:ClearListItems()
  for key, value in pairs(MailData or {}) do
    self:GenerateItem(value)
    bIsEmpty = false
  end
  if not bIsEmpty then
    Valid = self.WidgetSwitcher_Empty and self.WidgetSwitcher_Empty:SetActiveWidgetIndex(1)
  else
    Valid = self.WidgetSwitcher_Empty and self.WidgetSwitcher_Empty:SetActiveWidgetIndex(0)
    Valid = self.MailDetail and self.MailDetail:SetVisibility(Collapsed)
  end
  Valid = self.MailItemList and self.MailItemList:ScrollToTop()
end
function KaMailPanel:UpdateMailDetail(DetailData)
  Valid = self.MailDetail and self.MailDetail:Update(DetailData)
  Valid = self.WidgetSwitcher_Empty and self.WidgetSwitcher_Empty:SetActiveWidgetIndex(1)
  Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(1)
end
function KaMailPanel:RefreshSelfMailDetail()
  Valid = self.MailDetail and self.MailDetail:RefreshSelf()
end
function KaMailPanel:AddImageMap(key, value)
  self.ImageMap[key] = value
end
function KaMailPanel:GetImageMap()
  return self.ImageMap
end
function KaMailPanel:ClearCurMailDetail()
  Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(0)
end
function KaMailPanel:GenerateItem(Data)
  local obj = ObjectUtil:CreateLuaUObject(self)
  obj.data = Data
  obj.Parent = self
  Valid = self.MailItemList and self.MailItemList:AddItem(obj)
  Valid = Data.IsShowTip or table.insert(self.ReadedMail, Data.MailId)
  Valid = Data.HasAttach and table.insert(self.AttachMail, Data.MailId)
end
function KaMailPanel:ListNeededMediators()
  return {kaMailMediator}
end
function KaMailPanel:Construct()
  KaMailPanel.super.Construct(self)
  Valid = self.WidgetSwitcher and self.WidgetSwitcher:SetActiveWidgetIndex(0)
  self:BindEvent()
end
function KaMailPanel:Destruct()
  self:RemoveEvent()
  KaMailPanel.super.Destruct(self)
end
function KaMailPanel:BindEvent()
  Valid = self.Button_DeleteReaded and self.Button_DeleteReaded.OnClicked:Add(self, self.OnClickDeleteReaded)
  Valid = self.Button_AttachAll and self.Button_AttachAll.OnClicked:Add(self, self.OnClickAttachAll)
end
function KaMailPanel:RemoveEvent()
  Valid = self.Button_DeleteReaded and self.Button_DeleteReaded.OnClicked:Remove(self, self.OnClickDeleteReaded)
  Valid = self.Button_AttachAll and self.Button_AttachAll.OnClicked:Remove(self, self.OnClickAttachAll)
end
function KaMailPanel:OnClickDeleteReaded()
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
function KaMailPanel:ConfirmDeleteReaded(bIsConfirm)
  Valid = bIsConfirm and GameFacade:RetrieveProxy(ProxyNames.KaMailProxy):ReqDeleteMail(self.ReadedMail)
end
function KaMailPanel:OnClickAttachAll()
  if self.AttachMail and table.count(self.AttachMail) >= 1 then
    GameFacade:RetrieveProxy(ProxyNames.KaMailProxy):ReqTakeAttachMail(self.AttachMail, false)
  else
    local TipText = ConfigMgr:FromStringTable(StringTablePath.ST_KaPhone, "GetAllAttachTip")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, TipText)
  end
end
return KaMailPanel
