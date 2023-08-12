local BattleRecordItem = class("BattleRecordItem", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function BattleRecordItem:OnListItemObjectSet(itemObj)
  local recordData = itemObj.data
  if recordData then
    self.roomId = recordData.room_id
    local matchResult = CareerEnumDefine.winType.draw
    if table.count(recordData.winner_team) > 0 then
      if table.containsValue(recordData.winner_team, recordData.my_team) then
        matchResult = CareerEnumDefine.winType.win
      else
        matchResult = CareerEnumDefine.winType.lose
      end
    end
    if self.WidgetSwitcher_Bg then
      if matchResult == CareerEnumDefine.winType.lose then
        self.WidgetSwitcher_Bg:SetActiveWidgetIndex(1)
      else
        self.WidgetSwitcher_Bg:SetActiveWidgetIndex(0)
      end
    end
    if self.Text_Time and recordData.fight_time then
      local minute = math.floor(recordData.fight_time / 60)
      local second = recordData.fight_time % 60
      local minuteString = tostring(minute)
      local secondString = tostring(second)
      if minute < 10 then
        minuteString = "0" .. minuteString
      end
      if second < 10 then
        secondString = "0" .. secondString
      end
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Career, "BattleDuration")
      local stringMap = {
        [0] = minuteString,
        [1] = secondString
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.Text_Time:SetText(text)
    end
    if self.TextBlock_Score and self.TextBlock_Date and self.TextBlock_GameMode then
      local scoreText = ""
      if #recordData.scores > 0 then
        for key, value in pairs(recordData.scores) do
          if key == recordData.my_team then
            scoreText = value .. scoreText
          else
            scoreText = scoreText .. "-" .. value
          end
        end
      end
      self.TextBlock_Score:SetText(scoreText)
      self.TextBlock_Score:SetVisibility("" == scoreText and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
      if self.WidgetSwitcher_OutCome then
        self.WidgetSwitcher_OutCome:SetActiveWidgetIndex(matchResult)
      end
      local battleTime = os.date("%Y-%m-%d %H:%M", recordData.time)
      self.TextBlock_Date:SetText(battleTime)
      local gameModeText = ""
      if recordData.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_BOMB then
        gameModeText = "Normal-Bomb"
      elseif recordData.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_TEAM then
        gameModeText = "Normal-Team"
      elseif recordData.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_RANK_BOMB then
        gameModeText = "Rank-Bomb"
      elseif recordData.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_MINE then
        gameModeText = "Normal-Mine"
      elseif recordData.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_TEAM_5V5V5 or recordData.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_TEAM_3V3V3 then
        gameModeText = "Normal-Team"
      elseif recordData.game_mode == Pb_ncmd_cs.ERoomMode.RoomMode_ROOM then
        if recordData.play_mode == Pb_ncmd_cs.EPlayMode.PlayMode_BOMB then
          gameModeText = "Custom-Bomb"
        end
        if recordData.play_mode == Pb_ncmd_cs.EPlayMode.PlayMode_TEAM then
          gameModeText = "Custom-Team"
        end
        if recordData.play_mode == Pb_ncmd_cs.EPlayMode.PlayMode_MINE then
          gameModeText = "Custom-Mine"
        end
        if recordData.play_mode == Pb_ncmd_cs.EPlayMode.PlayMode_TEAM_5V5V5 or recordData.play_mode == Pb_ncmd_cs.EPlayMode.PlayMode_TEAM_3V3V3 then
          gameModeText = "Custom-Team"
        end
      end
      self.TextBlock_GameMode:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_Career, gameModeText))
    end
    if self.Image_Map and self.TextBlock_Map then
      local mapCfg = GameFacade:RetrieveProxy(ProxyNames.MapProxy):GetMapCfg(recordData.map_id)
      if mapCfg then
        self:SetImageByTexture2D_MatchSize(self.Image_Map, mapCfg.IconMapCareer)
        self.TextBlock_Map:SetText(mapCfg.Name)
      else
        LogWarn("BattleRecordItem", "Map:%s config is missing", recordData.map_id)
      end
    end
  end
  self.parentPage = itemObj.parentPage
  self.parentPage.actionOnChooseRecord:Add(self.CheckChosen, self)
  if self.CheckBox_Item then
    self.CheckBox_Item:SetIsChecked(false)
    if self.parentPage.currentChosen == self.roomId or itemObj.shouldChosen then
      self.CheckBox_Item:SetIsChecked(true)
      itemObj.shouldChosen = false
    end
  end
end
function BattleRecordItem:CheckChosen(InroomId)
  if self.roomId and self.CheckBox_Item and InroomId == self.roomId then
    self.CheckBox_Item:SetIsChecked(true)
    if self.SelectSound then
      self:K2_PostAkEvent(self.SelectSound)
    end
  else
    self.CheckBox_Item:SetIsChecked(false)
  end
end
return BattleRecordItem
