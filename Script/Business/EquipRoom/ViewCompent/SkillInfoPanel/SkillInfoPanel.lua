local SkillInfoPanel = class("SkillInfoPanel", PureMVC.ViewComponentPanel)
function SkillInfoPanel:OnInitialized()
  SkillInfoPanel.super.OnInitialized(self)
  self.skillItemsMap = {}
  self.skillItemsMap[GlobalEnumDefine.ERoleSkillType.Active] = self.SkillActiveItem
  self.skillItemsMap[GlobalEnumDefine.ERoleSkillType.Passive] = self.SkillPassiveItem
  self.skillItemsMap[GlobalEnumDefine.ERoleSkillType.Unique] = self.SkillUltimateItem
  for index, value in ipairs(self.skillItemsMap) do
    if value then
      value.onHoveredEvent:Add(self.OnSkillHovered, self)
    end
  end
end
function SkillInfoPanel:UpdatePanel(skillInfo)
  for index, value in ipairs(skillInfo) do
    local item = self.skillItemsMap[index]
    if item then
      item:SetSkillIcon(value.skillTexture)
      item:SetSkillType(index)
    end
  end
  self.skillInfo = skillInfo
  self.skillItemsMap[GlobalEnumDefine.ERoleSkillType.Active]:SetSelfBeHovered()
end
function SkillInfoPanel:OnSkillHovered(item)
  if self.lastItem then
    self.lastItem:SetHoveredState(false)
  end
  item:SetHoveredState(true)
  self.lastItem = item
  local info = self.skillInfo[item:GetSkillType()]
  if self.Txt_ModuleName then
    self.Txt_ModuleName:SetText(info.skillTypeName)
  end
  if self.Txt_SkillName then
    self.Txt_SkillName:SetText(info.skillName)
  end
  if self.Txt_SkillKeyName then
    self.Txt_SkillKeyName:SetText(info.keyName)
  end
  if self.Txt_SkillInfo then
    self.Txt_SkillInfo:SetText(info.skillDesc)
  end
end
function SkillInfoPanel:SetSkillKeyName(skilType, keyName)
  local info = self.skillInfo[skilType]
  if info then
    info.keyName = keyName
  end
end
function SkillInfoPanel:UpdateCurrentSkillKeyName()
  local info = self.skillInfo[self.lastItem:GetSkillType()]
  if info and self.Txt_SkillKeyName then
    self.Txt_SkillKeyName:SetText(info.keyName)
  end
end
return SkillInfoPanel
