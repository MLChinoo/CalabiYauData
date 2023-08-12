local TacticWheelPage = class("TacticWheelPage", PureMVC.ViewComponentPage)
local TacticWheelMediator = require("Business/TacticWheel/Mediators/TacticWheelMediator")
local CurSelectindex = -1
local bCoolDown = true
local SelectPartTimes = UE.TArray(UE.float)
local TimerTask
function TacticWheelPage:ListNeededMediators()
  return {TacticWheelMediator}
end
function TacticWheelPage:InitializeLuaEvent()
  LogDebug("TacticWheelPage", "InitializeLuaEvent")
  TacticWheelPage.super.InitializeLuaEvent(self)
end
function TacticWheelPage:OnOpen(luaOpenData, nativeOpenData)
  LogDebug("TacticWheelPage", "OnOpen")
  TacticWheelPage.super.OnOpen(luaOpenData, nativeOpenData)
  local TacticWheelProxy = GameFacade:RetrieveProxy(ProxyNames.TacticWheelProxy)
  TacticWheelProxy:InitCommunicateInfoArray()
  self:UpdateWheel()
  TacticWheelProxy:SetNeedUpdate(false)
end
function TacticWheelPage:OnClose()
  SelectPartTimes:Clear()
  if TimerTask then
    TimerTask:EndTask()
    TimerTask = nil
  end
  TacticWheelPage.super.OnClose()
end
function TacticWheelPage:OnShow(luaOpenData, nativeOpenData)
  CurSelectindex = -1
  self:ResetMouse()
  local TacticWheelProxy = GameFacade:RetrieveProxy(ProxyNames.TacticWheelProxy)
  if TacticWheelProxy:IsNeedUpdate() then
    TacticWheelProxy:SetNeedUpdate(false)
    self:UpdateWheel()
  end
  self:UpdateRenderOpacity()
  self:ResetSelectImageItem()
  self:UpdateDescription()
end
function TacticWheelPage:LuaHandleKeyEvent(key, inputEvent)
  if inputEvent == UE4.EInputEvent.IE_Released then
    local inputSetting = UE4.UInputSettings.GetInputSettings()
    local arr = UE4.TArray(UE4.FInputActionKeyMapping)
    inputSetting:GetActionMappingByName("TacticalRoulette", arr)
    local keyNames = {}
    for i = 1, arr:Length() do
      local ele = arr:Get(i)
      if ele then
        table.insert(keyNames, UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key))
      end
    end
    local inputKeyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
    if "Escape" == inputKeyName or table.index(keyNames, inputKeyName) then
      self:PlaySelectPartItem()
      return true
    end
  end
  return false
end
function TacticWheelPage:OnMouseButtonUp(InGeometry, InMouseEvent)
  if UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(InMouseEvent).KeyName == "RightMouseButton" then
    CurSelectindex = -1
    ViewMgr:HidePage(self, UIPageNameDefine.TacticWheelPage)
  elseif UE4.UKismetInputLibrary.PointerEvent_GetEffectingButton(InMouseEvent).KeyName == "LeftMouseButton" then
    self:PlaySelectPartItem()
  end
  return UE4.UWidgetBlueprintLibrary.UnHandled()
end
function TacticWheelPage:OnMouseMove(Geometry, MouseEvent)
  local InGeometry = self.PCenter:GetCachedGeometry()
  local ScreenPos = UE4.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
  local LocalPos = UE4.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenPos)
  self:UpdateWheelSelect(LocalPos)
  return UE4.UWidgetBlueprintLibrary.UnHandled()
end
function TacticWheelPage:UpdateWheelSelect(LocalPos)
  local Distance = LocalPos:Size()
  local SelectIndex = -1
  if Distance > self.LimitDistance then
    local Angel = math.deg(math.atan(LocalPos.Y, LocalPos.X)) - 247.5
    while Angel < 0 do
      Angel = Angel + 360
    end
    SelectIndex = math.floor(Angel / (360 / self.CellNum))
  end
  if SelectIndex ~= CurSelectindex then
    CurSelectindex = SelectIndex
    self:UpdateSelect()
  end
end
function TacticWheelPage:UpdateWheel()
  local TextBlock_Items = self.Nodes:GetAllChildren()
  for i = 1, TextBlock_Items:Length() do
    self:UpdatePartItemIcon(i)
  end
  self:ResetSelectImageItem()
end
function TacticWheelPage:ResetSelectImageItem()
  local Items = self.PCenter:GetAllChildren()
  for i = 1, Items:Length() do
    local ImageItem = Items:Get(i)
    ImageItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end
function TacticWheelPage:UpdatePartItemIcon(Index)
  local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
  local MyPlayerState = LocalPlayerController and LocalPlayerController.PlayerState
  if not MyPlayerState then
    return
  end
  local TextBlock_Item = self.Nodes:GetChildAt(Index - 1)
  if not TextBlock_Item then
    return
  end
  TextBlock_Item:SetVisibility(UE4.ESlateVisibility.Collapsed)
  local TacticWheelProxy = GameFacade:RetrieveProxy(ProxyNames.TacticWheelProxy)
  local CommunicationInfo = TacticWheelProxy:GetCommunicateInfo(Index)
  if nil == CommunicationInfo then
    return
  end
  local Text
  if CommunicationInfo.communication_type == GlobalEnumDefine.ECommunicationType.RoleAction then
    local RoleAction = TacticWheelProxy:GetRoleActionRow(CommunicationInfo.id)
    Text = RoleAction.ActionName
    TextBlock_Item:SetText(Text)
    TextBlock_Item:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  elseif CommunicationInfo.communication_type == GlobalEnumDefine.ECommunicationType.RoleVoice then
    local RoleVoice = TacticWheelProxy:GetRoleVoiceRow(CommunicationInfo.id)
    Text = RoleVoice.VoiceName
    TextBlock_Item:SetText(Text)
    TextBlock_Item:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  if CurSelectindex >= 0 then
    self.Text_Select:SetText(Text)
  end
end
function TacticWheelPage:UpdateSelect()
  self:UpdateDescription()
  if CurSelectindex >= 0 then
    local Items = self.PCenter:GetAllChildren()
    for i = 1, Items:Length() do
      local ImageItem = Items:Get(i)
      if i == CurSelectindex + 1 then
        ImageItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      else
        ImageItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  else
    self:ResetSelectImageItem()
  end
end
function TacticWheelPage:UpdateDescription()
  self.WidgetSwitcher_SelectState:SetActiveWidgetIndex(0)
  if CurSelectindex < 0 then
    return
  end
  local TacticWheelProxy = GameFacade:RetrieveProxy(ProxyNames.TacticWheelProxy)
  local CommunicationInfo = TacticWheelProxy:GetCommunicateInfo(CurSelectindex + 1)
  if nil ~= CommunicationInfo and 0 ~= CommunicationInfo.id then
    if CommunicationInfo.communication_type == GlobalEnumDefine.ECommunicationType.RoleAction then
      local RoleAction = TacticWheelProxy:GetRoleActionRow(CommunicationInfo.id)
      self.Text_Select:SetText(RoleAction.ActionName)
    elseif CommunicationInfo.communication_type == GlobalEnumDefine.ECommunicationType.RoleVoice then
      local RoleVoice = TacticWheelProxy:GetRoleVoiceRow(CommunicationInfo.id)
      self.Text_Select:SetText(RoleVoice.VoiceName)
    end
    self.WidgetSwitcher_SelectState:SetActiveWidgetIndex(1)
    return
  end
end
function TacticWheelPage:UpdateRenderOpacity()
  if self.Root then
    if bCoolDown then
      self.Root:SetRenderOpacity(1.0)
    else
      self.Root:SetRenderOpacity(0.4)
    end
  end
end
function TacticWheelPage:UpdateSelectState()
  local CurTime = os.time()
  SelectPartTimes:Add(CurTime)
  if SelectPartTimes:Length() >= self.MaxActionNum then
    if SelectPartTimes:Get(self.MaxActionNum) - SelectPartTimes:Get(1) < self.TacticActionCD then
      self:MakeCoolDown()
      SelectPartTimes:Clear()
      return
    end
    SelectPartTimes:Remove(1)
  end
end
function TacticWheelPage:PlaySelectPartItem()
  ViewMgr:HidePage(self, UIPageNameDefine.TacticWheelPage)
  local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
  if not LocalPlayerController then
    return
  end
  if bCoolDown then
    if CurSelectindex < 0 then
      return
    end
    local TacticWheelProxy = GameFacade:RetrieveProxy(ProxyNames.TacticWheelProxy)
    local CommunicationInfo = TacticWheelProxy:GetCommunicateInfo(CurSelectindex + 1)
    local ActionID = 0
    local AudioID = 0
    if nil ~= CommunicationInfo and 0 ~= CommunicationInfo.id then
      if CommunicationInfo.communication_type == GlobalEnumDefine.ECommunicationType.RoleAction then
        ActionID = CommunicationInfo.id
      elseif CommunicationInfo.communication_type == GlobalEnumDefine.ECommunicationType.RoleVoice then
        AudioID = CommunicationInfo.id
      end
      self:UpdateSelectState()
      LocalPlayerController:PlayTactic(ActionID, AudioID)
    end
  end
end
function TacticWheelPage:MakeCoolDown()
  bCoolDown = false
  TimerTask = TimerMgr:AddTimeTask(self.CannotActionCD, 0, 1, function()
    bCoolDown = true
    self:UpdateRenderOpacity()
  end)
end
function TacticWheelPage:ResetMouse()
  local LocalPlayerController = UE4.UPMLuaBridgeBlueprintLibrary.GetPMPlayerController(self, 0)
  if LocalPlayerController then
    local viewSize = UE4.UWidgetLayoutLibrary.GetViewportSize(LuaGetWorld())
    LocalPlayerController:SetMouseLocation(viewSize.X / 2, viewSize.Y / 2)
  end
end
return TacticWheelPage
