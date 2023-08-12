local ItemDisplayKeysPanel = class("ItemDisplayKeysPanel", PureMVC.ViewComponentPanel)
function ItemDisplayKeysPanel:ListNeededMediators()
  return {}
end
function ItemDisplayKeysPanel:InitializeLuaEvent()
  self.actionOnReturn = LuaEvent.new()
  self.actionOnStartPreview = LuaEvent.new(is3DModel)
  self.actionOnStopPreview = LuaEvent.new(is3DModel)
  self.actionOnStartDrag = LuaEvent.new()
  self.actionOnStopDrag = LuaEvent.new()
  self.actionOnStartScreenShot = LuaEvent.new()
  self.actionOnStopScreenShot = LuaEvent.new()
  self.actionOnSwitchShow = LuaEvent.new()
end
function ItemDisplayKeysPanel:Construct()
  self.Overridden.Construct(self)
  self.is3DModel = false
  if self.UI3DModel then
    local contrlImg = self.UI3DModel.ControlImage
    if contrlImg then
      contrlImg.OnStartDrag:Add(self, self.StartDrag)
      contrlImg.OnReleased:Add(self, self.StopDrag)
    end
    self.UI3DModel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if self.UI2DModel then
    self.UI2DModel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:InitKeysVisibility()
  self:BindSpawnCharacterDelegate()
end
function ItemDisplayKeysPanel:Destruct()
  self:StopPreview(self.is3DModel)
  self:UnSpawnCharacterDelegate()
  if self.OnCaptureScreenshotSuccessHandler then
    DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self.OnCaptureScreenshotSuccessHandler)
    self.OnCaptureScreenshotSuccessHandler = nil
  end
  self:RestEmote()
  self:StopRoleVoice()
  self:ExitWeaponAttackEffectPreview()
  self.Overridden.Destruct(self)
end
function ItemDisplayKeysPanel:InitKeysVisibility()
  if self.bShowEsc ~= nil then
    self:ShowEsc(self.bShowEsc)
  end
  if nil ~= self.bShowPreview then
    self:ShowPreview(self.bShowPreview)
  end
  if nil ~= self.bShowSwitch then
    self:ShowSwitch(self.bShowSwitch)
  end
  if self.duringSwitch then
    self:ShowSwitch(true)
  end
  if nil ~= self.bShowRoll then
    self:ShowRoll(self.bShowRoll)
  end
  if nil ~= self.bShowFOV then
    self:ShowFOV(self.bShowFOV)
  end
  if nil ~= self.bShowMove then
    self:ShowMove(self.bShowMove)
  end
  if nil ~= self.bShowScreenShot then
    self:ShowScreenShot(self.bShowScreenShot)
  end
end
function ItemDisplayKeysPanel:ShowEsc(shouldShow)
  if self.SizeBox_Esc then
    self.SizeBox_Esc:SetVisibility(shouldShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.Button_Esc then
    if shouldShow then
      self.bindEsc = true
      self.Button_Esc.OnClickEvent:Add(self, self.OnClickEsc)
    elseif self.bindEsc then
      self.bindEsc = false
      self.Button_Esc.OnClickEvent:Remove(self, self.OnClickEsc)
    end
  end
end
function ItemDisplayKeysPanel:OnClickEsc()
  if self.isPreviewing then
    self:StopPreview()
  else
    self.actionOnReturn()
  end
end
function ItemDisplayKeysPanel:ShowPreview(shouldShow)
  if self.SizeBox_Preview then
    self.SizeBox_Preview:SetVisibility(shouldShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.Button_T then
    if shouldShow then
      if not self.bindPreview then
        self.bindPreview = true
        self.Button_T.OnClickEvent:Add(self, self.OnClickPreview)
      end
    elseif self.bindPreview then
      self.bindPreview = false
      self.Button_T.OnClickEvent:Remove(self, self.OnClickPreview)
    end
  end
  self.isPreviewing = false
end
function ItemDisplayKeysPanel:OnClickPreview()
  if self.isPreviewing then
    self:StopPreview()
  else
    self:StartPreview()
  end
end
function ItemDisplayKeysPanel:StartPreview()
  local camera = self:GetLobbyCamera()
  if camera then
    if self.bIsMoveCamera then
      camera:EnterPreviewMode()
    else
      camera:SetPreviewMode(true)
    end
  end
  if self.imageBG then
    self.imageBG:SetVisibility(self.is3DModel and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if self.Button_Esc and not self.bindEsc then
    self.bindEsc = true
    self.Button_Esc.OnClickEvent:Add(self, self.OnClickEsc)
  end
  if self.itemType == UE4.EItemIdIntervalType.RoleSkin then
    self:ShowMove(true)
  end
  self.actionOnStartPreview(self.is3DModel)
  self.isPreviewing = true
end
function ItemDisplayKeysPanel:StopPreview(isVideo)
  local camera = self:GetLobbyCamera()
  if camera then
    if self.bIsMoveCamera then
      camera:QuitPreviewMode()
    else
      camera:SetPreviewMode(false)
    end
  end
  if self.MediaPlayer and not isVideo then
    self.MediaPlayer:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.MediaPlayer:CloseVideo()
  end
  self:InitKeysVisibility()
  self.actionOnStopPreview(self.is3DModel)
  self.isPreviewing = false
end
function ItemDisplayKeysPanel:ShowSwitch(shouldShow)
  if self.SizeBox_Switch then
    self.SizeBox_Switch:SetVisibility(shouldShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.Button_Switch then
    if shouldShow then
      if not self.bindSwitch then
        self.bindSwitch = true
        self.Button_Switch.OnClickEvent:Add(self, self.OnClickSwitch)
      end
    elseif self.bindSwitch then
      self.bindSwitch = false
      self.Button_Switch.OnClickEvent:Remove(self, self.OnClickSwitch)
    end
  end
end
function ItemDisplayKeysPanel:OnClickSwitch()
  if self.bUseCustomSwitch then
    self.actionOnSwitchShow()
    return
  end
  if self.duringSwitch then
    self:StopSwitch()
  else
    self:StartSwitch()
  end
end
function ItemDisplayKeysPanel:StartSwitch()
  local roleCfg = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleCfgByWeaponId(self.itemId)
  if nil == roleCfg then
    return
  end
  local roleId = roleCfg.RoleId
  local roleSkinId = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleCurrentWearAdvancedSkinID(roleId)
  if nil == roleSkinId then
    return
  end
  self.cachedItemId = self.itemId
  self:StopPreview(true)
  local data = {}
  data.itemId = roleSkinId
  data.stateMachineType = UE4.ELobbyCharacterAnimationStateMachineType.HoldWeapon
  self:SetItemDisplayed(data)
  if self.Display3DModelResult then
    local character = self.Display3DModelResult:RetrieveLobbyCharacter(0)
    if nil == character then
      return
    end
    character:EquipWeapon(self.cachedItemId)
  end
  self:ShowSwitch(true)
  self.duringSwitch = true
end
function ItemDisplayKeysPanel:StopSwitch()
  if self.cachedItemId == nil then
    return
  end
  self:StopPreview(true)
  self.duringSwitch = false
  self:SetItemDisplayed({
    itemId = self.cachedItemId
  })
  self.cachedItemId = nil
end
function ItemDisplayKeysPanel:ShowRoll(shouldShow)
  if self.SizeBox_Roll then
    self.SizeBox_Roll:SetVisibility(shouldShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ItemDisplayKeysPanel:ShowFOV(shouldShow)
  if self.SizeBox_FOV then
    self.SizeBox_FOV:SetVisibility(shouldShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ItemDisplayKeysPanel:ShowMove(shouldShow)
  if self.SizeBox_Move then
    self.SizeBox_Move:SetVisibility(shouldShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
end
function ItemDisplayKeysPanel:ShowScreenShot(shouldShow)
  if self.SizeBox_ScreenShot then
    self.SizeBox_ScreenShot:SetVisibility(shouldShow and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
  end
  if self.Button_ScreenShot then
    if shouldShow then
      if not self.bShowScreenShot then
        self.bShowScreenShot = true
        self.Button_ScreenShot.OnClickEvent:Add(self, self.OnClickScreenShot)
        self.OnCaptureScreenshotSuccessHandler = DelegateMgr:AddDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self, "OnStopScreenShot")
      end
    elseif self.bShowScreenShot then
      self.bShowScreenShot = false
      self.Button_ScreenShot.OnClickEvent:Remove(self, self.OnClickScreenShot)
      if self.OnCaptureScreenshotSuccessHandler then
        DelegateMgr:RemoveDelegate(UE4.UPMShareSubSystem.GetInst(self).OnCaptureScreenshotSuccess, self.OnCaptureScreenshotSuccessHandler)
        self.OnCaptureScreenshotSuccessHandler = nil
      end
    end
  end
end
function ItemDisplayKeysPanel:OnClickScreenShot()
  self.actionOnStartScreenShot()
end
function ItemDisplayKeysPanel:OnStopScreenShot()
  self.actionOnStopScreenShot()
end
function ItemDisplayKeysPanel:SetItemDisplayed(dataProp)
  if nil == dataProp or nil == dataProp.itemId or self.itemId == dataProp.itemId then
    return
  end
  self:RestEmote()
  self:StopRoleVoice()
  self:ExitWeaponAttackEffectPreview()
  self.itemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(dataProp.itemId)
  if self.itemType == UE4.EItemIdIntervalType.Weapon and self.duringSwitch and self.cachedItemId then
    if self:CanChangeWeaponSkinOnly(dataProp.itemId) then
      return
    end
    self.duringSwitch = false
    self.cachedItemId = nil
  end
  if self.duringSwitch and self.cachedItemId and self.cachedItemId ~= dataProp.itemId then
    self.duringSwitch = false
    self.cachedItemId = nil
  end
  self.itemId = dataProp.itemId
  self.imageBG = dataProp.imageBG
  if self.itemType == UE4.EItemIdIntervalType.RoleSkin then
    self.bShowPreview = true
    self.bShowSwitch = false
    self.bShowRoll = true
    self.bShowFOV = true
    self.bShowMove = false
    self.is3DModel = true
  elseif self.itemType == UE4.EItemIdIntervalType.Weapon then
    self.bShowPreview = true
    self.bShowSwitch = true
    self.bShowRoll = true
    self.bShowFOV = true
    self.bShowMove = false
    self.is3DModel = true
    local slotType = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy):GetWeaponSlotTypeByWeaponId(self.itemId)
    if slotType == UE4.EWeaponSlotTypes.WeaponSlot_Secondary or slotType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 or slotType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
      self.bShowSwitch = false
    end
  elseif self.itemType == UE4.EItemIdIntervalType.Decal then
    self.bShowPreview = false
    self.bShowSwitch = false
    self.bShowRoll = true
    self.bShowFOV = false
    self.bShowMove = false
    self.is3DModel = true
  elseif self.itemType == UE4.EItemIdIntervalType.FlyEffect then
    self.bShowPreview = true
    self.bShowSwitch = false
    self.bShowRoll = false
    self.bShowFOV = false
    self.bShowMove = false
    self.is3DModel = true
  elseif self.itemType == UE4.EItemIdIntervalType.RoleEmote then
    self.bShowPreview = false
    self.bShowSwitch = false
    self.bShowRoll = false
    self.bShowFOV = false
    self.bShowMove = false
    self.is3DModel = true
  elseif self.itemType == UE4.EItemIdIntervalType.RoleAction then
    self.bShowPreview = false
    self.bShowSwitch = false
    self.bShowRoll = false
    self.bShowFOV = false
    self.bShowMove = false
    self.is3DModel = true
  elseif self.itemType == UE4.EItemIdIntervalType.RoleVoice then
    self.bShowPreview = false
    self.bShowSwitch = false
    self.bShowRoll = false
    self.bShowFOV = false
    self.bShowMove = false
    self.is3DModel = false
    self:PlayRoleVoice()
  elseif self.itemType == UE4.EItemIdIntervalType.WeaponUpgradeFx then
    self.bShowPreview = false
    self.bShowSwitch = false
    self.bShowRoll = false
    self.bShowFOV = false
    self.bShowMove = false
    self.is3DModel = true
  else
    self.bShowPreview = false
    self.bShowSwitch = false
    self.bShowRoll = false
    self.bShowFOV = false
    self.bShowMove = false
    self.is3DModel = false
  end
  if self.imageBG then
    self.imageBG:SetVisibility(self.is3DModel and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:InitKeysVisibility()
  if self.UI3DModel and self.UI2DModel then
    if self.is3DModel then
      if self.itemType == UE4.EItemIdIntervalType.RoleEmote then
        if not dataProp.bNotChangeRole then
          if nil == self.EmoteDefaultCharacter then
            LogError("ItemDisplayKeysPanel", "找@秦嵩配置表情默认显示的角色皮肤!")
          else
            self.Display3DModelResult = self.UI3DModel:DisplayByItemId(self.EmoteDefaultCharacter, UE4.ELobbyCharacterAnimationStateMachineType.NotHoldWeaponNoLeisure)
          end
        end
        self:ShowCharacterEmote(self.itemId)
      elseif self.itemType == UE4.EItemIdIntervalType.RoleAction then
        if not dataProp.bNotChangeRole then
          self:SpawnActionCharacter(self.itemId)
        else
          self:PlayRoleAction(self.itemId)
        end
      elseif self.itemType == UE4.EItemIdIntervalType.WeaponUpgradeFx then
        self:ShowWeaponAttackEffectPreview(dataProp.weaponID)
      else
        if dataProp.stateMachineType then
          self.Display3DModelResult = self.UI3DModel:DisplayByItemId(self.itemId, dataProp.stateMachineType)
        else
          self.Display3DModelResult = self.UI3DModel:DisplayByItemId(self.itemId, UE4.ELobbyCharacterAnimationStateMachineType.NotHoldWeapon)
        end
        if self.itemType == UE4.EItemIdIntervalType.RoleSkin and self.ChangeRoleEffect and self.RoleEffectTransform then
          UE4.UGameplayStatics.SpawnEmitterAtLocation(self, self.ChangeRoleEffect, self.RoleEffectTransform.Translation, UE4.UKismetMathLibrary.Quat_Rotator(self.RoleEffectTransform.Rotation), self.RoleEffectTransform.Scale3D, true, UE4.EPSCPoolMethod.None, true)
        end
        if self.itemType == UE4.EItemIdIntervalType.Weapon and self.ChangeWeaponEffect and self.WeaponEffectTransform then
          self.WeaponEffectTransform.Translation = UE4.UPMLuaBridgeBlueprintLibrary.GetEquipRoomWeaponPosition(self)
          UE4.UGameplayStatics.SpawnEmitterAtLocation(self, self.ChangeWeaponEffect, self.WeaponEffectTransform.Translation, UE4.UKismetMathLibrary.Quat_Rotator(self.WeaponEffectTransform.Rotation), self.WeaponEffectTransform.Scale3D, true, UE4.EPSCPoolMethod.None, true)
        end
        if self.itemType == UE4.EItemIdIntervalType.FlyEffect and dataProp.flyEffectSkinId then
          self.UI3DModel:DisplayFlyEffect(dataProp.flyEffectSkinId, self.itemId)
        end
      end
      GameFacade:SendNotification(NotificationDefines.ItemImageDisplay)
      self.UI3DModel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    else
      if dataProp.show3DBackground then
        if self.imageBG then
          self.imageBG:SetVisibility(UE4.ESlateVisibility.Collapsed)
        end
        self.UI3DModel:Display3DEnvBackground()
      end
      GameFacade:SendNotification(NotificationDefines.ItemImageDisplay, self.itemId)
      self.UI2DModel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function ItemDisplayKeysPanel:CanChangeWeaponSkinOnly(newWeaponId)
  local newRoleCfg = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleCfgByWeaponId(newWeaponId)
  if nil == newRoleCfg then
    return false
  end
  local curRoleCfg = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleCfgByWeaponId(self.cachedItemId)
  if nil == curRoleCfg then
    return false
  end
  if newRoleCfg.RoleId ~= curRoleCfg.RoleId then
    return false
  end
  if self.Display3DModelResult then
    local character = self.Display3DModelResult:RetrieveLobbyCharacter(0)
    if nil == character then
      return
    end
    character:EquipWeapon(newWeaponId)
  end
  self.cachedItemId = newWeaponId
  return true
end
function ItemDisplayKeysPanel:PlayRoleAction(actionId)
  LogDebug("ItemDisplayKeysPanel", "Play role action: %d", actionId)
  if self.is3DModel and self.Display3DModelResult then
    local character = self.Display3DModelResult:RetrieveLobbyCharacter(0)
    if nil == character then
      return
    end
    character:PlayAction(actionId)
  end
end
function ItemDisplayKeysPanel:SetCharacterHiddenInGame(bHide)
  LogDebug("ItemDisplayKeysPanel:SetCharacterHiddenInGame", "HiddenInGame :" .. tostring(bHide))
  if self.Display3DModelResult then
    local character = self.Display3DModelResult:RetrieveLobbyCharacter(0)
    if nil == character then
      return
    end
    character:SetActorHiddenInGame(bHide)
  end
  if self.UI3DModel then
    self.UI3DModel:SetVisibility(bHide and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ItemDisplayKeysPanel:SetDecalActorHiddenInGame(bHide)
  LogDebug("ItemDisplayKeysPanel:Set3DModelStaticMeshActorHiddenInGame", "HiddenInGame :" .. tostring(bHide))
  if self.Display3DModelResult then
    local meshActor = self.Display3DModelResult:Get3DModelActorStaticMeshActor()
    if nil == meshActor then
      return
    end
    meshActor:SetActorHiddenInGame(bHide)
  end
  if self.UI3DModel then
    self.UI3DModel:SetVisibility(bHide and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ItemDisplayKeysPanel:HideMedia(isHidden)
  if self.MediaPlayer then
    if isHidden then
      self.MediaPlayer:CloseVideo()
    end
    self.MediaPlayer:SetVisibility(isHidden and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end
function ItemDisplayKeysPanel:GetLobbyCamera()
  if self.lobbyCamera == nil and self.Display3DModelResult and self.itemType == UE4.EItemIdIntervalType.RoleSkin then
    self.lobbyCamera = self.Display3DModelResult:RetrieveLobbyCharacterCamera(0)
  end
  return self.lobbyCamera
end
function ItemDisplayKeysPanel:LuaHandleKeyEvent(key, inputEvent)
  local ret = false
  if self.Button_Esc and not ret then
    ret = self.Button_Esc:MonitorKeyDown(key, inputEvent)
  end
  if self.Button_T and not ret then
    ret = self.Button_T:MonitorKeyDown(key, inputEvent)
  end
  if self.Button_Switch and not ret then
    ret = self.Button_Switch:MonitorKeyDown(key, inputEvent)
  end
  if self.Button_ScreenShot and not ret then
    ret = self.Button_ScreenShot:MonitorKeyDown(key, inputEvent)
  end
  return ret
end
function ItemDisplayKeysPanel:StartDrag()
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, true)
  if self.itemType and self.itemType == UE4.EItemIdIntervalType.Weapon then
    self.actionOnStartDrag()
  end
end
function ItemDisplayKeysPanel:StopDrag()
  UE4.UPMLuaBridgeBlueprintLibrary.HoldUpCustomKeyEvent(self, false)
  if self.itemType and self.itemType == UE4.EItemIdIntervalType.Weapon then
    self.actionOnStopDrag()
  end
end
function ItemDisplayKeysPanel:SetFlyEffectOfBaseSkinID(baseSkinID)
  self.baseSkinID = baseSkinID
end
function ItemDisplayKeysPanel:GetLobbyCharacter(index)
  if self.Display3DModelResult then
    if nil == index then
      index = 0
    end
    return self.Display3DModelResult:RetrieveLobbyCharacter(index)
  end
  return nil
end
function ItemDisplayKeysPanel:ShowCharacterEmote(emoteID)
  if self.EmoteCanvas == nil then
    return
  end
  self:RestEmote()
  local emoteProxy = GameFacade:RetrieveProxy(ProxyNames.RoleEmoteProxy)
  local emoteRow = emoteProxy:GetRoleEmoteTableRow(emoteID)
  if nil == emoteRow then
    return
  end
  local emoteBPClass = ObjectUtil:LoadClass(emoteRow.BluePrint)
  if nil == emoteBPClass then
    return
  end
  local Widget = UE4.UWidgetBlueprintLibrary.Create(self, emoteBPClass)
  if nil == Widget then
    return
  end
  local WidgetSolt = self.EmoteCanvas:AddChild(Widget)
  local size = self:GetScreenResolution()
  LogDebug("ItemDisplayKeysPanel:GetScreenResolution", "ScreenResolution is " .. tostring(size))
  if size and self.EmoteOffsetVector then
    local ViewportPos = UE.FVector2D(0, 0)
    ViewportPos.X = size.X * 0.5 + self.EmoteOffsetVector.X
    ViewportPos.Y = size.Y * 0.3 + self.EmoteOffsetVector.Y
    WidgetSolt:SetPosition(ViewportPos)
    if Widget then
      Widget:UpdateEmote(emoteID)
      Widget:SetIsAutoPlay(true)
    end
  end
end
function ItemDisplayKeysPanel:RestEmote()
  if self.EmoteCanvas == nil then
    return
  end
  self.EmoteCanvas:ClearChildren()
end
function ItemDisplayKeysPanel:StopCharacterAction()
  local character = self:GetLobbyCharacter()
  if character then
    character:StopMontageAction()
  end
end
function ItemDisplayKeysPanel:SetCharacterEnableLeisure(bEnable)
  local character = self:GetLobbyCharacter()
  if character then
  end
end
function ItemDisplayKeysPanel:SwitchAnimStateMachineType(stateMachineType)
  local character = self:GetLobbyCharacter()
  if character then
    character:SwitchAnimStateMachineType(stateMachineType)
  end
end
function ItemDisplayKeysPanel:GetScreenResolution()
  local UserSetting = UE4.UGameUserSettings.GetGameUserSettings()
  local resolution
  resolution = UE4.USlateBlueprintLibrary.GetLocalSize(self:GetCachedGeometry())
  if resolution and resolution.X > 0 and resolution.Y > 0 then
    return resolution
  end
  return UE.FVector2D(1920, 1080)
end
function ItemDisplayKeysPanel:GetDisplayItemID()
  return self.itemId
end
function ItemDisplayKeysPanel:SpawnActionCharacter(actionId)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleActionRow = roleProxy:GetRoleAction(actionId)
  if roleActionRow then
    local roleRow = roleProxy:GetRole(roleActionRow.RoleId)
    if roleRow then
      self.Display3DModelResult = self.UI3DModel:DisplayByItemId(roleRow.RoleSkin, UE4.ELobbyCharacterAnimationStateMachineType.NotHoldWeaponNoLeisure)
    end
  end
end
function ItemDisplayKeysPanel:BindSpawnCharacterDelegate()
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    self.OnLoadingLobbyCharacterDelegate = DelegateMgr:AddDelegate(GlobalDelegateManager.OnLoadingLobbyCharacterDelegate, self, "OnSpawnCharacterCallBack")
  end
end
function ItemDisplayKeysPanel:UnSpawnCharacterDelegate()
  local GlobalDelegateManager = GetGlobalDelegateManager()
  if GlobalDelegateManager and DelegateMgr then
    DelegateMgr:RemoveDelegate(GlobalDelegateManager.OnLoadingLobbyCharacterDelegate, self.OnLoadingLobbyCharacterDelegate)
  end
end
function ItemDisplayKeysPanel:OnSpawnCharacterCallBack(eventData)
  if self.itemType == UE4.EItemIdIntervalType.RoleAction then
    self:PlayRoleAction(self.itemId)
  end
end
function ItemDisplayKeysPanel:PlayRoleVoice()
  if self.itemId == nil then
    return
  end
  local roleVoiceRow = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleVoice(self.itemId)
  if roleVoiceRow then
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    self.PlayingID = audio.PostEvent(audio.GetID(roleVoiceRow.AkEvent))
    if self.UI2DModel then
      self.UI2DModel:PlayRoleVoice()
    end
    self.stopVoiceTask = TimerMgr:AddTimeTask(audio.GetAkEventMinimumDuration(roleVoiceRow.AkEvent), 0, 1, function()
      self:StopRoleVoice()
    end)
  end
end
function ItemDisplayKeysPanel:StopRoleVoice()
  if self.PlayingID then
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    audio.StopPlayingID(self.PlayingID)
    self.PlayingID = nil
    if self.UI2DModel then
      self.UI2DModel:StopRoleVoice()
    end
  end
  if self.stopVoiceTask then
    self.stopVoiceTask:EndTask()
    self.stopVoiceTask = nil
  end
end
function ItemDisplayKeysPanel:RestPanel()
  self.itemId = nil
end
function ItemDisplayKeysPanel:DisplayPackageSkin(roleSkinId, weaponSkinId)
  self:RestPanel()
  local data = {}
  data.itemId = roleSkinId
  data.stateMachineType = UE4.ELobbyCharacterAnimationStateMachineType.HoldWeapon
  self:SetItemDisplayed(data)
  if self.Display3DModelResult then
    local character = self.Display3DModelResult:RetrieveLobbyCharacter(0)
    if nil == character then
      return
    end
    character:EquipWeapon(weaponSkinId)
  end
  self:RestPanel()
end
function ItemDisplayKeysPanel:SetSwitchBtnName(newName)
  if self.Button_Switch then
    self.Button_Switch:SetPanelName(newName)
  end
end
function ItemDisplayKeysPanel:ShowWeaponAttackEffectPreview(weaponID)
  local roleCfg = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleCfgByWeaponId(weaponID)
  if nil == roleCfg then
    return
  end
  local roleId = roleCfg.RoleId
  local roleSkinId = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRoleCurrentWearAdvancedSkinID(roleId)
  if nil == roleSkinId then
    return
  end
  UE4.UCyWeaponSkinEffectPreviewSubsystem.Get(LuaGetWorld()):ShowAttackEffectPreview(roleId, roleSkinId, weaponID, self.itemId)
end
function ItemDisplayKeysPanel:ExitWeaponAttackEffectPreview()
  UE4.UCyWeaponSkinEffectPreviewSubsystem.Get(LuaGetWorld()):ExitAttackEffectPreview()
end
return ItemDisplayKeysPanel
