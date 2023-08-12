local HermesHotListPageMB = class("HermesHotListPage", PureMVC.ViewComponentPage)
local HermesHotListMediator = require("Business/Hermes/Mediators/HotList/HotListMediator")
local Collapsed = UE4.ESlateVisibility.Collapsed
local Visible = UE4.ESlateVisibility.Visible
local SelfHitTestInvisible = UE4.ESlateVisibility.SelfHitTestInvisible
local Valid
function HermesHotListPageMB:Update(Data)
end
function HermesHotListPageMB:ListNeededMediators()
  return {HermesHotListMediator}
end
function HermesHotListPageMB:OnOpen(luaOpenData, nativeOpenData)
  Valid = self.CloseAnim and self:PlayAnimation(self.CloseAnim, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function HermesHotListPageMB:OnClose()
end
return HermesHotListPageMB
