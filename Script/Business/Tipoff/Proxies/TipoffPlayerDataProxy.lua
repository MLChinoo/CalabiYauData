local TipoffPlayerDataProxy = class("TipoffPlayerDataProxy", PureMVC.Proxy)
function TipoffPlayerDataProxy:OnRegister()
  TipoffPlayerDataProxy.super.OnRegister(self)
  LogDebug("TipoffPlayerDataProxy", "OnRegister")
  self.TipoffPlayerTabTb = {}
  local TipoffTabTableRow = ConfigMgr:GetTipoffCategoryTableRow()
  if TipoffTabTableRow then
    for RowName, RowData in pairs(TipoffTabTableRow:ToLuaTable()) do
      self.TipoffPlayerTabTb[RowData.EnteraceType] = RowData
    end
  end
  LogDebug("TipoffPlayer", TableToString(self.TipoffPlayerTabTb))
  self.TipOffBehaviorTb = {}
  local TipoffBehaviorTableRow = ConfigMgr:GetTipoffBehaviorTableRow()
  if TipoffBehaviorTableRow then
    for RowName, RowData in pairs(TipoffBehaviorTableRow:ToLuaTable()) do
      self.TipOffBehaviorTb[RowData.CategoryType] = RowData
    end
  end
  self.TipoffConfig = nil
  local TipoffGlobalTableRow = ConfigMgr:GetTipoffGlobalTableRow()
  if TipoffGlobalTableRow then
    local TipoffGlobalTb = TipoffGlobalTableRow:ToLuaTable()
    if TipoffGlobalTb then
      self.TipoffConfig = {}
      for RowName, RowData in pairs(TipoffGlobalTb) do
        self.TipoffConfig[RowData.Id] = RowData.Param
      end
    end
  else
    LogDebug("TipoffPlayerDataProxy", "Tipff Data Failed .")
  end
  self.CurrentTipOffData = nil
  self:InitResetCurentTipoffData()
end
function TipoffPlayerDataProxy:OnRemove()
  LogDebug("TipoffPlayerDataProxy", "OnRemove")
  self.TipOffBehaviorTb = nil
  self.TipoffPlayerTabTb = nil
  self.CurrentTipOffData = nil
  TipoffPlayerDataProxy.super.OnRemove(self)
end
function TipoffPlayerDataProxy:ResetTipoffCache()
  self:InitResetCurentTipoffData()
end
function TipoffPlayerDataProxy:InitResetCurentTipoffData()
  self.CurrentTipOffData = {
    TargetUID = -1,
    CurCategoryType = 0,
    CurReasonTypes = {},
    CurSceneType = 0,
    CurBattleID = 0,
    CurBattleTime = 0,
    CurDesc = "",
    CurContent = "",
    CurEntranceType = 0,
    RoomID = -1,
    BattleTime = 0
  }
end
function TipoffPlayerDataProxy:ClearTipoffReson()
  if self.CurrentTipOffData then
    self.CurrentTipOffData.CurReasonTypes = {}
  end
end
function TipoffPlayerDataProxy:InitTipoffPlayerData(data)
  self:ResetTipoffCache()
  LogDebug("TipoffPlayerDataProxy", "TipoffPlayerDataProxy:InitTipoffPlayerData .")
  LogDebug("TipoffPlayerDataProxy", TableToString(data))
  if self.CurrentTipOffData then
    self.CurrentTipOffData.TargetUID = data.TargetUID
    self.CurrentTipOffData.TargetName = data.TargetName
    self.CurrentTipOffData.CurCategoryType = self:GetDafaultCategoryType(data.EnteranceType)
    self.CurrentTipOffData.CurSceneType = data.SceneType
    self.CurrentTipOffData.CurEntranceType = data.EnteranceType
    self.CurrentTipOffData.RoomID = 0
    self.CurrentTipOffData.BattleTime = 0
    if data.Content ~= nil and data.Content ~= "" then
      self.CurrentTipOffData.CurContent = data.Content
    end
    local GameState = UE4.UGameplayStatics.GetGameState(LuaGetWorld())
    if GameState then
      local PMGS = GameState:Cast(UE4.APMGameState)
      if PMGS then
        self.CurrentTipOffData.RoomID = PMGS.RoomID
        self.CurrentTipOffData.BattleTime = UE4.UPMLuaBridgeBlueprintLibrary.GetBattleStartTime(LuaGetWorld())
      end
    end
  end
end
function TipoffPlayerDataProxy:UpdateTipBehaviorData(data)
  if not data then
    return
  end
  local bChoose = data.bChoose
  local TipoffReasonType = data.ReasonType
  if bChoose then
    if not self:IsTipoffReasonDataExist(TipoffReasonType) then
      table.insert(self.CurrentTipOffData.CurReasonTypes, TipoffReasonType)
    end
  elseif self:IsTipoffReasonDataExist(TipoffReasonType) then
    for i = #self.CurrentTipOffData.CurReasonTypes, 1, -1 do
      if self.CurrentTipOffData.CurReasonTypes[i] == TipoffReasonType then
        table.remove(self.CurrentTipOffData.CurReasonTypes, i)
        break
      end
    end
  end
  LogDebug("TipoffPlayerDataProxy", "===================================================")
  LogDebug("TipoffPlayerDataProxy", TableToString(self.CurrentTipOffData.CurReasonTypes))
end
function TipoffPlayerDataProxy:UpdateTipDesc(DescData)
  if DescData then
    self.CurrentTipOffData.CurDesc = DescData
  end
end
function TipoffPlayerDataProxy:UpdateCurCategoryType(CategoryType)
  if self.CurrentTipOffData then
    if self.CurrentTipOffData.CurCategoryType ~= CategoryType then
      self.CurrentTipOffData.CurCategoryType = CategoryType
    end
    if #self.CurrentTipOffData.CurReasonTypes > 0 then
      self:ClearTipoffReson()
    end
  end
  GameFacade:SendNotification(NotificationDefines.TipoffPlayer.TipoffCategoryChange)
end
function TipoffPlayerDataProxy:GetTipoffBehaviorTableRow()
  return self.TipOffBehaviorTb
end
function TipoffPlayerDataProxy:GetTipOffTabTableRow(entranceType)
  return self.TipoffPlayerTabTb[entranceType]
end
function TipoffPlayerDataProxy:IsTipoffReasonDataExist(TipoffBehaviorID)
  return table.containsValue(self.CurrentTipOffData.CurReasonTypes, TipoffBehaviorID)
end
function TipoffPlayerDataProxy:GetTipoffReasonSelectedNum()
  LogDebug("LogDebug", TableToString(self.CurrentTipOffData.CurReasonTypes))
  return #self.CurrentTipOffData.CurReasonTypes
end
function TipoffPlayerDataProxy:GetCurTipoffData()
  return self.CurrentTipOffData
end
function TipoffPlayerDataProxy:GetCurCategoryType()
  if self.CurrentTipOffData then
    return self.CurrentTipOffData.CurCategoryType
  end
  return -1
end
function TipoffPlayerDataProxy:GetCurEnteranceType()
  if self.CurrentTipOffData then
    return self.CurrentTipOffData.CurEntranceType
  end
  return -1
end
function TipoffPlayerDataProxy:GetCurTargetUID()
  if self.CurrentTipOffData then
    return self.CurrentTipOffData.TargetUID
  end
  return -1
end
function TipoffPlayerDataProxy:GetCurTipoffBehavior()
  return self.CurrentTipOffData.CurReasonTypes, #self.CurrentTipOffData.CurReasonTypes
end
function TipoffPlayerDataProxy:GetTipoffTargetUID()
  if self.CurrentTipOffData then
    return self.CurrentTipOffData.TargetUID
  end
  return -1
end
function TipoffPlayerDataProxy:GetTipoffContent()
  if self.CurrentTipOffData then
    return self.CurrentTipOffData.CurContent
  end
  return ""
end
function TipoffPlayerDataProxy:GetMaxTipoffReasonNum()
  if self.TipoffConfig and self.TipoffConfig[UE4.ECyTipoffType.TIPOFF_OPTION_MAX_NUM] then
    return self.TipoffConfig[UE4.ECyTipoffType.TIPOFF_OPTION_MAX_NUM]
  end
  return 2
end
function TipoffPlayerDataProxy:GetMaxTipoffContentNum()
  if self.TipoffConfig and self.TipoffConfig[UE4.ECyTipoffType.TIPOFF_MAX_CONTENT] then
    return self.TipoffConfig[UE4.ECyTipoffType.TIPOFF_MAX_CONTENT]
  end
  return -1
end
function TipoffPlayerDataProxy:GetTipoffPlayerName(uid, entranceType)
  if uid <= 0 then
    return ""
  end
  if entranceType == UE4.ECyTipoffEntranceType.ENTERANCE_INGAME or entranceType == UE4.ECyTipoffEntranceType.ENTERANCE_ENDGAME then
    local playerName = self:GetTipoffPlayerNameInGame(uid)
    if playerName then
      return playerName
    end
    return nil
  else
    return nil
  end
end
function TipoffPlayerDataProxy:GetTipoffPlayerNameInGame(uid)
  local roomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  if roomProxy then
    local roomMemberList = roomProxy:GetTeamMemberList()
    if roomMemberList then
      for key, value in pairs(roomMemberList) do
        if nil ~= value and value.playerId == uid then
          return value.nick
        end
      end
    end
  end
  return nil
end
function TipoffPlayerDataProxy:GetDafaultCategoryType(entranceType)
  local CategoryTypeRowTable = self.TipoffPlayerTabTb[entranceType]
  if CategoryTypeRowTable and CategoryTypeRowTable.CategoryTypes and CategoryTypeRowTable.CategoryTypes:Num() > 0 then
    return CategoryTypeRowTable.CategoryTypes:Get(1)
  end
  return -1
end
return TipoffPlayerDataProxy
