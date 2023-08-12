local RoleAchievementMediator = require("Business/Career/Mediators/RoleAchievement/RoleAchievementMediator")
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
local RoleAchievementPage = class("RoleAchievementPage", PureMVC.ViewComponentPage)
function RoleAchievementPage:ListNeededMediators()
  return {RoleAchievementMediator}
end
function RoleAchievementPage:InitializeLuaEvent()
  LogDebug("RoleAchievementPage", "Init lua event")
end
function RoleAchievementPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("RoleAchievementPage", "Lua implement OnOpen")
  if self.bHideChat then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  end
  GameFacade:SendNotification(NotificationDefines.Career.RoleAchievement.InitPage)
end
function RoleAchievementPage:InitView(roleAchievementMap)
  self.RoleAchvInfo = GameFacade:RetrieveProxy(ProxyNames.AchievementDataProxy):GetRoleAchvInfo()
  self.RoleAchvMap = roleAchievementMap or {}
  self.GeneralId = 0
  self.AchvSlotList = {}
  self.RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  self.AllRoleProfileCfg = self.RoleProxy:GetAllRoleProfile()
  self.RoleDisplayOrder = {}
  self.RoleDisplayOrder[0] = {
    self.GeneralId
  }
  for _, cfg in pairs(self.AllRoleProfileCfg) do
    local roleId = cfg.RoleId
    local roleTeam = cfg.Team
    local isAvailable = self.RoleProxy:GetRole(roleId).AvailableState
    if isAvailable > 0 then
      if not self.RoleDisplayOrder[roleTeam] then
        self.RoleDisplayOrder[roleTeam] = {}
      end
      table.insert(self.RoleDisplayOrder[roleTeam], roleId)
    end
  end
  for teamId, roles in ipairs(self.RoleDisplayOrder) do
    table.sort(roles, function(a, b)
      return a < b
    end)
  end
  self:InitRoleScroll()
  self:PlayAnimation(self.Anim_In, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function RoleAchievementPage:InitRoleScroll()
  self.AllHeroLogicId = 0
  self.AllHeroIdx = 0
  local allHeroItemData = {}
  allHeroItemData.RoleId = self.AllHeroLogicId
  allHeroItemData.RoleAchvInfo = self.RoleAchvInfo[self.AllHeroLogicId]
  allHeroItemData.ItemType = CareerEnumDefine.RoleAchvHeadItemType.General
  self.AllHeroHeadItem:InitItem(self.AllHeroIdx, allHeroItemData)
  self.AllHeroHeadItem:PlayAnimation(self.AllHeroHeadItem.Anim_In, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  local teamOrder = {
    1,
    3,
    2
  }
  self.HeadItemsList = {}
  local listIdx = 0
  local headItemCount = 0
  for order, teamId in ipairs(teamOrder) do
    for idx, roleId in ipairs(self.RoleDisplayOrder[teamId]) do
      local headItemData = {}
      headItemData.RoleId = roleId
      headItemData.RoleAchvInfo = self.RoleAchvInfo[roleId]
      headItemData.ItemType = CareerEnumDefine.RoleAchvHeadItemType.Hero
      headItemData.RoleProfileCfg = self.AllRoleProfileCfg[tostring(roleId)]
      local defaultSkinCfg = self.RoleProxy:GetRoleDefaultSkin(roleId)
      headItemData.RoleHeadTexture = defaultSkinCfg.IconRoleSelect
      local headItem = self.DynaEntryHeadItem:BP_CreateEntry()
      if headItem then
        listIdx = listIdx + 1
        headItem:InitItem(listIdx, headItemData)
        self.HeadItemsList[listIdx] = headItem
      end
      headItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
      headItemCount = headItemCount + 1
    end
  end
  self.EnterCount = 0
  self.HeadEnterTimer = TimerMgr:AddTimeTask(0.02, 0.02, headItemCount, function()
    self.EnterCount = self.EnterCount + 1
    local headItem = self.HeadItemsList[self.EnterCount]
    headItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    headItem:PlayAnimation(headItem.Anim_In, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    if self.EnterCount == headItemCount then
      self:ClearHeadEnterTimer()
    end
  end)
  self.AllHeroHeadItem:OnItemClicked()
end
function RoleAchievementPage:ClearHeadEnterTimer()
  if self.HeadEnterTimer then
    self.HeadEnterTimer:EndTask()
    self.HeadEnterTimer = nil
  end
end
function RoleAchievementPage:OnRoleHeadItemClicked(itemIdx)
  if self.CurMemItem and self.CurMemItem.Idx == itemIdx then
    return
  end
  if itemIdx == self.AllHeroIdx then
    self.CurMemItem = self.AllHeroHeadItem
    self:OnHeadItemSelected(self.AllHeroHeadItem)
    self.TxtAllHero:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.TxtAllHero:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  for index, headItem in ipairs(self.HeadItemsList) do
    if index == itemIdx then
      self.CurMemItem = headItem
      self:OnHeadItemSelected(headItem)
      self.AllHeroHeadItem:SetNotBeSelected()
    else
      headItem:SetNotBeSelected()
    end
  end
  self:PlayAnimation(self.Anim_ChangeRole, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function RoleAchievementPage:OnHeadItemSelected(targetItem)
  local roleAchvInfo = targetItem.RoleAchvData.RoleAchvInfo
  local roleId = targetItem.RoleAchvData.RoleId
  if roleId > 0 then
    local portraitTexture = self.RoleProxy:GetRole(roleId).AchivmentPortrait
    self:SetImageByTexture2D(self.ImgHeroPortrait, portraitTexture)
    self.ImgHeroPortrait:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.ImgAllHero:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.ImgHeroPortrait:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.ImgAllHero:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:UpdateAchvScroll(roleAchvInfo)
end
function RoleAchievementPage:UpdateAchvScroll(roleAchvInfo)
  local minSlotNum = 5
  local groupIdx = 0
  local checkGroup = 0
  local AchvGroup = {}
  for baseId, info in pairs(roleAchvInfo or {}) do
    if 0 == math.fmod(checkGroup, 2) then
      groupIdx = groupIdx + 1
      checkGroup = 0
    end
    checkGroup = checkGroup + 1
    if not AchvGroup[groupIdx] then
      AchvGroup[groupIdx] = {}
    end
    table.insert(AchvGroup[groupIdx], info)
  end
  local slotIdx = 0
  self.DynaEntryAchvSlot:Reset()
  self.AchvSlotList = {}
  for Idx, groupData in ipairs(AchvGroup) do
    local slotItem = self.DynaEntryAchvSlot:BP_CreateEntry()
    if slotItem then
      slotIdx = slotIdx + 1
      slotItem:UpdateSlot(slotIdx, groupData)
      self.AchvSlotList[slotIdx] = slotItem
    end
  end
  if minSlotNum > slotIdx then
    for i = slotIdx + 1, minSlotNum do
      local slotItem = self.DynaEntryAchvSlot:BP_CreateEntry()
      slotItem:UpdateSlot(i)
      self.AchvSlotList[i] = slotItem
    end
  end
  if slotIdx > 0 then
    self:ClearAchvItemEnterTimer()
    self.AchvEnterCount = 0
    self.AchvEnterTimer = TimerMgr:AddTimeTask(0, 0.2, slotIdx, function()
      self.AchvEnterCount = self.AchvEnterCount + 1
      local slotItem = self.AchvSlotList[self.AchvEnterCount]
      slotItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      slotItem:PlayerEnterAnim()
      if self.AchvEnterCount == slotIdx then
        self:ClearAchvItemEnterTimer()
      end
    end)
  end
end
function RoleAchievementPage:ClearAchvItemEnterTimer()
  if self.AchvEnterTimer then
    self.AchvEnterTimer:EndTask()
    self.AchvEnterTimer = nil
  end
end
function RoleAchievementPage:OnRoleAchvItemClicked(roleAchvItem)
  for idx, slotItem in ipairs(self.AchvSlotList) do
    slotItem:UpdateClickState(roleAchvItem.ParentSlotIdx, roleAchvItem.ItemIdx)
  end
  local curLv = roleAchvItem.AchvInfo.level
  local nextLv = curLv + 1
  local totalLv = table.count(roleAchvItem.AchvInfo.levelNodes)
  if curLv == totalLv then
    nextLv = curLv
  end
  local achvCfg = roleAchvItem.AchvInfo.itemConfig
  self.TxtAchvName:SetText(achvCfg.Name)
  local explainMsg = achvCfg.Explain
  local strMap = {}
  strMap[0] = roleAchvItem.AchvInfo.levelNodes[nextLv]
  explainMsg = ObjectUtil:GetTextFromFormat(explainMsg, strMap)
  self.RT_Description:SetText(explainMsg)
  self.TextBlock_Detail:SetText(achvCfg.Details)
  local progressInfo = {}
  progressInfo.progress = roleAchvItem.AchvInfo.progress
  progressInfo.curLv = curLv
  progressInfo.nextLv = nextLv
  self.RoleAchvLevelNodes:UpdateLevelNodes(roleAchvItem.AchvInfo.levelNodes, progressInfo)
  self.CurMemItem:UpdateRedDot()
end
function RoleAchievementPage:OnClose()
  self:ClearHeadEnterTimer()
  self:ClearAchvItemEnterTimer()
  if self.bHideChat then
    GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  end
  if self.HotKeyButton_Esc then
    self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  end
end
function RoleAchievementPage:ShowAchievementTypeInfo()
end
function RoleAchievementPage:ShowMedalInfo()
end
function RoleAchievementPage:OnEscHotKeyClick()
  LogInfo("RoleAchievementPage", "OnEscHotKeyClick")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
return RoleAchievementPage
