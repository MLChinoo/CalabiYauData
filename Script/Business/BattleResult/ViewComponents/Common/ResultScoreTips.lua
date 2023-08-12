local ResultScoreTips = class("ResultScoreTips", PureMVC.ViewComponentPanel)
function ResultScoreTips:Construct()
  ResultScoreTips.super.Construct(self)
  local BattleResultProxy = GameFacade:RetrieveProxy(ProxyNames.BattleResultProxy)
  if not BattleResultProxy then
    return
  end
  local SettleBattleGameData = BattleResultProxy:GetSettleBattleGameData()
  if not SettleBattleGameData then
    return
  end
  self:SetTipType(SettleBattleGameData.map_id)
end
function ResultScoreTips:SetTipType(mapId)
  local mapProxy = GameFacade:RetrieveProxy(ProxyNames.MapProxy)
  if not mapProxy then
    return
  end
  local mapType = mapProxy:GetMapType(mapId)
  local tips = self.ScoreTipMap:Find(mapType)
  tips = tips or self.ScoreTipMap:Find(1)
  self.Txt_ScoreTips:SetText(tips)
end
return ResultScoreTips
