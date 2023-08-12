local NewGuidePage = class("NewGuidePage", PureMVC.ViewComponentPage)
local NewGuidePageMediator = require("Business/NewPlayerGuide/Mediators/NewGuidePageMediator")
local NewPlayerGuideEnum = require("Business/NewPlayerGuide/Proxies/NewPlayerGuideEnum")
function NewGuidePage:ListNeededMediators()
  return {NewGuidePageMediator}
end
function NewGuidePage:Construct()
  NewGuidePage.super.Construct(self)
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, true, true)
end
function NewGuidePage:InitializeLuaEvent()
  if self.Button_Play then
    self.Button_Play.OnClicked:Add(self, NewGuidePage.OnPlayClick)
  end
  if self.Button_Close then
    self.Button_Close.OnClicked:Add(self, NewGuidePage.OnCloseClick)
  end
  if self.SkipBtn then
    self.SkipBtn.OnClicked:Add(self, NewGuidePage.OnSkipClick)
  end
  self.LeftMaskSlot = self.LeftMask.Slot
  self.RightMaskSlot = self.RightMask.Slot
  self.TopMaskSlot = self.TopMask.Slot
  self.BottomMaskSlot = self.BottomMask.Slot
  self.LeftMask:SetColorAndOpacity(self.ShadowColor)
  self.RightMask:SetColorAndOpacity(self.ShadowColor)
  self.TopMask:SetColorAndOpacity(self.ShadowColor)
  self.BottomMask:SetColorAndOpacity(self.ShadowColor)
  self.ShadowSlot = self.Shadow.Slot
  local marginT = UE4.FMargin()
  local dpx = 10
  marginT.Bottom = -dpx
  marginT.Top = -dpx
  marginT.Left = -dpx
  marginT.Right = -dpx
  self.ShadowSlot:SetOffsets(marginT)
  self.dpx = dpx
end
function NewGuidePage:Destruct()
  NewGuidePage.super.Destruct(self)
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, false)
end
function NewGuidePage:OnOpen(luaOpenData)
  self.GuideInfo = luaOpenData or {}
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  NewPlayerGuideProxy:SetGuideUIExistFlag(true)
  self.TargetPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetBorderMaskVisible(false)
  self.GuideTriggerProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideTriggerProxy)
  if self.GuideInfo.GuideName == "TeamFightGuide" then
    self.GuideTriggerProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerTeamFightGuideTriggerProxy)
    if self.SkipBtn then
      self.SkipBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  self.GuideTriggerProxy:Start()
end
function NewGuidePage:ShowMask()
  local size, position = self.TargetPanel.Slot:GetSize(), self.TargetPanel.Slot:GetPosition()
  local marginL = UE4.FMargin()
  local marginT = UE4.FMargin()
  local marginR = UE4.FMargin()
  local marginB = UE4.FMargin()
  local CachedGeometry = self.ShowPanel:GetCachedGeometry()
  local itemSize = UE4.USlateBlueprintLibrary.GetLocalSize(CachedGeometry)
  local r = itemSize.X - position.X + self.dpx
  local l = position.X + size.X + self.dpx
  local t = position.Y + size.Y + self.dpx
  local b = itemSize.Y - position.Y + self.dpx
  marginL.Right = r
  marginL.Top = t
  marginL.Bottom = b
  marginR.Left = l
  marginR.Top = t
  marginR.Bottom = b
  marginB.Top = t
  marginT.Bottom = b
  self.LeftMaskSlot:SetOffsets(marginL)
  self.RightMaskSlot:SetOffsets(marginR)
  self.BottomMaskSlot:SetOffsets(marginB)
  self.TopMaskSlot:SetOffsets(marginT)
end
function NewGuidePage:OnPlayClick()
end
function NewGuidePage:DestoryPopTimer()
  if self.animOpenPageTask then
    self.animOpenPageTask:EndTask()
    self.animOpenPageTask = nil
  end
end
function NewGuidePage:OnCloseClick()
  ViewMgr:ClosePage(self, UIPageNameDefine.NewGuidePage)
end
function NewGuidePage:OnSkipClick()
  local pageData = {}
  pageData.contentTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Context_SkipApartmentTeach")
  pageData.confirmTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Confirm_Default")
  pageData.returnTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "Cancel")
  function pageData.cb(bConfirm)
    if bConfirm then
      local NewPlayerGuideTriggerProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideTriggerProxy)
      NewPlayerGuideTriggerProxy:ShowRevertFunc(NewPlayerGuideEnum.GuideStep.Gift)
      UE4.UPMApartmentSubsystem.Get(LuaGetWorld()):ClearCharacterAllAttachActor()
      ViewMgr:ClosePage(self, UIPageNameDefine.RewardDisplayPage)
      GameFacade:SendNotification(NotificationDefines.GivePageClose)
      ViewMgr:ClosePage(self, UIPageNameDefine.NewGuidePage)
    end
  end
  ViewMgr:OpenPage(self, UIPageNameDefine.MsgDialogPage, false, pageData)
end
function NewGuidePage:ResetTeamFightGuide()
  if self.GuideInfo.GuideName == "TeamFightGuide" then
    local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
    NewPlayerGuideProxy.ResetTeamFightGuideFlag = true
    self:OnCloseClick()
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
    NewPlayerGuideProxy:ResetTeamFightGuide()
    return
  end
end
function NewGuidePage:OnClose()
  local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
  NewPlayerGuideProxy:SetGuideUIExistFlag(false)
  if not NewPlayerGuideProxy.ResetTeamFightGuideFlag then
    NewPlayerGuideProxy:SetCurComplete()
  end
  self.GuideTriggerProxy:DestoryTimeoutTimer()
  self:DestoryFloatTimer()
  self:DestoryAnimOpenTimer()
  self:DestoryCheckCacheTimer()
end
function NewGuidePage:ClearAfterClickItem()
  self.clickCallFunc = nil
  self.focusWidget = nil
  self.focusActor = nil
  self.TargetPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetBorderMaskVisible(false)
  self.handlekeyCallFunc = nil
end
function NewGuidePage:OnMouseButtonDown(myGeometry, mouseEvent)
  if self.ShowAniming then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  if self.TargetPanel:GetVisibility() == UE4.ESlateVisibility.Collapsed then
    return UE4.UWidgetBlueprintLibrary.Handled()
  end
  local screenSpacePosition = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(mouseEvent)
  local cachedGeometry = self.Image_143:GetCachedGeometry()
  local bClicked = UE4.USlateBlueprintLibrary.IsUnderLocation(cachedGeometry, screenSpacePosition)
  if bClicked then
    self:DestoryFloatTimer()
    self:DestoryAnimOpenTimer()
    self:SetBorderMaskVisible(false)
    if self.clickCallFunc and type(self.clickCallFunc) == "function" then
      local callfunc = self.clickCallFunc
      local delayTime = callfunc() or 5
      GameFacade:SendNotification(NotificationDefines.ApartmentNewGuideCloseWithDelay, delayTime)
      self:ClearAfterClickItem()
      self:K2_PostAkEvent(self.ClickAudio)
    end
  end
  return UE4.UWidgetBlueprintLibrary.Handled()
end
function NewGuidePage:SetShowPanlePositionAndSize(position, size, extras)
  if extras and extras.sizeoffsets then
    size.X = extras.sizeoffsets.X + size.X
    size.Y = extras.sizeoffsets.Y + size.Y
    position.X = position.X - extras.sizeoffsets.X / 2
    position.Y = position.Y - extras.sizeoffsets.Y / 2
  end
  if position then
    self.TargetPanel.Slot:SetPosition(position)
  end
  if size then
    self.TargetPanel.Slot:SetSize(size)
  end
end
function NewGuidePage:SetClickCallFunc(callfunc)
  if callfunc then
    self.clickCallFunc = callfunc
  end
end
function NewGuidePage:SetHandleKeyFunc(keyCallFunc)
  if keyCallFunc then
    self.handlekeyCallFunc = keyCallFunc
  end
end
function NewGuidePage:ShowAnim(widget)
  self.Mask:SetVisibility(UE4.ESlateVisibility.Visible)
  self.TargetPanel:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
  self:ShowMask()
  self:SetBorderMaskVisible(true)
  self.ShowAniming = true
  self:ShowFloatTimer()
end
function NewGuidePage:SetClickPass(bPass)
  local Vis = UE4.ESlateVisibility.Visible
  if bPass then
    Vis = UE4.ESlateVisibility.HitTestInvisible
  end
  self.Mask:SetVisibility(Vis)
end
function NewGuidePage:SetBorderMaskVisible(bVis)
  local Vis = UE4.ESlateVisibility.Hidden
  if bVis then
    Vis = UE4.ESlateVisibility.Visible
  end
  self.LeftMask:SetVisibility(Vis)
  self.RightMask:SetVisibility(Vis)
  self.TopMask:SetVisibility(Vis)
  self.BottomMask:SetVisibility(Vis)
end
function NewGuidePage:SetNodeOffset(slot, offset)
  local margin = UE4.FMargin()
  margin.Right = offset
  margin.Left = offset
  margin.Top = offset
  margin.Bottom = offset
  slot:SetOffsets(margin)
end
function NewGuidePage:ShowAnimTimer()
  self:DestoryAnimOpenTimer()
  if self.animOpenPageTask == nil then
    local intervalTime = 0.01
    local scale = 2
    local Image_143_TotalRenderOpacityTime = 0.4 / scale
    local Target_1_TotalShowRenderOpacityTime = 0.55 / scale
    local Target_1_TotalHideRenderOpacityTime = 0.15 / scale
    local showTotalTime = 0.7 / scale
    local totalTime = 0
    local getOpa = function(opa)
      return math.clamp(opa, 0, 1)
    end
    self.Target:SetRenderOpacity(0)
    self.Image_143:SetRenderOpacity(0)
    self.Target_1:SetRenderOpacity(0)
    local Image_143_Offset = 600
    local Target_1_Offset = 500
    self.animOpenPageTask = TimerMgr:AddTimeTask(0, intervalTime, 0, function()
      totalTime = totalTime + intervalTime
      local opa = getOpa(totalTime / Image_143_TotalRenderOpacityTime)
      self.Image_143:SetRenderOpacity(opa)
      local offset = (1 - getOpa(totalTime / Image_143_TotalRenderOpacityTime)) * -Image_143_Offset
      self:SetNodeOffset(self.Image_143.Slot, offset)
      offset = (1 - getOpa(totalTime / Target_1_TotalShowRenderOpacityTime)) * -Target_1_Offset
      self:SetNodeOffset(self.Target_1.Slot, offset)
      if totalTime > Target_1_TotalShowRenderOpacityTime then
        opa = getOpa(totalTime / Target_1_TotalShowRenderOpacityTime)
      else
        opa = 1 - getOpa(totalTime - Target_1_TotalHideRenderOpacityTime / Target_1_TotalShowRenderOpacityTime)
      end
      self.Target_1:SetRenderOpacity(opa)
      if totalTime > showTotalTime then
        self:DestoryAnimOpenTimer()
        self:ShowFloatTimer()
      end
    end)
  end
end
function NewGuidePage:ShowFloatTimer()
  self:DestoryFloatTimer()
  self.ShowAniming = false
  if self.animFloatPageTask == nil then
    local intervalTime = 0.01
    local scale = 1.2
    local TargetRenderOpaList = {
      {
        time = 0.35 / scale,
        value = 0
      },
      {
        time = 0.45 / scale,
        value = 1
      },
      {
        time = 1 / scale,
        value = 0
      }
    }
    local TargetRenderOffsetList = {
      {
        time = 0.45 / scale,
        value = -5
      },
      {
        time = 1 / scale,
        value = -50
      }
    }
    local Target_1RenderOpaList = {
      {
        time = 0 / scale,
        value = 1
      },
      {
        time = 0.75 / scale,
        value = 0
      }
    }
    local Target_1RenderOffsetList = {
      {
        time = 0 / scale,
        value = -5
      },
      {
        time = 0.75 / scale,
        value = -20
      }
    }
    local showTotalTime = 1.4 / scale
    local totalTime = 0
    local getOpa = function(opa)
      return math.clamp(opa, 0, 1)
    end
    local GetLerpValue = function(list, totalTime)
      for i = 1, #list - 1 do
        if totalTime <= list[1].time then
          return list[1].value
        end
        if totalTime >= list[#list].time then
          return list[#list].value
        end
        if totalTime >= list[i].time and totalTime <= list[i + 1].time then
          local lastValue = list[i].value
          local targetValue = list[i + 1].value
          local value = targetValue - lastValue
          local percent = (totalTime - list[i].time) / (list[i + 1].time - list[i].time)
          local ans = lastValue + percent * (targetValue - lastValue)
          return ans
        end
      end
    end
    self.animFloatPageTask = TimerMgr:AddTimeTask(0, intervalTime, 0, function()
      totalTime = totalTime + intervalTime
      local opa = GetLerpValue(TargetRenderOpaList, totalTime)
      if opa then
        self.Target:SetRenderOpacity(opa)
      end
      opa = GetLerpValue(Target_1RenderOpaList, totalTime)
      if opa then
        self.Target_1:SetRenderOpacity(opa)
      end
      local offset = GetLerpValue(TargetRenderOffsetList, totalTime)
      if offset then
        self:SetNodeOffset(self.Target.Slot, offset)
      end
      offset = GetLerpValue(Target_1RenderOffsetList, totalTime)
      if offset then
        self:SetNodeOffset(self.Target_1.Slot, offset)
      end
      if totalTime > showTotalTime then
        totalTime = 0
      end
    end)
  end
end
function NewGuidePage:DestoryFloatTimer()
  if self.animFloatPageTask then
    self.animFloatPageTask:EndTask()
    self.animFloatPageTask = nil
  end
end
function NewGuidePage:DestoryAnimOpenTimer()
  if self.animOpenPageTask then
    self.animOpenPageTask:EndTask()
    self.animOpenPageTask = nil
  end
end
function NewGuidePage:StartCheckCache(data)
  self:DestoryCheckCacheTimer()
  self.TargetPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:SetBorderMaskVisible(false)
  if data.widget then
    local intervalTime = 0.1
    local scale = 3
    local widget = data.widget
    local curPosition = data.position
    local maxTimes = 100
    local cnt = 0
    self.focusWidget = data.widget
    self.extras = data.extras
    self.checkCacheTask = TimerMgr:AddTimeTask(0.1, intervalTime, 0, function()
      cnt = cnt + 1
      if cnt > maxTimes then
        self:DestoryCheckCacheTimer()
        self:OnCloseClick()
        return
      end
      local position = UE4.FVector2D()
      local geometry = widget:GetCachedGeometry()
      UE4.USlateBlueprintLibrary.LocalToViewport(self, geometry, UE4.FVector2D(0, 0), UE4.FVector2D(), position)
      if position.X == curPosition.X and position.Y == curPosition.Y then
        self:DestoryCheckCacheTimer()
        local size = UE4.USlateBlueprintLibrary.GetLocalSize(geometry)
        self:SetShowPanlePositionAndSize(position, size, data.extras)
        self:ShowAnim()
      else
        curPosition = position
      end
    end)
  else
    self.focusActor = data.extras.focusActor
    self:SetShowPanlePositionAndSize(data.position, data.size, data.extras)
    self:ShowAnim()
  end
end
function NewGuidePage:DestoryCheckCacheTimer()
  if self.checkCacheTask then
    self.checkCacheTask:EndTask()
    self.checkCacheTask = nil
  end
end
function NewGuidePage:OnLuaViewportResized()
  if self.focusWidget then
    local position = UE4.FVector2D()
    local geometry = self.focusWidget:GetCachedGeometry()
    UE4.USlateBlueprintLibrary.LocalToViewport(self, geometry, UE4.FVector2D(0, 0), UE4.FVector2D(), position)
    local size = UE4.USlateBlueprintLibrary.GetLocalSize(geometry)
    self:SetShowPanlePositionAndSize(position, size, self.extras)
  else
    local NewPlayerGuideProxy = GameFacade:RetrieveProxy(ProxyNames.NewPlayerGuideProxy)
    if NewPlayerGuideProxy:IsShowGuideUI(NewPlayerGuideEnum.GuideStep.Gift3DBox) and self.focusActor then
      local item = self.focusActor
      local worldLocation = item.RootComponent:K2_GetComponentLocation()
      local PlayerController = UE4.UGameplayStatics.GetPlayerController(self, 0)
      local ScreenPosition = UE4.FVector2D(0, 0)
      local bNormalShow = UE4.UWidgetLayoutLibrary.ProjectWorldLocationToWidgetPosition(PlayerController, worldLocation, ScreenPosition, false)
      local size = UE4.FVector2D(400, 400)
      ScreenPosition.Y = ScreenPosition.Y - size.Y + 50
      ScreenPosition.X = ScreenPosition.X - size.X / 2
      self:SetShowPanlePositionAndSize(ScreenPosition, size)
    end
  end
end
function NewGuidePage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if self.handlekeyCallFunc and self.handlekeyCallFunc(key, inputEvent) then
    self:ClearAfterClickItem()
    return true
  end
  if "Escape" == keyName and self.GuideInfo.GuideName ~= "TeamFightGuide" then
    self:OnSkipClick()
    return true
  end
  return false
end
return NewGuidePage
