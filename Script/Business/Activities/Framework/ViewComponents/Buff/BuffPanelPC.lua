local BuffPanelPC = class("BuffPanelPC", PureMVC.ViewComponentPanel)
local BuffPanelMediator = require("Business/Activities/Framework/Mediators/Buff/BuffPanelMediator")
local BuffEnum = require("Business/Activities/Framework/Proxies/BuffEnum")
function BuffPanelPC:ListNeededMediators()
  return {BuffPanelMediator}
end
local StartX = 308
local OffsetX = 36
local StartY = 12
function BuffPanelPC:OnInitialized()
  BuffPanelPC.super.OnInitialized(self)
  self.BuffWidgetTbl = {
    self.Buff1,
    self.Buff2,
    self.BuffCafe
  }
  for i, v in ipairs(self.BuffWidgetTbl) do
    v:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  local AttributeTb = ConfigMgr:GetAttributeTableRow()
  AttributeTb = AttributeTb:ToLuaTable()
  self.AttributeTbl = {}
  for key, value in pairs(AttributeTb) do
    self.AttributeTbl[key] = value
  end
  self.buffData = {}
end
function BuffPanelPC:SetData(data, sourceType)
  if sourceType == BuffEnum.Source.Activity then
    for k, cfg in pairs(data.cfg_list) do
      self.buffData[cfg.attribute_id] = self.buffData[cfg.attribute_id] or {}
      self.buffData[cfg.attribute_id].act = {
        rate = cfg.rate,
        expire_time = data.actInfo.cfg.expire_time,
        starttime = data.actInfo.cfg.start_time
      }
    end
  elseif sourceType == BuffEnum.Source.System then
    for i, v in pairs(data) do
      if v.effect_id == GlobalEnumDefine.PlayerAttributeType.emEXP then
        local attribute_id = GlobalEnumDefine.PlayerAttributeType.emExpIncRate
        self.buffData[attribute_id] = self.buffData[attribute_id] or {}
        self.buffData[attribute_id].sys = {
          rate = v.effect_rate,
          expire_time = v.duration
        }
      end
    end
  elseif sourceType == BuffEnum.Source.QQ then
    local attribute_id = GlobalEnumDefine.PlayerAttributeType.emExpIncRate
    self.buffData[attribute_id] = self.buffData[attribute_id] or {}
    self.buffData[attribute_id].qq = {rate = 1, expire_time = 0}
  end
  self:SetBuffIcon()
  self:CreateUpdateTimer()
  self:RefreshBuffPosition()
  self:UpdateViewVisible()
end
function BuffPanelPC:InitializeLuaEvent()
  if self.Button_Play then
    self.Button_Play.OnClicked:Add(self, BuffPanelPC.OnPlayClick)
  end
  if self.Button_Close then
    self.Button_Close.OnClicked:Add(self, BuffPanelPC.OnCloseClick)
  end
end
function BuffPanelPC:OnCloseClick()
end
function BuffPanelPC:OnPlayClick()
  print("BuffPage!!!!")
end
function BuffPanelPC:CreateUpdateTimer()
  self:DestoryUpdateTimer()
  if self.updateTimer == nil then
    local intervalTime = 1
    self.updateTimer = TimerMgr:AddTimeTask(0, intervalTime, 0, function()
      self.effectBuffCnt = 0
      for i = 1, #self.buffAttribute do
        self:ShowCountTimeText(i)
      end
      if 0 == self.effectBuffCnt then
        self:DestoryUpdateTimer()
        self.Buff1:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self.Buff2:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self:UpdateViewVisible()
      end
    end)
  end
end
function BuffPanelPC:GetShowCountTimeText(index)
  local attri = self.buffAttribute[index]
  local currentBuff = self.buffData[attri]
  local BuffProxy = GameFacade:RetrieveProxy(ProxyNames.BuffProxy)
  local actEffected = not BuffProxy:CheckActBuffIsExpired()
  if currentBuff.act and 0 == currentBuff.act.expire_time and actEffected then
    return ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Forever")
  end
  local duration_time = 0
  local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  if currentBuff.act and servertime < currentBuff.act.expire_time and servertime > currentBuff.act.starttime and actEffected then
    duration_time = currentBuff.act.expire_time - servertime
  end
  if currentBuff.sys and servertime < currentBuff.sys.expire_time then
    local dtime = currentBuff.sys.expire_time - servertime
    if duration_time < dtime then
      duration_time = dtime
    end
  end
  if duration_time > 0 then
    local showTxt = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "RestTime")
    local stringMap = {
      [0] = BuffProxy:SecondToStrFormat(duration_time)
    }
    local text = ObjectUtil:GetTextFromFormat(showTxt, stringMap)
    return text
  end
  if currentBuff.qq and currentBuff.qq.rate > 0 then
    return ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Forever")
  end
end
function BuffPanelPC:CheckBuffEffected(index)
  local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  local attri = self.buffAttribute[index]
  local currentBuff = self.buffData[attri]
  if currentBuff.act then
    local BuffProxy = GameFacade:RetrieveProxy(ProxyNames.BuffProxy)
    local actEffected = not BuffProxy:CheckActBuffIsExpired()
    if actEffected then
      if 0 == currentBuff.act.expire_time then
        return true
      end
      local duration_time = currentBuff.act.expire_time - servertime
      if duration_time > 0 then
        return true
      end
    end
  end
  if currentBuff.sys then
    local duration_time = currentBuff.sys.expire_time - servertime
    if duration_time > 0 then
      return true
    end
  end
  if currentBuff.qq and currentBuff.qq.rate > 0 then
    return true
  end
  return false
end
function BuffPanelPC:GetRate(index)
  local attri = self.buffAttribute[index]
  local currentBuff = self.buffData[attri]
  local BuffProxy = GameFacade:RetrieveProxy(ProxyNames.BuffProxy)
  local actEffected = not BuffProxy:CheckActBuffIsExpired()
  local rate = 0
  local servertime = UE4.UPMLuaBridgeBlueprintLibrary.GetServerTime()
  if actEffected and currentBuff.act then
    if 0 == currentBuff.act.expire_time then
      rate = rate + currentBuff.act.rate * 100
    elseif servertime < currentBuff.act.expire_time and servertime > currentBuff.act.starttime then
      rate = rate + currentBuff.act.rate * 100
    end
  end
  if currentBuff.sys and servertime < currentBuff.sys.expire_time then
    local dtime = currentBuff.sys.expire_time - servertime
    if dtime > 0 then
      rate = rate + currentBuff.sys.rate
    end
  end
  if currentBuff.qq then
    rate = rate + currentBuff.qq.rate
  end
  return rate
end
function BuffPanelPC:ShowCountTimeText(index)
  if self:CheckBuffEffected(index) then
    self.effectBuffCnt = self.effectBuffCnt + 1
    local restTimeText = self:GetShowCountTimeText(index)
    local attribute = self.buffAttribute[index]
    local name = self.AttributeTbl[attribute .. ""].Name
    local rate = self:GetRate(index)
    self["Buff" .. index]:RefreshContentAndRestTime(string.format("%s:%d%%", name, rate), restTimeText)
  else
  end
end
function BuffPanelPC:SetBuffIcon()
  for i = 1, 2 do
    if self["Buff" .. i] then
      self["Buff" .. i]:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  local index = 1
  local buffAttribute = {}
  for attribute, v in pairs(self.buffData) do
    if self["Buff" .. index] then
      local name = self.AttributeTbl[attribute .. ""].Name
      local brush = self.SlateBrushMap:Find(tostring(attribute))
      if nil == brush then
        brush = self.SlateBrushMap:Find("0")
      end
      self["Buff" .. index]:SetBrush(brush)
      buffAttribute[#buffAttribute + 1] = attribute
      self["Buff" .. index]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    index = index + 1
  end
  self:RefreshBuffPosition()
  self.buffAttribute = buffAttribute
end
function BuffPanelPC:SetViewVisible(bToggleShowUI)
  self.bToggleShowUI = bToggleShowUI
  self:UpdateViewVisible()
end
function BuffPanelPC:RefreshPrivilegeCfg()
  local CafePrivilegeProxy = GameFacade:RetrieveProxy(ProxyNames.CafePrivilegeProxy)
  local barInfo = CafePrivilegeProxy:GetCurrentInternetBarInfo()
  if barInfo then
    self.BuffCafe:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    self.BuffCafe:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self.BuffCafe:RefreshPrivilegeCfg(barInfo)
  self:RefreshBuffPosition()
  self:UpdateViewVisible()
end
function BuffPanelPC:UpdateViewVisible()
  if self.bToggleShowUI and self:CheckAnyBuffShow() then
    GameFacade:SendNotification(NotificationDefines.Activities.BuffShowVis, {bVis = true})
  else
    GameFacade:SendNotification(NotificationDefines.Activities.BuffShowVis, {bVis = false})
  end
end
function BuffPanelPC:DestoryUpdateTimer()
  if self.updateTimer then
    self.updateTimer:EndTask()
    self.updateTimer = nil
  end
end
function BuffPanelPC:RefreshBuffPosition()
  local index = 0
  for i, v in ipairs(self.BuffWidgetTbl) do
    if v:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
      self:SetBuffPosition(v, index)
      index = index + 1
    end
  end
end
function BuffPanelPC:CheckAnyBuffShow()
  for i, v in ipairs(self.BuffWidgetTbl) do
    if v:GetVisibility() ~= UE4.ESlateVisibility.Collapsed then
      return true
    end
  end
  return false
end
function BuffPanelPC:SetBuffPosition(widget, idx)
  local x = StartX + idx * OffsetX
  widget.Slot:SetPosition(UE4.FVector2D(x, StartY))
end
function BuffPanelPC:Destruct()
  BuffPanelPC.super.Destruct(self)
  self:DestoryUpdateTimer()
end
return BuffPanelPC
