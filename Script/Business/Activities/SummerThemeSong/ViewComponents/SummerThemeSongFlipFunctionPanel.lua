local SummerThemeSongFlipFunctionPanel = class("SummerThemeSongFlipFunctionPanel", PureMVC.ViewComponentPage)
local SummerThemeSongFlipFunctionPanelMediator = require("Business/Activities/SummerThemeSong/Mediators/SummerThemeSongFlipFunctionPanelMediator")
function SummerThemeSongFlipFunctionPanel:ListNeededMediators()
  return {SummerThemeSongFlipFunctionPanelMediator}
end
function SummerThemeSongFlipFunctionPanel:Construct()
  SummerThemeSongFlipFunctionPanel.super.Construct(self)
  local SummerThemeSongProxy = GameFacade:RetrieveProxy(ProxyNames.SummerThemeSongProxy)
  SummerThemeSongProxy:ReqScGetData()
end
function SummerThemeSongFlipFunctionPanel:Destruct()
  SummerThemeSongFlipFunctionPanel.super.Destruct(self)
end
function SummerThemeSongFlipFunctionPanel:PlayRoundFinishedAnim(bFirst)
  if bFirst then
    self:PlayAnimation(self.RoundFinishedAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  else
    self:PlayAnimation(self.RoundFinishedTick, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
end
return SummerThemeSongFlipFunctionPanel
