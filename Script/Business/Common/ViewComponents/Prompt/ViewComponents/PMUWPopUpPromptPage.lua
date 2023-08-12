local PMUWPopUpPromptPage = class("PMUWPopUpPromptPage", PureMVC.ViewComponentPage)
local PromptPopUpMediator = require("Business/Common/Mediators/PromptPopUp/PromptPopUpMediator")
local MaxCacheNum = 3
local PoolCacheNum = MaxCacheNum + 1
local SuvialTime = 1.2
local DistInterval = 90
function PMUWPopUpPromptPage:OnInitialized()
  PMUWPopUpPromptPage.super.OnInitialized(self)
  self.cacheMsg = {}
  self:CreateCachePool()
end
function PMUWPopUpPromptPage:ListNeededMediators()
  return {PromptPopUpMediator}
end
function PMUWPopUpPromptPage:OnOpen(luaOpenData, nativeOpenData)
  LogInfo("PMUWPopUpPromptPage", "Open PMUWPopUpPromptPage")
  local PopUpPromptProxy = GameFacade:RetrieveProxy(ProxyNames.PopUpPromptProxy)
  PopUpPromptProxy:SetPrompUIExistFlag(true)
  self:ShowMsg(luaOpenData.realMsg, luaOpenData.oriData)
end
function PMUWPopUpPromptPage:PushMsgData(msgDt)
  self.cacheMsg[#self.cacheMsg + 1] = msgDt
end
function PMUWPopUpPromptPage:PopMsgData()
  return table.remove(self.cacheMsg, 1)
end
function PMUWPopUpPromptPage:CheckHasMsg()
  return #self.cacheMsg > 0
end
local createMsgDt = function(msg, bPositive)
  return {message = msg, bPositive = bPositive}
end
function PMUWPopUpPromptPage:ShowMsg(msg, oriData)
  local bPositive = true
  if type(oriData) == "number" and 0 ~= oriData then
    bPositive = false
  end
  local dt = createMsgDt(msg, bPositive)
  self:PushMsgData(dt)
  self:CreatePopTimer()
end
function PMUWPopUpPromptPage:AddNewItem()
  local msgDt = self:PopMsgData()
  local FreeWidgetDt = self:GetFreeWidgetDt()
  local item = FreeWidgetDt.widget
  local slot = FreeWidgetDt.slot
  item:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  item:InitView({
    msg = msgDt.message
  })
  local dist = DistInterval
  local y = 0
  if #self.children > 0 then
    y = self.children[#self.children].widget.Slot:GetPosition().Y + dist
  end
  slot:SetPosition(UE4.FVector2D(0, y))
  self.children[#self.children + 1] = {
    widget = item,
    time = 0,
    showAni = false
  }
  item:SetRenderOpacity(0)
  if msgDt.bPositive then
    self:K2_PostAkEvent(self.PositiveAudio)
  else
    self:K2_PostAkEvent(self.NegativeAudio)
  end
end
function PMUWPopUpPromptPage:GetIntervalDist()
  return #self.children * DistInterval
end
function PMUWPopUpPromptPage:CreatePopTimer()
  if self.animOpenPageTask == nil then
    self.children = {}
    self:AddNewItem()
    local dist = 15
    local intervalTime = 0.01
    self.animOpenPageTask = TimerMgr:AddTimeTask(0, intervalTime, 0, function()
      if self:CheckHasMsg() or self.children[1] and self.children[1].widget.Slot:GetPosition().Y > -self:GetIntervalDist() then
        for i, v in ipairs(self.children) do
          local y = v.widget.Slot:GetPosition().Y
          v.widget.Slot:SetPosition(UE4.FVector2D(0, y - dist))
        end
      end
      for i, v in ipairs(self.children) do
        v.time = v.time + intervalTime
      end
      for i, v in ipairs(self.children) do
        local x = v.time
        local opa
        if v.time < SuvialTime / 3 then
          if v.showAni == false then
            v.showAni = true
            v.widget:PlayShowAni()
          end
          opa = 1
        elseif v.time < SuvialTime * 2 / 3 then
          opa = 1
        else
          opa = (SuvialTime - v.time) / (SuvialTime / 3)
        end
        v.widget:SetRenderOpacity(opa)
      end
      if self.children[1] and self.children[1].widget.Slot:GetPosition().Y <= -self:GetIntervalDist() and self:CheckHasMsg() then
        self:AddNewItem()
      end
      if #self.children > MaxCacheNum or self.children[1] and self.children[1].time > SuvialTime then
        self.children[1].widget:SetVisibility(UE4.ESlateVisibility.Collapsed)
        table.remove(self.children, 1)
      end
      if 0 == #self.children then
        self:DestoryPopTimer()
      end
    end)
  end
end
function PMUWPopUpPromptPage:DestoryPopTimer()
  if self.animOpenPageTask then
    self.animOpenPageTask:EndTask()
    self.animOpenPageTask = nil
  end
end
function PMUWPopUpPromptPage:CreateCachePool()
  self.pool = {}
  local itemClass = ObjectUtil:LoadClass(self.itemClass)
  for i = 1, PoolCacheNum do
    local item = UE4.UWidgetBlueprintLibrary.Create(self, itemClass)
    local slot = self.CanvasPanel_Center:AddChild(item)
    item:SetRenderOpacity(0)
    item:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.pool[#self.pool + 1] = {widget = item, slot = slot}
  end
end
function PMUWPopUpPromptPage:GetFreeWidgetDt()
  if self.freeIndex == nil then
    self.freeIndex = 1
  else
    self.freeIndex = (self.freeIndex + 1) % PoolCacheNum
    if 0 == self.freeIndex then
      self.freeIndex = PoolCacheNum
    end
  end
  return self.pool[self.freeIndex]
end
function PMUWPopUpPromptPage:OnClose()
  LogInfo("PMUWPopUpPromptPage", "OnClose PMUWPopUpPromptPage")
  local PopUpPromptProxy = GameFacade:RetrieveProxy(ProxyNames.PopUpPromptProxy)
  PopUpPromptProxy:SetPrompUIExistFlag(false)
  self:DestoryPopTimer()
end
return PMUWPopUpPromptPage
