local MichellePlaytimeRewardChestItemPanel = class("MichellePlaytimeRewardChestItemPanel", PureMVC.ViewComponentPage)
function MichellePlaytimeRewardChestItemPanel:ListNeededMediators()
  return {}
end
function MichellePlaytimeRewardChestItemPanel:Construct()
  MichellePlaytimeRewardChestItemPanel.super.Construct(self)
  self.Btn_RewardPreview.OnClicked:Add(self, self.OnClickRewardPreview)
end
function MichellePlaytimeRewardChestItemPanel:Destruct()
  MichellePlaytimeRewardChestItemPanel.super.Destruct(self)
  self.Btn_RewardPreview.OnClicked:Remove(self, self.OnClickRewardPreview)
end
function MichellePlaytimeRewardChestItemPanel:OnListItemObjectSet(listItemObject)
  self.itemId = listItemObject.itemId
  self.itemCnt = listItemObject.itemCnt
  local ItemsProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  local itemImg = ItemsProxy:GetAnyItemImg(self.itemId)
  self:SetImageByTexture2D(self.Img_ItemIcon, itemImg)
  self.Txt_ItemNum:SetText(self.itemCnt)
end
function MichellePlaytimeRewardChestItemPanel:OnClickRewardPreview()
  ViewMgr:OpenPage(self, UIPageNameDefine.SpaceTimeCardDetailPage, false, {
    itemId = self.itemId
  })
end
return MichellePlaytimeRewardChestItemPanel
