local ShowCreditScoreTipCmd = class("ShowCreditScoreTipCmd", PureMVC.Command)
local FTextPolarisGroupID = {
  [1] = "CreditScoreTip_Chat",
  [2] = "CreditScoreTip_Team",
  [3] = "CreditScoreTip_Rank",
  [4] = "CreditScoreTip_Friend",
  [5] = "CreditScoreTip_Register",
  [6] = "CreditScoreTip_Login",
  [7] = "CreditScoreTip_Match"
}
function ShowCreditScoreTipCmd:Execute(notification)
  local Body = notification:GetBody()
  if Body then
    local formatText = ConfigMgr:FromStringTable(StringTablePath.ST_Common, FTextPolarisGroupID[Body.group_id])
    local Score = 350
    if 6 == Body.group_id then
      Score = Body.limit_score
    end
    local stringMap = {
      [0] = Score
    }
    local text = ObjectUtil:GetTextFromFormat(formatText, stringMap)
    local pageData = {contentText = text}
    ViewMgr:OpenPage(LuaGetWorld(), UIPageNameDefine.CreditScoreDialogPage, nil, pageData)
  end
end
return ShowCreditScoreTipCmd
