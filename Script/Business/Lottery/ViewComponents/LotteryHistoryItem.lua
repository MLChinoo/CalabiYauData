local LotteryHistoryItem = class("LotteryHistoryItem", PureMVC.ViewComponentPanel)
function LotteryHistoryItem:ListNeededMediators()
  return {}
end
function LotteryHistoryItem:UpdateView(lotteryItemtemInfo, lotteryId)
  local itemId = lotteryItemtemInfo.item_id
  local itemProxy = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy)
  if self.Text_Type then
    local itemTypeInterval = itemProxy:GetItemIdInterval(itemId)
    self.Text_Type:SetText(nil ~= itemTypeInterval and itemTypeInterval.ItemTypeName or "")
  end
  if self.Text_Name then
    self.Text_Name:SetText(itemProxy:GetAnyItemName(itemId))
    local itemQuality = itemProxy:GetAnyItemQuality(itemId)
    if self.ItemQualityColor and itemQuality then
      local colorTable = self.ItemQualityColor:ToTable()
      if colorTable[itemQuality] then
        self.Text_Name:SetColorAndOpacity(colorTable[itemQuality])
      end
    end
  end
  if self.Text_Owner then
    self.Text_Owner:SetText(itemProxy:GetAnyItemInfoById(itemId).roleName or "")
  end
  if self.Text_Time then
    local timeText = os.date("%Y-%m-%d   %H:%M:%S", lotteryItemtemInfo.his_time)
    self.Text_Time:SetText(timeText)
  end
  if self.Text_Lottery then
    if nil == lotteryId then
      lotteryId = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotterySelected()
    end
    local lotteryCfg = GameFacade:RetrieveProxy(ProxyNames.LotteryProxy):GetLotteryCfg(lotteryId)
    if lotteryCfg then
      self.Text_Lottery:SetText(lotteryCfg.Name)
    else
      self.Text_Lottery:SetText("")
    end
  end
end
return LotteryHistoryItem
