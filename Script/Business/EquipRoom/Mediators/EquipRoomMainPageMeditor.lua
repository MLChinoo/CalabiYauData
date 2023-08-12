local EquioRoomMainPageMeditor = class("EquioRoomMainPageMeditor", PureMVC.Mediator)
local ERoleViewMode = {PreviewMode = 1, NormalMode = 2}
local Display3DModelResult, EquipRoomProxy, RoleProxy, WeaponProxy
function EquioRoomMainPageMeditor:ListNotificationInterests()
  return {
    NotificationDefines.EquipRoomUpdateRoleList,
    NotificationDefines.EquipRoomUpdateRoleProfessionInfo,
    NotificationDefines.EquipRoomUpdateSkillInfo,
    NotificationDefines.EquipRoomUpdateWeaponEquipSolt,
    NotificationDefines.EquipRoomUpdateWeaponList,
    NotificationDefines.OnResEquipWeapon,
    NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed,
    NotificationDefines.Setting.SettingChangeCompleteNtf
  }
end
function EquioRoomMainPageMeditor:OnRegister()
  self.rolePlayedAppearanceVoiceMap = {}
  if self:GetViewComponent().OnSelectRoleEvent then
    self:GetViewComponent().OnSelectRoleEvent:Add(self.OnSelectRole, self)
  end
  if self:GetViewComponent().OnOpenRolePresetPageEvent then
    self:GetViewComponent().OnOpenRolePresetPageEvent:Add(self.OnOpenRolePresetPage, self)
  end
  if self:GetViewComponent().OnOpenDecalPageEvent then
    self:GetViewComponent().OnOpenDecalPageEvent:Add(self.OnOpenDecalPage, self)
  end
  if self:GetViewComponent().OnOpenWeaponSkinPageEvent then
    self:GetViewComponent().OnOpenWeaponSkinPageEvent:Add(self.OnOpenWeaponSkinPage, self)
  end
  if self:GetViewComponent().OnRoleUnlockEvent then
    self:GetViewComponent().OnRoleUnlockEvent:Add(self.OnRoleUnlockClick, self)
  end
  if self:GetViewComponent().OnClickWeaponSoltItemEvent then
    self:GetViewComponent().OnClickWeaponSoltItemEvent:Add(self.OnClickSoltItem, self)
  end
  if self:GetViewComponent().OnClickWeaponListItemEvent then
    self:GetViewComponent().OnClickWeaponListItemEvent:Add(self.OnClickWeaponListItem, self)
  end
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    self:GetViewComponent().WBP_ItemDisplayKeys.actionOnStartPreview:Add(self.EnterPreviewMode, self)
    self:GetViewComponent().WBP_ItemDisplayKeys.actionOnStopPreview:Add(self.QuitPreviewMode, self)
  end
  self:GetViewComponent().OnCloseAnimationFinishEvent:Add(self.OnCloseAnimationFinish, self)
  self:GetViewComponent().OnClickWeaponListBGEvent:Add(self.OnClickWeaponListBG, self)
  self.bDefaultSelect = true
  self.pageViewMode = ERoleViewMode.NormalMode
  self.bPlayingCloseAnim = false
  EquipRoomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  WeaponProxy = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy)
  self:UpdateBtnName()
end
function EquioRoomMainPageMeditor:OnRemove()
  self:GetViewComponent().OnCloseAnimationFinishEvent:Remove(self.OnCloseAnimationFinish, self)
  self:GetViewComponent().OnCloseAnimationFinishEvent:Remove(self.OnCloseAnimationFinish, self)
  self:GetViewComponent().OnClickWeaponListBGEvent:Remove(self.OnClickWeaponListBG, self)
  if self:GetViewComponent().OnSelectRoleEvent then
    self:GetViewComponent().OnSelectRoleEvent:Remove(self.OnSelectRole, self)
  end
  if self:GetViewComponent().OnOpenRolePresetPageEvent then
    self:GetViewComponent().OnOpenRolePresetPageEvent:Remove(self.OnOpenRolePresetPage, self)
  end
  if self:GetViewComponent().OnOpenDecalPageEvent then
    self:GetViewComponent().OnOpenDecalPageEvent:Remove(self.OnOpenDecalPage, self)
  end
  if self:GetViewComponent().OnOpenWeaponSkinPageEvent then
    self:GetViewComponent().OnOpenWeaponSkinPageEvent:Remove(self.OnOpenWeaponSkinPage, self)
  end
  if self:GetViewComponent().OnRoleUnlockEvent then
    self:GetViewComponent().OnRoleUnlockEvent:Remove(self.OnRoleUnlockClick, self)
  end
  if self:GetViewComponent().OnClickWeaponSoltItemEvent then
    self:GetViewComponent().OnClickWeaponSoltItemEvent:Remove(self.OnClickSoltItem, self)
  end
  if self:GetViewComponent().OnClickWeaponListItemEvent then
    self:GetViewComponent().OnClickWeaponListItemEvent:Remove(self.OnClickWeaponListItem, self)
  end
  if self:GetViewComponent().WBP_ItemDisplayKeys then
    self:GetViewComponent().WBP_ItemDisplayKeys.actionOnStartPreview:Remove(self.EnterPreviewMode, self)
    self:GetViewComponent().WBP_ItemDisplayKeys.actionOnStopPreview:Remove(self.QuitPreviewMode, self)
  end
  self:StopVoice()
end
function EquioRoomMainPageMeditor:HandleNotification(notify)
  local notifyName = notify:GetName()
  local notifyBody = notify:GetBody()
  if notifyName == NotificationDefines.EquipRoomUpdateRoleList then
    self:GetViewComponent():UpdateRoleGridPanel(notifyBody.ItemData)
    if self.bDefaultSelect then
      self:GetViewComponent():SetDefaultSelectItem(EquipRoomProxy:GetSelectRoleID())
    end
    self.bDefaultSelect = true
  elseif notifyName == NotificationDefines.EquipRoomUpdateRoleProfessionInfo then
    self:GetViewComponent().RoleProfessionInfoPanel:UpdatePanel(notifyBody)
  elseif notifyName == NotificationDefines.EquipRoomUpdateSkillInfo then
    self:GetViewComponent().SkillInfoPanel:UpdatePanel(notifyBody)
  elseif notifyName == NotificationDefines.EquipRoomUpdateWeaponEquipSolt then
    self:GetViewComponent().EquipWeaponPanel:UpdateEquipSlot(notifyBody)
  elseif notifyName == NotificationDefines.EquipRoomUpdateWeaponList then
    self:GetViewComponent().EquipWeaponPanel:UpdateWeaponList(notifyBody)
    self:ShowWeaponListPanel()
  elseif notifyName == NotificationDefines.OnResEquipWeapon then
    self:OnResEquipWeaponCallBack(notifyBody)
  elseif notifyName == NotificationDefines.Hermes.PurchaseGoods.BuyGoodsSuccessed then
    if notifyBody.IsSuccessed and notifyBody.PageName == UIPageNameDefine.EquipRoomMainPage then
      self:OnBuyGoodsSuccessed(notifyBody)
    end
  elseif notifyName == NotificationDefines.Setting.SettingChangeCompleteNtf then
    self:SetSkillKeyName()
  end
end
function EquioRoomMainPageMeditor:OnViewComponentPagePreOpen(luaData, originOpenData)
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleListCmd)
  self:GetViewComponent():UpdateRoleListRedDot()
end
function EquioRoomMainPageMeditor:OnSelectRole(roleId)
  if self.currentRoleID == roleId then
    LogDebug("EquioRoomMainPageMeditor:OnSelectRole", "SelectRole already show, Current ID : %s", self.currentRoleID)
    return
  end
  self.currentSoltItemID = nil
  self.currentWeaponSoltType = nil
  self.currentRoleID = roleId
  self:GetViewComponent():HideWeaponListPanel()
  self:ShowRoleModel(roleId)
  self.bChangeRole = true
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleProfessionInfoCmd, roleId)
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateSkillInfoCmd, roleId)
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponEquipSoltCmd, roleId)
  self:GetViewComponent().EquipWeaponPanel:DefalutSelectSoltItem(UE4.EWeaponSlotTypes.WeaponSlot_Primary)
  local roleItem = self:GetViewComponent().SelectRoleGridPanel:GetSelectItem()
  if roleItem then
    self:GetViewComponent():SetRoleUnlockVisible(not roleItem:GetUnlock())
  end
  local equiproomProxy = GameFacade:RetrieveProxy(ProxyNames.EquipRoomProxy)
  equiproomProxy:SetSelectRoleID(roleId)
  self:PlayChangeRoleEffect()
  self:StopVoice()
  self:PlayRoleAppearanceVoice(roleItem:GetItemID())
  self:GetViewComponent():UpdateRedDotByRole()
end
function EquioRoomMainPageMeditor:OnOpenRolePresetPage()
  if self.bPlayingCloseAnim then
    LogDebug("EquioRoomMainPageMeditor:OnOpenRolePresetPage", "Playing Close Anim")
    return
  end
  self.bPlayingCloseAnim = true
  self:PalyCloseAnimationAtChangPage(UIPageNameDefine.EquipRoomRolePresetPage)
end
function EquioRoomMainPageMeditor:OnOpenDecalPage()
  if self.bPlayingCloseAnim then
    LogDebug("EquioRoomMainPageMeditor:OnOpenDecalPage", "Playing Close Anim")
    return
  end
  self.bPlayingCloseAnim = true
  self:PalyCloseAnimationAtChangPage(UIPageNameDefine.EquipRoomDecalPage)
end
function EquioRoomMainPageMeditor:OnOpenWeaponSkinPage()
  if self.bPlayingCloseAnim then
    LogDebug("EquioRoomMainPageMeditor:OnOpenWeaponSkinPage", "Playing Close Anim")
    return
  end
  self.bPlayingCloseAnim = true
  EquipRoomProxy:SetSelectWeaponSlotData(self.currentWeaponSoltType, self.currentSoltItemID)
  self:PalyCloseAnimationAtChangPage(UIPageNameDefine.EquipRoomWeaponSkinPage)
end
function EquioRoomMainPageMeditor:PalyCloseAnimationAtChangPage(nextPage)
  self.nextPage = nextPage
  self:GetViewComponent().ViewSwtichAnimation:PlayCloseAnimation({
    self:GetViewComponent(),
    self:GetViewComponent().OnCloseAnimationFinish
  })
end
function EquioRoomMainPageMeditor:OnCloseAnimationFinish()
  self:GetViewComponent():OpenNextPage(self.nextPage)
end
function EquioRoomMainPageMeditor:OnClickSoltItem(soltItem)
  local roleItem = self:GetCurrentSelectRoleItem()
  if nil == roleItem then
    LogWarn("EquioRoomMainPageMeditor:OnClickSoltItem", "roleItem is nil")
    return
  end
  if nil == soltItem then
    LogWarn("EquioRoomMainPageMeditor:OnClickSoltItem", "soltItem is nil")
    return
  end
  if not roleItem:IsOwn() then
    if soltItem:GetItemSoltType() ~= UE4.EWeaponSlotTypes.WeaponSlot_Primary then
      self:ShowRoleNotUnlockTips()
      return
    end
    LogWarn("EquioRoomMainPageMeditor:OnClickSoltItem", "role not unlock")
  end
  if self.currentWeaponSoltType and self.currentWeaponSoltType == soltItem:GetItemSoltType() then
    if self.currentWeaponSoltType ~= UE4.EWeaponSlotTypes.WeaponSlot_Primary then
      if self.bWeaponListShow then
        self:HideWeaponListPanel()
      else
        self:ShowWeaponListPanel()
      end
    end
    LogDebug("EquioRoomMainPageMeditor:OnClickSoltItem", "lastSoltType and slotItem SoltType equips,type : " .. tostring(soltItem:GetItemSoltType()))
    return
  end
  if soltItem:GetItemSoltType() == UE4.EWeaponSlotTypes.WeaponSlot_Primary then
    self:HideWeaponListPanel()
  else
    self:SendUpdateWeaponListCmd(roleItem:GetItemID(), soltItem:GetItemSoltType())
  end
  if self.currentWeaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 and soltItem:GetItemSoltType() == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 or self.currentWeaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 and soltItem:GetItemSoltType() == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
  else
    self:PlayRoleEquipWeaponVoice(soltItem:GetItemID())
  end
  self:RoleModelEquipWeapon(soltItem:GetItemID())
  self.currentSoltItemID = soltItem:GetItemID()
  self.currentWeaponSoltType = soltItem:GetItemSoltType()
end
function EquioRoomMainPageMeditor:ShowRoleNotUnlockTips()
  local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "RoleUnlockEquipWeaponTips")
  GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
end
function EquioRoomMainPageMeditor:ShowWeaponListPanel()
  if self:GetViewComponent().WeaponListBG and self:GetViewComponent().EquipWeaponPanel then
    self.bWeaponListShow = true
    self:GetViewComponent():ShowWeaponListPanel()
  end
end
function EquioRoomMainPageMeditor:HideWeaponListPanel()
  if self:GetViewComponent().WeaponListBG and self:GetViewComponent().EquipWeaponPanel then
    self.bWeaponListShow = false
    self:GetViewComponent():HideWeaponListPanel()
  end
end
function EquioRoomMainPageMeditor:OnClickWeaponListBG()
  self:HideWeaponListPanel()
end
function EquioRoomMainPageMeditor:SendUpdateWeaponListCmd(roleID, weaponSlotType)
  local body = {}
  body.weaponSlotType = weaponSlotType
  body.roleID = roleID
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponListCmd, body)
end
function EquioRoomMainPageMeditor:OnClickWeaponListItem(data)
  if data.bUnlock then
    local roleItem = self:GetViewComponent().SelectRoleGridPanel:GetSelectItem()
    if roleItem then
      local roleID = roleItem:GetItemID()
      data.roleID = roleID
    end
    GameFacade:SendNotification(NotificationDefines.ReqEquipWeaponCmd, data)
  else
    local text = ConfigMgr:FromStringTable(StringTablePath.ST_Common, "EquipRoomNoUnlockTips")
    GameFacade:SendNotification(NotificationDefines.ShowCommonTipCmd, text)
    return
  end
  self:RoleModelEquipWeapon(data.itemID)
end
function EquioRoomMainPageMeditor:ShowRoleModel(roleID)
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  if roleProxy then
    local roleSkinID = roleProxy:GetRoleCurrentWearAdvancedSkinID(roleID)
    if self:GetViewComponent().WBP_ItemDisplayKeys then
      local dataProp = {}
      dataProp.itemId = roleSkinID
      dataProp.stateMachineType = UE4.ELobbyCharacterAnimationStateMachineType.HoldWeapon
      self:GetViewComponent().WBP_ItemDisplayKeys:SetItemDisplayed(dataProp)
    end
  end
end
function EquioRoomMainPageMeditor:RoleModelEquipWeapon(weaponID)
  local ItemDisplay = self:GetViewComponent().WBP_ItemDisplayKeys
  if ItemDisplay and ItemDisplay.Display3DModelResult then
    local character = ItemDisplay.Display3DModelResult:RetrieveLobbyCharacter(0)
    if character then
      local advanceID = GameFacade:RetrieveProxy(ProxyNames.WeaponProxy):GetEquipAdvanedSkinID(weaponID)
      character:EquipWeapon(advanceID)
      if self.bChangeRole == false then
        character:PlayRoleHoldWeaponAction(weaponID)
      end
      self.bChangeRole = false
    end
  end
end
function EquioRoomMainPageMeditor:EnterPreviewMode()
  if self.bPlayingCloseAnim then
    return
  end
  self.pageViewMode = ERoleViewMode.PreviewMode
  if self:GetViewComponent().EquipWeaponPanel then
    self:GetViewComponent().EquipWeaponPanel:HideWeaponListPanel()
  end
  if self:GetViewComponent().ViewSwtichAnimation then
    self:GetViewComponent().ViewSwtichAnimation:PlayCloseAnimation()
  end
end
function EquioRoomMainPageMeditor:QuitPreviewMode()
  if self.bPlayingCloseAnim then
    return
  end
  self.pageViewMode = ERoleViewMode.NormalMode
  self:GetViewComponent().ViewSwtichAnimation:PlayOpenAnimation()
end
function EquioRoomMainPageMeditor:GetLobbyCamera()
  if self.lobbyCamera == nil and Display3DModelResult then
    self.lobbyCamera = Display3DModelResult:RetrieveLobbyCharacterCamera(0)
  end
  return self.lobbyCamera
end
function EquioRoomMainPageMeditor:OnRoleUnlockClick()
  local roleItem = self:GetViewComponent().SelectRoleGridPanel:GetSelectItem()
  if roleItem then
    local roleRow = GameFacade:RetrieveProxy(ProxyNames.RoleProxy):GetRole(roleItem:GetItemID())
    self:CheckUnlockCond(roleRow)
  end
end
function EquioRoomMainPageMeditor:CheckActivityUnlockSeverData(activityID)
  return GameFacade:RetrieveProxy(ProxyNames.ActivitiesProxy):IsEndActivity(activityID)
end
function EquioRoomMainPageMeditor:JumpActivity(activityID, roleID)
  local Data = {
    StoreId = roleID,
    PageName = UIPageNameDefine.EquipRoomMainPage,
    ActivityId = activityID
  }
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.RoleWarmUpGoodsPanel, false, Data)
end
function EquioRoomMainPageMeditor:CheckUnlockCond(roleRow)
  local unlockArray = {}
  local severdata = RoleProxy:GetRoleSpecialObtainedCfg(roleRow.RoleId)
  if severdata then
    unlockArray = severdata.channels
  else
    local unlockNum = roleRow.GainType:Length()
    if unlockNum ~= roleRow.GainParam1:Length() or 0 == unlockNum then
      return
    end
    for index = 1, unlockNum do
      local unloclCond = {}
      unloclCond.type = roleRow.GainType:Get(index)
      unloclCond.id = roleRow.GainParam1:Get(index)
      table.insert(unlockArray, unloclCond)
    end
  end
  local storeID = roleRow.RoleId
  for key, value in pairs(unlockArray) do
    if value.type == GlobalEnumDefine.EItemUnlockConditionType.Store then
      storeID = value.id
      break
    end
  end
  for key, value in pairs(unlockArray) do
    if value.type == GlobalEnumDefine.EItemUnlockConditionType.Activity and not self:CheckActivityUnlockSeverData(value.id) then
      self:JumpActivity(value.id, storeID)
      return
    end
  end
  self:StoreBuy(storeID)
end
function EquioRoomMainPageMeditor:StoreBuy(storeID)
  local StoreGoodsData = GameFacade:RetrieveProxy(ProxyNames.HermesProxy):GetAnyStoreGoodsDataByStoreId(storeID)
  if nil == StoreGoodsData then
    LogError("OpenPurchaseGoodsPageCmd", "Store表格配置表中没有此Id数据,ID:%s", storeID)
    return nil
  end
  local Data = {
    StoreId = storeID,
    PageName = UIPageNameDefine.EquipRoomMainPage
  }
  ViewMgr:OpenPage(self:GetViewComponent(), UIPageNameDefine.HermesPurchaseGoodsPage, false, Data)
end
function EquioRoomMainPageMeditor:OnBuyGoodsSuccessed(data)
  self.bDefaultSelect = false
  GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateRoleListCmd)
  local roleItem = self:GetViewComponent().SelectRoleGridPanel:GetSelectItem()
  if roleItem then
    self:GetViewComponent():SetRoleUnlockVisible(not roleItem:GetUnlock())
    local roleRow = RoleProxy:GetRole(roleItem:GetItemID())
    if roleRow then
      self:PlayRoleUnlockVoice(roleRow.UnlockVoiceId)
    end
  end
end
function EquioRoomMainPageMeditor:PlayChangeRoleEffect()
end
function EquioRoomMainPageMeditor:PlayRoleAppearanceVoice(roleID)
  if self:CheckRolePlayedAppearanceVoice(roleID) == false then
    return
  end
  local roleRow = RoleProxy:GetRole(roleID)
  if nil == roleRow then
    return
  end
  self.rolePlayedAppearanceVoiceMap[roleID] = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  local voiceID = roleRow.AppearanceVoiceId
  local roleVoiceRow = RoleProxy:GetRoleVoice(voiceID)
  if roleVoiceRow then
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    if self.rolePlayVoiceID then
      self:StopVoice()
    end
    self.rolePlayVoiceID = audio.PostEvent(audio.GetID(roleVoiceRow.AkEvent))
  end
end
function EquioRoomMainPageMeditor:CheckRolePlayedAppearanceVoice(roleID)
  local isPlayed = false
  local lastTime = self.rolePlayedAppearanceVoiceMap[roleID]
  if nil == lastTime then
    isPlayed = true
  else
    local currentTime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
    isPlayed = currentTime - lastTime >= self:GetViewComponent().RoleVoiceCD
  end
  return isPlayed
end
function EquioRoomMainPageMeditor:PlayRoleUnlockVoice(voiceID)
  local roleVoiceRow = RoleProxy:GetRoleVoice(voiceID)
  if roleVoiceRow then
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    if self.rolePlayVoiceID then
      self:StopVoice()
    end
    self.rolePlayVoiceID = audio.PostEvent(audio.GetID(roleVoiceRow.AkEvent))
  end
end
function EquioRoomMainPageMeditor:StopVoice()
  if self.rolePlayVoiceID then
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    audio.StopPlayingID(self.rolePlayVoiceID)
    self.rolePlayVoiceID = nil
    if self.playEquipWeaponVoiceTimer then
      self.playEquipWeaponVoiceTimer:EndTask()
      self.playEquipWeaponVoiceTimer = nil
    end
  end
end
function EquioRoomMainPageMeditor:PlayRoleEquipWeaponVoice(weaponID)
  local voiceID
  local weaponSoltType = WeaponProxy:GetWeaponSlotTypeByWeaponId(weaponID)
  local tempType = weaponSoltType
  if weaponSoltType then
    if weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Secondary then
      local roleRow = RoleProxy:GetRole(EquipRoomProxy:GetSelectRoleID())
      if roleRow then
        voiceID = roleRow.EquipSecondWeaponVoiceId
      end
    elseif weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1 or weaponSoltType == UE4.EWeaponSlotTypes.WeaponSlot_Grenade_2 then
      local roleRow = RoleProxy:GetRole(EquipRoomProxy:GetSelectRoleID())
      if roleRow then
        voiceID = roleRow.EquipGrenadeVoiceId
        tempType = UE4.EWeaponSlotTypes.WeaponSlot_Grenade_1
      end
    end
  end
  if self.bPlayEquipWeaponVoice and self.lastPlayWeaponType == tempType then
    LogDebug("EquioRoomMainPageMeditor:PlayRoleEquipWeaponVoice", "Current weaponType is Palying, Type：" .. tempType)
    return
  end
  if nil == voiceID then
    return
  end
  local roleVoiceRow = RoleProxy:GetRoleVoice(voiceID)
  if roleVoiceRow then
    local audio = UE4.UPMLuaAudioBlueprintLibrary
    if self.rolePlayVoiceID then
      self:StopVoice()
    end
    self.bPlayEquipWeaponVoice = true
    self.lastPlayWeaponType = tempType
    local time = audio.GetAkEventMinimumDuration(roleVoiceRow.AkEvent)
    self.playEquipWeaponVoiceTimer = TimerMgr:AddTimeTask(time, 0, 1, function()
      self:StopEquipWeapon()
    end)
    self.rolePlayVoiceID = audio.PostEvent(audio.GetID(roleVoiceRow.AkEvent))
  end
end
function EquioRoomMainPageMeditor:StopEquipWeapon()
  self.bPlayEquipWeaponVoice = false
  self.lastPlayWeaponType = nil
end
function EquioRoomMainPageMeditor:GetCurrentSelectRoleItem()
  if self:GetViewComponent().SelectRoleGridPanel then
    return self:GetViewComponent().SelectRoleGridPanel:GetSelectItem()
  end
  LogWarn("EquioRoomMainPageMeditor:GetCurrentSelectRoleItem", "SelectRoleGridPanel is nil")
  return nil
end
function EquioRoomMainPageMeditor:SetSkillKeyName()
  local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
  if platform == GlobalEnumDefine.EPlatformType.PC and self:GetViewComponent().SkillInfoPanel then
    self:GetViewComponent().SkillInfoPanel:SetSkillKeyName(GlobalEnumDefine.ERoleSkillType.Active, self:GetSkilKeyName("SkillQ"))
    self:GetViewComponent().SkillInfoPanel:SetSkillKeyName(GlobalEnumDefine.ERoleSkillType.Unique, self:GetSkilKeyName("SkillX"))
    self:GetViewComponent().SkillInfoPanel:UpdateCurrentSkillKeyName()
  end
end
function EquioRoomMainPageMeditor:GetSkilKeyName(keyName)
  local settingInputUtilProxy = GameFacade:RetrieveProxy(ProxyNames.SettingInputUtilProxy)
  local key1, key2 = settingInputUtilProxy:GetKeyByInputName(keyName)
  if key1 and 0 ~= string.len(key1) then
    return key1
  else
    return key2
  end
end
function EquioRoomMainPageMeditor:UpdateBtnName()
  if self:GetViewComponent().Btn_OpenRolePresetPage then
    local name = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "RoleDefault")
    self:GetViewComponent().Btn_OpenRolePresetPage:SetPanelName(name)
  end
  if self:GetViewComponent().Btn_OpeDecalPage then
    local name = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "CommonDefault")
    self:GetViewComponent().Btn_OpeDecalPage:SetPanelName(name)
  end
  if self:GetViewComponent().Btn_OpenWeaponSkinPage then
    local name = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "WeaponSkin")
    self:GetViewComponent().Btn_OpenWeaponSkinPage:SetPanelName(name)
  end
  if self:GetViewComponent().Text_UnlockRole then
    local name = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "ItemBuyPopPageTitle_2")
    self:GetViewComponent().Text_UnlockRole:SetText(name)
  end
end
function EquioRoomMainPageMeditor:OnResEquipWeaponCallBack(notifyBody)
  local roleID = notifyBody.roleID
  local soltItem = self:GetViewComponent().EquipWeaponPanel:GetSelectSoltItem()
  if soltItem then
    if soltItem:GetItemSoltType() == UE4.EWeaponSlotTypes.WeaponSlot_Primary then
      LogError("EquioRoomMainPageMeditor:OnResEquipWeaponCallBack", "SoltType Is Primary")
      return
    end
    self:SendUpdateWeaponListCmd(roleID, soltItem:GetItemSoltType())
    GameFacade:SendNotification(NotificationDefines.EquipRoomUpdateWeaponEquipSoltCmd, roleID)
  end
end
return EquioRoomMainPageMeditor
