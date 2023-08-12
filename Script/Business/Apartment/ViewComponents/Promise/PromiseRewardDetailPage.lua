local PromiseRewardDetailPage = class("PromiseRewardDetailPage", PureMVC.ViewComponentPage)
local ApartmentPromiseRewardDetailMediator = require("Business/Apartment/Mediators/Promise/ApartmentPromiseRewardDetailMediator")
local Valid
function PromiseRewardDetailPage:ListNeededMediators()
  return {ApartmentPromiseRewardDetailMediator}
end
function PromiseRewardDetailPage:Init(RewardData)
  self.RewardItemArray = RewardData.RewardItemArray
  self.GridsPanel:Update(self.RewardItemArray)
end
function PromiseRewardDetailPage:UpdatePanel(ItemId)
  Valid = self.ItemDescWithHeadPanel and self.ItemDescWithHeadPanel:Update(ItemId)
  local data = {}
  data.itemId = ItemId
  data.imageBG = self.Img_BG
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys:SetItemDisplayed(data)
end
function PromiseRewardDetailPage:UpdateButton(InData)
end
function PromiseRewardDetailPage:LuaHandleKeyEvent(key, inputEvent)
  if self.ItemDisplayKeys then
    self.ItemDisplayKeys:LuaHandleKeyEvent(key, inputEvent)
  end
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    return true
  else
    return false
  end
end
function PromiseRewardDetailPage:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Add(self.ClosePage, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStartPreview:Add(self.OnClickStartPreview, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStopPreview:Add(self.OnClickStopPreview, self)
  self.IsPreview = true
  self:PlayOpenOrCloseAnimation(true)
  self:Init(luaOpenData)
end
function PromiseRewardDetailPage:OnClose()
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnReturn:Remove(self.ClosePage, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStartPreview:Remove(self.OnClickStartPreview, self)
  Valid = self.ItemDisplayKeys and self.ItemDisplayKeys.actionOnStopPreview:Remove(self.OnClickStopPreview, self)
  GameFacade:SendNotification(NotificationDefines.ApartmentMainPageVisibility, true)
end
function PromiseRewardDetailPage:ClosePage()
  ViewMgr:ClosePage(self)
end
function PromiseRewardDetailPage:OnClickStartPreview(is3DModel)
  self:PlayOpenOrCloseAnimation(false)
end
function PromiseRewardDetailPage:OnClickStopPreview(is3DModel)
  self:PlayOpenOrCloseAnimation(true)
end
function PromiseRewardDetailPage:PlayOpenOrCloseAnimation(Open)
  if self.SwitchAnimation == nil then
    return nil
  end
  if Open then
    if self.IsPreview == false then
      self.SwitchAnimation:PlayOpenAnimation()
      self.IsPreview = true
    end
  else
    if self.IsPreview then
      self.SwitchAnimation:PlayCloseAnimation()
    end
    self.IsPreview = false
  end
end
return PromiseRewardDetailPage
