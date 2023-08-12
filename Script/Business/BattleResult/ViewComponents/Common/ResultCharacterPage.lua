local ResultCharacterPage = class("ResultCharacterPage", PureMVC.ViewComponentPage)
local GamePlayGlobal = require("Business/Common/ViewComponents/GamePlay/GamePlayGlobal")
function ResultCharacterPage:OnOpen(luaOpenData, nativeOpenData)
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
  local LastRoleSkinId = BattleResultProxy:GetLastRoleSkinId()
  local LastWeaponSkinId = BattleResultProxy:GetLastWeaponSkinId()
  local roleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local RoleSkinRow = roleProxy:GetRoleSkin(LastRoleSkinId)
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  if RoleSkinRow and MyPlayerInfo then
    local SequenceId = 0
    if SettleBattleGameData.winner_team_id == MyPlayerInfo.team_id then
      SequenceId = MyPlayerInfo.mvp and RoleSkinRow.MvpSequence or RoleSkinRow.WinSequence
    else
      SequenceId = RoleSkinRow.LoseSequence
    end
    ViewMgr:OpenPage(self, UIPageNameDefine.ResultMvpPage)
    self:PlayCharacterSequence(LastRoleSkinId, LastWeaponSkinId, SequenceId)
  else
    ViewMgr:OpenPage(self, UIPageNameDefine.ResultMvpPage)
    local GameState, MyPlayerController, MyPlayerState = GamePlayGlobal:GetGSAndFirstPCAndFirstPS(self)
    if not MyPlayerController then
      return
    end
    MyPlayerController:OnMatchEndLSFinished()
  end
end
return ResultCharacterPage
