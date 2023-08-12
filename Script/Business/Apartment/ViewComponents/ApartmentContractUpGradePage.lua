local ApartmentContractUpGradePage = class("ApartmentContractUpGradePage", PureMVC.ViewComponentPage)
local NewPlayerGuideEnum = require("Business/NewPlayerGuide/Proxies/NewPlayerGuideEnum")
function ApartmentContractUpGradePage:OnOpen(luaOpenData, nativeOpenData)
  self.TouchToClose = false
  local apartmentContractProxy = GameFacade:RetrieveProxy(ProxyNames.ApartmentContractProxy)
  luaOpenData = luaOpenData or apartmentContractProxy:GetContractUpgradeData()
  self.ContractInfo = luaOpenData
  self.ImgTouch.OnMouseButtonDownEvent:Bind(self, self.OnBgClicked)
  if self.ContractInfo then
    self.Text_Lv_grade:SetText(self.ContractInfo.roleIntimacyLv)
    self.Text_Tile_upgrade:SetText(self.ContractInfo.roleIntimacyNickName)
    self.Text_RoleName_grade:SetText(string.format("与%s的誓约", self.ContractInfo.roleNameCn))
  end
  if #luaOpenData.bodyNewUnlock > 0 then
    local newUnlockTouchPointMsg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Common, "UnlockBodyTouch")
    self.TxtUnlockTouchPoint:SetText(newUnlockTouchPointMsg)
    self.OverlayTouchPoint:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.OverlayTouchPoint:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if #luaOpenData.areaNewUnlock > 0 then
    local newUnlockMsg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Common, "UnlockRoomArea")
    local dot = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Common, "LabelDot")
    local totalCount = #luaOpenData.areaNewUnlock
    local count = 0
    for _, value in ipairs(luaOpenData.areaNewUnlock) do
      local msg = UE4.UKismetTextLibrary.TextFromStringTable(StringTablePath.ST_Common, string.format("ApartmentRoleActivityArea_%d", value))
      count = count + 1
      if totalCount > count then
        msg = msg .. dot
      end
      newUnlockMsg = newUnlockMsg .. msg
    end
    self.TxtUnlockArea:SetText(newUnlockMsg)
    self.OverlayArea:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.OverlayArea:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:PlayAnimation(self.Effect_Haoganshengji, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.TextTouchClose:SetVisibility(UE4.ESlateVisibility.Collapsed)
  TimerMgr:AddTimeTask(3, 0, 1, function()
    self.TouchToClose = true
    self.TextTouchClose:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end)
end
function ApartmentContractUpGradePage:OnClose()
end
function ApartmentContractUpGradePage:OnBgClicked()
  if not self.TouchToClose then
    return UE4.UWidgetBlueprintLibrary.Unhandled()
  end
  ViewMgr:ClosePage(LuaGetWorld(), UIPageNameDefine.ApartmentContractUpGradePage)
  GameFacade:SendNotification(NotificationDefines.ApartmentContract, nil, NotificationDefines.ApartmentContract.ContractUpGradePageClosed)
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  if not NewPlayerGuideProxy:IsAllGuideComplete() then
    NewPlayerGuideProxy:SetCurComplete()
  end
  return UE4.UWidgetBlueprintLibrary.Unhandled()
end
function ApartmentContractUpGradePage:UpdateRoleContractInfo(contractInfo)
  self.Text_Lv:SetText(contractInfo.roleIntimacyLv)
  self.Text_Tile:SetText(contractInfo.roleTile)
  self.Text_RoleName:SetText(contractInfo.roleNameCn)
end
function ApartmentContractUpGradePage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnBgClicked()
    return true
  end
  return false
end
return ApartmentContractUpGradePage
