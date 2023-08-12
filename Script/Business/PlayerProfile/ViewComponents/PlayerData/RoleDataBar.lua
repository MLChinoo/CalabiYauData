local RoleDataBar = class("RoleDataBar", PureMVC.ViewComponentPanel)
function RoleDataBar:ListNeededMediators()
  return {}
end
function RoleDataBar:UpdateView(totalMatchNum, matchInfo)
  if matchInfo.roleSkinConfig and self.Image_Avatar then
    self:SetImageByTexture2D(self.Image_Avatar, matchInfo.roleSkinConfig.IconRoleScoreboard)
  end
  if matchInfo.roleConfig then
    if self.TextBlock_RoleName then
      self.TextBlock_RoleName:SetText(matchInfo.roleConfig.NameCn)
    end
    if self.ProgressBar_GameCount then
      self.ProgressBar_GameCount:SetPercent(matchInfo.matchCount.count / totalMatchNum)
    end
    if self.TextBlock_GameCount then
      local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_PlayerProfile, "RoleGameCount")
      local stringMap = {
        [0] = matchInfo.matchCount.count
      }
      local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
      self.TextBlock_GameCount:SetText(text)
    end
    if self.TextBlock_WinRate then
      local winRate = matchInfo.matchCount.winCount / matchInfo.matchCount.count
      self.TextBlock_WinRate:SetText(string.format("%.2f%%", winRate * 100))
    end
    if self.TextBlock_Favor then
      local roleApartmentInfo = GameFacade:RetrieveProxy(ProxyNames.KaPhoneProxy):GetRoleProperties(matchInfo.roleConfig.RoleId)
      if roleApartmentInfo then
        self.TextBlock_Favor:SetText(roleApartmentInfo.intimacy_lv)
      end
    end
  end
end
return RoleDataBar
