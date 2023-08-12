local AiLevelPanel = class("AiLevelPanel", PureMVC.ViewComponentPanel)
local RoomEnum = require("Business/Lobby/Mediators/RoomEnum")
local RoomProxy
function AiLevelPanel:Construct()
  AiLevelPanel.super.Construct(self)
  self:PlayAnimation(self.Opening, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  self.Btn_AiLevel_Simple.OnClicked:Add(self, self.OnClickBtnAiLevelSimple)
  self.Btn_AiLevel_Normal.OnClicked:Add(self, self.OnClickBtnAiLevelNormal)
  self.Btn_AiLevel_Difficult.OnClicked:Add(self, self.OnClickBtnAiLevelDifficult)
  RoomProxy = GameFacade:RetrieveProxy(ProxyNames.RoomProxy)
  local arrRows = ConfigMgr:GetCyDivisionRoomAITableRow()
  if arrRows then
    self.aiLevelTable = arrRows:ToLuaTable()
  end
  self:LoadAiLevelName()
  local currentSelectLevel = RoomProxy:GetCurrentAiLevel()
  if not currentSelectLevel then
    self:InitDefaultSelectAiLevel()
  else
    self:SelectAiLevelBtn(currentSelectLevel)
  end
end
function AiLevelPanel:Destruct()
  AiLevelPanel.super.Destruct(self)
  self.Btn_AiLevel_Simple.OnClicked:Remove(self, self.OnClickBtnAiLevelSimple)
  self.Btn_AiLevel_Normal.OnClicked:Remove(self, self.OnClickBtnAiLevelNormal)
  self.Btn_AiLevel_Difficult.OnClicked:Remove(self, self.OnClickBtnAiLevelDifficult)
end
function AiLevelPanel:LoadAiLevelName()
  if self.aiLevelTable then
    for key, value in pairs(self.aiLevelTable) do
      if value and value.Id and value.Name then
        self:SetAiLevelName(value.Id, value.Name)
      end
    end
  end
end
function AiLevelPanel:SetAiLevelName(aiLevelId, aiLevelName)
  if aiLevelId == RoomEnum.AiLevelEnum.Simple then
    self.Text_Simple:SetText(aiLevelName)
  elseif aiLevelId == RoomEnum.AiLevelEnum.Normal then
    self.Text_Normal:SetText(aiLevelName)
  elseif aiLevelId == RoomEnum.AiLevelEnum.Difficult then
    self.Text_Difficult:SetText(aiLevelName)
  end
end
function AiLevelPanel:InitDefaultSelectAiLevel()
  if self.aiLevelTable then
    for key, value in pairs(self.aiLevelTable) do
      if value and value.Id and 1 == value.Id then
        self:SelectAiLevelBtn(value.Id)
        return
      end
    end
  end
end
function AiLevelPanel:SelectAiLevelBtn(selectLevel)
  if self.currentSelectLevel == selectLevel then
    return
  end
  self:CancelSelectedAiLevelBtn()
  self.currentSelectLevel = selectLevel
  RoomProxy:ReqTeamRobotSet(selectLevel)
  if selectLevel == RoomEnum.AiLevelEnum.Simple then
    self.Btn_AiLevel_Simple:SetStyle(self.bp_selectedBrush)
    self.Text_Simple:SetColorAndOpacity(self.bp_btnHoverTextColor)
  elseif selectLevel == RoomEnum.AiLevelEnum.Normal then
    self.Btn_AiLevel_Normal:SetStyle(self.bp_selectedBrush)
    self.Text_Normal:SetColorAndOpacity(self.bp_btnHoverTextColor)
  elseif selectLevel == RoomEnum.AiLevelEnum.Difficult then
    self.Btn_AiLevel_Difficult:SetStyle(self.bp_selectedBrush)
    self.Text_Difficult:SetColorAndOpacity(self.bp_btnHoverTextColor)
  end
end
function AiLevelPanel:CancelSelectedAiLevelBtn()
  local selectLevel = self.currentSelectLevel
  if selectLevel == RoomEnum.AiLevelEnum.Simple then
    self.Btn_AiLevel_Simple:SetStyle(self.bp_unSelectedBrush)
    self.Text_Simple:SetColorAndOpacity(self.bp_btnUnhoverTextColor)
  elseif selectLevel == RoomEnum.AiLevelEnum.Normal then
    self.Btn_AiLevel_Normal:SetStyle(self.bp_unSelectedBrush)
    self.Text_Normal:SetColorAndOpacity(self.bp_btnUnhoverTextColor)
  elseif selectLevel == RoomEnum.AiLevelEnum.Difficult then
    self.Btn_AiLevel_Difficult:SetStyle(self.bp_unSelectedBrush)
    self.Text_Difficult:SetColorAndOpacity(self.bp_btnUnhoverTextColor)
  end
end
function AiLevelPanel:OnClickBtnAiLevelSimple()
  self:SelectAiLevelBtn(RoomEnum.AiLevelEnum.Simple)
end
function AiLevelPanel:OnClickBtnAiLevelNormal()
  self:SelectAiLevelBtn(RoomEnum.AiLevelEnum.Normal)
end
function AiLevelPanel:OnClickBtnAiLevelDifficult()
  self:SelectAiLevelBtn(RoomEnum.AiLevelEnum.Difficult)
end
return AiLevelPanel
