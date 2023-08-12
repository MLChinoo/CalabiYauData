local SummerThemeSongDeliverRewardItemPanel = class("SummerThemeSongDeliverRewardItemPanel", PureMVC.ViewComponentPage)
function SummerThemeSongDeliverRewardItemPanel:ListNeededMediators()
  return {}
end
function SummerThemeSongDeliverRewardItemPanel:Construct()
  SummerThemeSongDeliverRewardItemPanel.super.Construct(self)
end
function SummerThemeSongDeliverRewardItemPanel:Destruct()
  SummerThemeSongDeliverRewardItemPanel.super.Destruct(self)
end
function SummerThemeSongDeliverRewardItemPanel:InitRewardItem(itemId, itemNum)
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local imageItem = ItemsProxy:GetAnyItemImg(itemId)
  if self.Img_RewardIcon and imageItem then
    self:SetImageByTexture2D(self.Img_RewardIcon, imageItem)
  end
  self.Txt_RewardNum:SetText(itemNum)
end
return SummerThemeSongDeliverRewardItemPanel
