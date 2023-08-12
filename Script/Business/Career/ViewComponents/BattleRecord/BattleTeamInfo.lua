local BattleTeamInfo = class("BattleTeamInfo", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function BattleTeamInfo:ListNeededMediators()
  return {}
end
function BattleTeamInfo:UpdateTeamInfo(data)
  local campId = data.campId
  local bSelfTeam = data.bMyTeam
  if self.WidgetSwitcher_TeamBG_Left and self.WidgetSwitcher_TeamResult then
    if 0 == campId then
      self.WidgetSwitcher_TeamBG_Left:SetActiveWidgetIndex(bSelfTeam and 3 or 2)
      self.WidgetSwitcher_TeamResult:SetActiveWidgetIndex(data.winType)
      self.WidgetSwitcher_TeamResult:SetVisibility(UE4.ESlateVisibility.HitTestInvisible)
    elseif 1 == campId then
      self.WidgetSwitcher_TeamBG_Left:SetActiveWidgetIndex(0)
      self.WidgetSwitcher_TeamResult:SetVisibility(UE4.ESlateVisibility.Collapsed)
    elseif 2 == campId then
      self.WidgetSwitcher_TeamBG_Left:SetActiveWidgetIndex(1)
      self.WidgetSwitcher_TeamResult:SetVisibility(UE4.ESlateVisibility.Collapsed)
    end
  end
  if self.Text_TeamScore then
    self.Text_TeamScore:SetText(data.score)
  end
  if self.WidgetSwitcher_TeamBg_Top then
    local bUseBlueBG = 2 == campId or 0 == campId and data.bMyTeam
    self.WidgetSwitcher_TeamBg_Top:SetActiveWidgetIndex(bUseBlueBG and 1 or 0)
  end
  if self.BattleInfo_Title then
    if bSelfTeam and self.BattleTitle_Own then
      self.BattleInfo_Title:SetTitle(data.battleMode, self.BattleTitle_Own)
    end
    if not bSelfTeam and self.BattleTitle_Enemy then
      self.BattleInfo_Title:SetTitle(data.battleMode, self.BattleTitle_Enemy)
    end
    if self.WidgetSwitcher_ScoreTips then
      if data.battleMode == CareerEnumDefine.BattleMode.Bomb then
        self.WidgetSwitcher_ScoreTips:SetActiveWidgetIndex(0)
      end
      if data.battleMode == CareerEnumDefine.BattleMode.Team then
        self.WidgetSwitcher_ScoreTips:SetActiveWidgetIndex(1)
      end
    end
  end
  if self.playerDataPanels then
    local sortTeamInfo = function(t1, t2)
      if t1.scores and t2.scores and t1.scores ~= t2.scores then
        return t1.scores > t2.scores
      end
      if t1.kill_num and t2.kill_num and t1.kill_num ~= t2.kill_num then
        return t1.kill_num > t2.kill_num
      end
      if t1.dead_num and t2.dead_num and t1.dead_num ~= t2.dead_num then
        return t1.dead_num < t2.dead_num
      end
      if t1.assists_num and t2.assists_num and t1.assists_num ~= t2.assists_num then
        return t1.assists_num > t2.assists_num
      end
    end
    table.sort(data.teamInfo, function(a, b)
      return sortTeamInfo(a, b)
    end)
    for key, value in pairs(self.playerDataPanels) do
      if data.teamInfo[key] then
        value:SetInfoItemData(data.battleMode, data.myId, data.teamInfo[key], data.bIsRoom, data.drawMVPTeam)
        value:ShowInfo(true)
      else
        value:ShowInfo(false)
      end
    end
    local bDecreaseItem = false
    local platform = UE4.UPMLuaBridgeBlueprintLibrary.GetPlatform(LuaGetWorld())
    if platform == GlobalEnumDefine.EPlatformType.Mobile and data.battleMode == CareerEnumDefine.BattleMode.Team then
      bDecreaseItem = true
    end
    for key, value in pairs(self.playerDataPanels) do
      if key > 3 then
        value:SetVisibility(bDecreaseItem and UE4.ESlateVisibility.Collapsed or UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end
function BattleTeamInfo:Construct()
  BattleTeamInfo.super.Construct(self)
  if self.Button_Score then
    self.Button_Score.OnHovered:Add(self, self.OnHoverScore)
    self.Button_Score.OnUnhovered:Add(self, self.OnUnhoverScore)
  end
  if self.MenuAnchor_Score then
    self.MenuAnchor_Score.OnGetMenuContentEvent:Bind(self, self.InitScoreTip)
  end
  self.playerDataPanels = nil
  if self.VerticalBox_Team then
    local panels = self.VerticalBox_Team:GetAllChildren()
    if panels:Length() > 0 then
      self.playerDataPanels = {}
      for i = 1, panels:Length() do
        table.insert(self.playerDataPanels, panels:Get(i))
      end
    end
  end
end
function BattleTeamInfo:Destruct()
  if self.Button_Score then
    self.Button_Score.OnHovered:Remove(self, self.OnHoverScore)
    self.Button_Score.OnUnhovered:Remove(self, self.OnUnhoverScore)
  end
  if self.MenuAnchor_Score then
    self.MenuAnchor_Score.OnGetMenuContentEvent:Unbind()
  end
  BattleTeamInfo.super.Destruct(self)
end
function BattleTeamInfo:OnHoverScore()
  if self.MenuAnchor_Score then
    self.MenuAnchor_Score:Open(true)
  end
end
function BattleTeamInfo:OnUnhoverScore()
  if self.MenuAnchor_Score then
    self.MenuAnchor_Score:Close()
  end
end
function BattleTeamInfo:InitScoreTip()
  local scoreTipIns = UE4.UWidgetBlueprintLibrary.Create(self, self.MenuAnchor_Score.MenuClass)
  if scoreTipIns then
    local standingInfo = GameFacade:RetrieveProxy(ProxyNames.BattleRecordDataProxy):GetRoomStanding()
    if standingInfo and standingInfo.map_id then
      scoreTipIns:SetTipType(standingInfo.map_id)
    end
    return scoreTipIns
  end
  return nil
end
return BattleTeamInfo
