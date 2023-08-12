local FBBindWaitPageMediator = require("Business/AccountBind/Mediators/FBBindWaitPageMediator")
local FBBindWaitPage = class("FBBindWaitPage", PureMVC.ViewComponentPage)
local AccountBindProxy
function FBBindWaitPage:ListNeededMediators()
  return {FBBindWaitPageMediator}
end
function FBBindWaitPage:InitializeLuaEvent()
end
function FBBindWaitPage:OnOpen(luaOpenData, nativeOpenData)
  AccountBindProxy = GameFacade:RetrieveProxy(ProxyNames.AccountBindProxy)
  self.CloseBtn.OnClicked:Add(self, self.OnClickCloseBtn)
  self:UpdataReward()
  local AccountBindWorldSubsystem = UE4.UPMAccountBindWorldSubsystem.Get(LuaGetWorld())
  if AccountBindWorldSubsystem then
    self.OnAccountBindCallbackHandler = DelegateMgr:AddDelegate(AccountBindWorldSubsystem.OnAccountBindCallback, self, "OnAccountBindCallback")
  end
  if AccountBindProxy then
    local FBid = AccountBindProxy:GetFBid()
    if nil == FBid or "" == FBid then
      self.FBIdRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.FBIdRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      self.FBIdText:SetText(FBid)
    end
  end
end
function FBBindWaitPage:OnAccountBindCallback(Status, Code)
  print("OnAccountBindCallback", "Status = " .. Status .. "  Code = " .. Code)
  if "200" == Status then
    if AccountBindProxy then
      AccountBindProxy:ReqBindAccountFanbook(0, FunctionUtil:urlDecode(Code), "")
    end
  else
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, "Fanbook授权失败")
  end
end
function FBBindWaitPage:OnClose()
  self.CloseBtn.OnClicked:Remove(self, self.OnClickCloseBtn)
  local AccountBindWorldSubsystem = UE4.UPMAccountBindWorldSubsystem.Get(LuaGetWorld())
  if AccountBindWorldSubsystem and self.OnAccountBindCallbackHandler then
    DelegateMgr:RemoveDelegate(AccountBindWorldSubsystem.OnAccountBindCallback, self.OnAccountBindCallbackHandler)
    self.OnAccountBindCallbackHandler = nil
  end
end
function FBBindWaitPage:OnClickCloseBtn()
  ViewMgr:ClosePage(self)
end
function FBBindWaitPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName then
    if inputEvent == UE4.EInputEvent.IE_Released then
      self:OnClickCloseBtn()
    end
    return true
  else
    return false
  end
end
function FBBindWaitPage:UpdataReward()
  if AccountBindProxy then
    if AccountBindProxy:GetFBBingHasReward() then
      local itemID, itemCount = AccountBindProxy:GetFBBindReward()
      if nil == itemID then
        return
      end
      local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
      if ItemsProxy then
        local ItemInfo = ItemsProxy:GetAnyItemInfoById(itemID)
        local itemQualityCfg = ItemsProxy:GetItemQualityConfig(ItemInfo.quality)
        if self.Image_Qullaty then
          self.Image_Qullaty:SetColorAndOpacity(UE4.UKismetMathLibrary.Conv_ColorToLinearColor(UE4.FColor.LuaFromHex(itemQualityCfg.Color)))
        end
        if self.RewadImage then
          self:SetImageByTexture2D(self.RewadImage, ItemInfo.image)
        end
        if self.NumText then
          self.NumText:SetText(tostring(itemCount))
        end
      end
      self.RewadRoot:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      self.RewadRoot:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
end
return FBBindWaitPage
