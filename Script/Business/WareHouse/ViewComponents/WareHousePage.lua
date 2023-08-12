local WareHousePage = class("WareHousePage", PureMVC.ViewComponentPage)
local WareHouseMediator = require("Business/WareHouse/Mediators/WareHouseMediator")
local Collapsed = UE.ESlateVisibility.Collapsed
local Visible = UE.ESlateVisibility.Visible
local SelfHitTestInvisible = UE.ESlateVisibility.SelfHitTestInvisible
local Valid
function WareHousePage:UpdateGridPanel(GridData)
  if not self.GridPanel then
    return
  end
  if nil == GridData or 0 == table.count(GridData) then
    self:SetEmptyItem(true)
  else
    self:SetEmptyItem(false)
  end
  self.GridPanel:UpdatePanel(GridData)
  if self.GridPanel:GetSingleItemByItemID(self.SelectedItem) then
    self.GridPanel:SetDefaultSelectItemByItemID(self.SelectedItem)
  else
    self.GridPanel:SetDefaultSelectItem(1)
  end
end
function WareHousePage:UpdateDescPanel(DescData)
  Valid = self.DescPanel and self.DescPanel:SetVisibility(Collapsed)
  Valid = self.ButtonUse and self.ButtonUse:SetVisibility(Collapsed)
  Valid = self.ButtonJump and self.ButtonJump:SetVisibility(Collapsed)
  Valid = self.ButtonSell and self.ButtonSell:SetVisibility(Collapsed)
  if DescData and table.count(DescData) > 0 then
    Valid = self.DescPanel and self.DescPanel:UpdatePanel(DescData)
    if self.UI3DModel:DisplayByItemId(tonumber(DescData.itemId), UE4.ELobbyCharacterAnimationStateMachineType.None) then
      Valid = self.Img_BigBackground and self.Img_BigBackground:SetVisibility(Collapsed)
      GameFacade:SendNotification(NotificationDefines.ItemImageDisplay)
    else
      Valid = self.Img_BigBackground and self.Img_BigBackground:SetVisibility(Visible)
      GameFacade:SendNotification(NotificationDefines.ItemImageDisplay, DescData.itemId)
    end
    Valid = self.DescPanel and self.DescPanel:SetVisibility(Visible)
    self.ItemType = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetItemIdIntervalType(DescData.itemId)
    if self.ItemType == UE4.EItemIdIntervalType.BagItem_RoleFavorabilityGift or self.ItemType == UE4.EItemIdIntervalType.BagItem_LotteryTicket then
      Valid = self.ButtonJump and self.ButtonJump:SetVisibility(Visible)
    else
      Valid = self.ButtonUse and self.ButtonUse:SetVisibility(Visible)
      Valid = self.ButtonSell and self.ButtonSell:SetVisibility(DescData.saleType and DescData.saleType > 0 and Visible or Collapsed)
    end
  end
end
function WareHousePage:OnResCloseOperate()
  if self.GridPanel:GetSelectItemID() == nil then
    self.DescPanel:SetVisibility(Collapsed)
    self.ButtonUse:SetVisibility(Collapsed)
    self.ButtonSell:SetVisibility(Collapsed)
    self.ButtonJump:SetVisibility(Collapsed)
  end
  if self.GridPanel:GetSingleItemByItemID(self.SelectedItem) then
    self.GridPanel:SetDefaultSelectItemByItemID(self.SelectedItem)
  else
    self.GridPanel:SetDefaultSelectItem(1)
  end
end
function WareHousePage:ListNeededMediators()
  return {WareHouseMediator}
end
function WareHousePage:OnOpen(luaOpenData, nativeOpenData)
  self:BindEvent()
  Valid = self.DescPanel and self.DescPanel:SetVisibility(Collapsed)
  Valid = self.ButtonUse and self.ButtonUse:SetVisibility(Collapsed)
  Valid = self.ButtonJump and self.ButtonJump:SetVisibility(Collapsed)
  Valid = self.ButtonSell and self.ButtonSell:SetVisibility(Collapsed)
  Valid = self.GridPanel and self.GridPanel:SetDefaultSelectItem(1)
  Valid = self.EnterInto and self:PlayAnimationForward(self.EnterInto, 1, false)
  Valid = self.HotKeyButton_Esc and self.HotKeyButton_Esc.OnClickEvent:Add(self, self.OnEscHotKeyClick)
  Valid = self.bHideChat and GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Hide)
end
function WareHousePage:OnClose()
  Valid = self.HotKeyButton_Esc and self.HotKeyButton_Esc.OnClickEvent:Remove(self, self.OnEscHotKeyClick)
  Valid = ViewMgr and ViewMgr:ClosePage(self, UIPageNameDefine.WareHouseOperatePage)
  Valid = self.bHideChat and GameFacade:SendNotification(NotificationDefines.SetChatState, nil, NotificationDefines.ChatState.Show)
  self:RemoveEvent()
end
function WareHousePage:BindEvent()
  Valid = self.GridPanel and self.GridPanel.clickItemEvent:Add(self.ClickItem, self)
  Valid = self.ButtonUse and self.ButtonUse.OnClickEvent:Add(self, self.ClickUseButton)
  Valid = self.ButtonJump and self.ButtonJump.OnClickEvent:Add(self, self.ClickJumpButton)
  Valid = self.ButtonSell and self.ButtonSell.OnClickEvent:Add(self, self.ClickSellButton)
end
function WareHousePage:RemoveEvent()
  Valid = self.GridPanel and self.GridPanel.clickItemEvent:Remove(self.ClickItem, self)
  Valid = self.ButtonUse and self.ButtonUse.OnClickEvent:Remove(self, self.ClickUseButton)
  Valid = self.ButtonJump and self.ButtonJump.OnClickEvent:Remove(self, self.ClickJumpButton)
  Valid = self.ButtonSell and self.ButtonSell.OnClickEvent:Remove(self, self.ClickSellButton)
end
function WareHousePage:SetEmptyItem(IsEmpty)
  Valid = self.Switcher and self.Switcher:SetActiveWidgetIndex(IsEmpty and 1 or 0)
  Valid = IsEmpty and self.Tip_pop and self:PlayAnimation(self.Tip_pop, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
end
function WareHousePage:ClickItem(itemUUID)
  GameFacade:SendNotification(NotificationDefines.UpdateWareHouseDescPanel, itemUUID)
  self.SelectedItem = itemUUID
  local redDotId = self.GridPanel and self.GridPanel:GetSelectItemRedDotID()
  if redDotId and 0 ~= redDotId then
    GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):ReadRedDot(redDotId)
    Valid = self.GridPanel and self.GridPanel:SetSelectItemRedDotID(0)
    if GameFacade:RetrieveProxy(ProxyNames.RedDotProxy):GetRedDotPass(redDotId) then
      RedDotTree:ChangeRedDotCnt(RedDotModuleDef.ModuleName.CareerWarehouse, -1)
    end
  end
  GameFacade:RetrieveProxy(ProxyNames.ApartmentGiftProxy):UpdateGiftRedDot()
end
function WareHousePage:ClickUseButton()
  local body = {
    ItemUUId = self.SelectedItem,
    IsUseButton = true
  }
  Valid = ViewMgr and ViewMgr:OpenPage(self, UIPageNameDefine.WareHouseOperatePage, nil, body)
end
function WareHousePage:ClickJumpButton()
  if self.ItemType == UE4.EItemIdIntervalType.BagItem_RoleFavorabilityGift then
    local EnumClickButton = {
      Promise = 0,
      Information = 1,
      Memory = 2,
      Gift = 3
    }
    local NavBarBodyTable = {
      pageType = UE4.EPMFunctionTypes.Apartment,
      exData = {
        EnumClickButton = EnumClickButton.Gift
      }
    }
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, NavBarBodyTable)
  elseif self.ItemType == UE4.EItemIdIntervalType.BagItem_LotteryTicket then
    local NavBarBodyTable = {
      pageType = UE4.EPMFunctionTypes.Shop,
      secondIndex = 3
    }
    GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage, NavBarBodyTable)
  end
end
function WareHousePage:ClickSellButton()
  local body = {
    ItemUUId = self.SelectedItem,
    IsUseButton = false
  }
  Valid = ViewMgr and ViewMgr:OpenPage(self, UIPageNameDefine.WareHouseOperatePage, nil, body)
end
function WareHousePage:OnEscHotKeyClick()
  LogInfo("WareHousePage", "OnEscHotKeyClick")
  GameFacade:SendNotification(NotificationDefines.NavigationBar.SwitchDisplayPage)
end
return WareHousePage
