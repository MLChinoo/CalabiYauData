local NewGuidePageMediator = class("NewGuidePageMediator", PureMVC.Mediator)
local NewPlayerGuideEnum = require("Business/NewPlayerGuide/Proxies/NewPlayerGuideEnum")
function NewGuidePageMediator:OnRegister()
  self.ViewPage = self:GetViewComponent()
end
function NewGuidePageMediator:OnRemove()
  self.super:OnRemove()
end
function NewGuidePageMediator:ListNotificationInterests()
  return {
    NotificationDefines.ApartmentNewGuideShow,
    NotificationDefines.ApartmentNewGuideHideTarget,
    NotificationDefines.ApartmentNewGuideClose,
    NotificationDefines.ApartmentNewGuideClickPass,
    NotificationDefines.ShowPlayerGuideCurrentIndex,
    NotificationDefines.ApartmentNewGuideCloseWithDelay,
    NotificationDefines.GameServerReopen
  }
end
function NewGuidePageMediator:HandleNotification(notification)
  local NtfName = notification:GetName()
  local data = notification:GetBody()
  if NtfName == NotificationDefines.ApartmentNewGuideShow then
    self.ViewPage:SetClickPass(false)
    self.ViewPage:SetClickCallFunc(data.callfunc)
    self.ViewPage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ViewPage:SetHandleKeyFunc(data.handleKeyFunc)
    self.ViewPage:StartCheckCache(data)
  elseif NtfName == NotificationDefines.ApartmentNewGuideHideTarget then
    self.ViewPage:SetClickPass(false)
    self.ViewPage.TargetPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  elseif NtfName == NotificationDefines.ApartmentNewGuideClickPass then
    self.ViewPage:SetClickPass(true)
  elseif NtfName == NotificationDefines.ApartmentNewGuideClose then
    ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.NewGuidePage)
  elseif NtfName == NotificationDefines.ShowPlayerGuideCurrentIndex then
    self:OnShowPlayerGuide(data)
  elseif NtfName == NotificationDefines.GameServerReopen then
    self.ViewPage:ResetTeamFightGuide()
  end
end
function NewGuidePageMediator:InitPage()
end
function NewGuidePageMediator:OnShowPlayerGuide(step)
  if step == NewPlayerGuideEnum.GuideStep.Gift3DBox then
    self:Show3DGiftMask()
  end
end
function NewGuidePageMediator:Show3DGiftMask()
  local viewpage = self:GetViewComponent()
  local class = LoadClass("/Script/Engine.StaticMeshActor")
  local Arr = UE4.UGameplayStatics.GetAllActorsOfClass(viewpage, class)
  for i = 1, Arr:Length() do
    local item = Arr:Get(i)
    local objName = UE4.UKismetSystemLibrary.GetObjectName(item)
    if "Gift_Blur_Mask" == objName then
      local worldLocation = item.RootComponent:K2_GetComponentLocation()
      local PlayerController = UE4.UGameplayStatics.GetPlayerController(viewpage, 0)
      local ScreenPosition = UE4.FVector2D(0, 0)
      local bNormalShow = UE4.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(PlayerController, worldLocation, ScreenPosition, false)
      local size = UE4.FVector2D(400, 400)
      ScreenPosition.Y = ScreenPosition.Y - size.Y + 50
      ScreenPosition.X = ScreenPosition.X - size.X / 2
      self:GetViewComponent().FocusActor = item
      GameFacade:SendNotification(NotificationDefines.ApartmentNewGuideShow, {
        context = viewpage,
        position = ScreenPosition,
        size = size,
        callfunc = function()
          GameFacade:SendNotification(NotificationDefines.ApartmentNewGuideHideTarget)
          GameFacade:SendNotification(NotificationDefines.NewPlayerGuideGetGift)
          self:GetViewComponent().FocusActor = nil
        end
      })
    end
  end
end
return NewGuidePageMediator
