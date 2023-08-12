local RoleAchvsSlot = class("RoleAchvsSlot", PureMVC.ViewComponentPanel)
local CareerEnumDefine = require("Business/Career/Proxies/CareerEnumDefine")
function RoleAchvsSlot:InitializeLuaEvent()
end
function RoleAchvsSlot:Construct()
  self.super.Construct(self)
  self.MaxSlot = 2
  self.PosState = {}
end
function RoleAchvsSlot:Destruct()
  self.super.Destruct(self)
end
function RoleAchvsSlot:UpdateSlot(idx, roleAchvInfo)
  self.SlotIdx = idx
  self.roleAchvInfoGroup = roleAchvInfo or {}
  for i = 1, self.MaxSlot do
    self.PosState[i] = false
    local roleAchvItem = self[string.format("RoleAchvItem%d", i)]
    local ImgEmpty = self[string.format("ImgEmpty%d", i)]
    local roleAchvInfo = self.roleAchvInfoGroup[i]
    if roleAchvInfo then
      self.PosState[i] = true
      roleAchvItem:InitNormalItem(self.SlotIdx, i, roleAchvInfo)
      roleAchvItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      ImgEmpty:SetVisibility(UE4.ESlateVisibility.Collapsed)
      roleAchvItem.CanvasPanel_Click:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      roleAchvItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
      ImgEmpty:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function RoleAchvsSlot:PlayerEnterAnim()
  self.RoleAchvItem1.CanvasPanel_Click:SetVisibility(UE4.ESlateVisibility.Visible)
  if 1 == self.SlotIdx then
    self.RoleAchvItem1:OnLuaItemClick()
  end
  self.RoleAchvItem1:PlayAnimation(self.RoleAchvItem1.Anim_In, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  if self.roleAchvInfoGroup[2] then
    TimerMgr:AddTimeTask(0.1, 0.1, 1, function()
      self.RoleAchvItem2.CanvasPanel_Click:SetVisibility(UE4.ESlateVisibility.Visible)
      self.RoleAchvItem2:PlayAnimation(self.RoleAchvItem2.Anim_In, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
    end)
  end
end
function RoleAchvsSlot:UpdateClickState(slotIdx, achvIdx)
  for i = 1, self.MaxSlot do
    if self.PosState[i] then
      local roleAchvItem = self[string.format("RoleAchvItem%d", i)]
      if self.SlotIdx ~= slotIdx or roleAchvItem.ItemIdx ~= achvIdx then
        roleAchvItem:SetUnchosen()
      end
    end
  end
end
return RoleAchvsSlot
