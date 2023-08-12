local ResultVictoryDefeatTitlePanel_PC = class("ResultVictoryDefeatTitlePanel_PC", PureMVC.ViewComponentPanel)
local BattleResultDefine = require("Business/BattleResult/Proxies/BattleResultDefine")
function ResultVictoryDefeatTitlePanel_PC:Construct()
  ResultVictoryDefeatTitlePanel_PC.super.Construct(self)
  self:UpdateUI(BattleResultDefine.PanelType.Account)
end
function ResultVictoryDefeatTitlePanel_PC:UpdateUI(PanelType)
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local MyPlayerInfo = BattleResultProxy:GetMyPlayerInfo()
  if BattleResultProxy:IsDraw() then
    self.Title:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Draw"))
  elseif BattleResultProxy:IsWinnerTeam(MyPlayerInfo.team_id) then
    self.Title:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Victory"))
  else
    self.Title:SetText(ConfigMgr:FromStringTable(StringTablePath.ST_InGame, "Defeat"))
  end
  local QRCodeSpriteAsset = {
    [BattleResultDefine.PanelType.Account] = self.QRCodeSpriteAssetAccout,
    [BattleResultDefine.PanelType.BattlePass] = self.QRCodeSpriteAssetBattlePass,
    [BattleResultDefine.PanelType.KDA] = self.QRCodeSpriteAssetKDA
  }
  self.QRCode.Brush.ResourceObject = QRCodeSpriteAsset[PanelType]
end
return ResultVictoryDefeatTitlePanel_PC
