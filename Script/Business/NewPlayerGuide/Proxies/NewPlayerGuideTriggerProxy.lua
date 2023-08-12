local NewPlayerGuideTriggerProxy = class("NewPlayerGuideTriggerProxy", PureMVC.Proxy)
local NewPlayerGuideEnum = require("Business/NewPlayerGuide/Proxies/NewPlayerGuideEnum")
local CreateTriggerConfigArr = function()
  local TriggerConfigArr = {
    [NewPlayerGuideEnum.GuideStep.Gift] = require("Business/NewPlayerGuide/Proxies/GuideStep/GiftConfig"),
    [NewPlayerGuideEnum.GuideStep.GiftFirstItem] = require("Business/NewPlayerGuide/Proxies/GuideStep/GiftFirstItemConfig"),
    [NewPlayerGuideEnum.GuideStep.Gift3DBox] = require("Business/NewPlayerGuide/Proxies/GuideStep/Gift3DBoxConfig"),
    [NewPlayerGuideEnum.GuideStep.GiftReceived] = require("Business/NewPlayerGuide/Proxies/GuideStep/GiftReceivedConfig"),
    [NewPlayerGuideEnum.GuideStep.BackLobbyAndClose] = require("Business/NewPlayerGuide/Proxies/GuideStep/BackLobbyAndCloseConfig")
  }
  return TriggerConfigArr
end
function NewPlayerGuideTriggerProxy:OnRegister()
  self.super.OnRegister(self)
  self.triggerConfig = CreateTriggerConfigArr()
  self.showCurIndex = nil
end
function NewPlayerGuideTriggerProxy:OnRemove()
  self.super.OnRemove(self)
  self.triggerConfig = nil
end
function NewPlayerGuideTriggerProxy:Start()
  self.showCurIndex = 1
  self:CreateTimeoutTimer()
end
function NewPlayerGuideTriggerProxy:ShowNextStep(delayTime)
  self.showCurIndex = self.showCurIndex + 1
  if nil == delayTime and self.showCurIndex == NewPlayerGuideEnum.GuideStep.GiftReceived then
    delayTime = 0.5
  end
  if self.showCurIndex > NewPlayerGuideEnum.GuideStepMax then
    self:DestoryTimeoutTimer()
    GameFacade:SendNotification(NotificationDefines.ApartmentNewGuideClose)
  else
    self:CreateTimeoutTimer(delayTime)
  end
end
function NewPlayerGuideTriggerProxy:ShowCurFocusWidget()
  local config = self.triggerConfig[self.showCurIndex]
  if nil == config then
    self:DestoryTimeoutTimer()
    return
  end
  if config.viewClassPath then
    local WidgetUIArr = self:GetWidgetArrByPath(config.viewClassPath)
    local WidgetUI
    if config.selectFunc then
      WidgetUI = config.selectFunc(WidgetUIArr)
    elseif WidgetUIArr:Num() > 0 then
      WidgetUI = WidgetUIArr:GetRef(1)
    end
    if nil == WidgetUI then
      LogDebug("NewPlayerGuide", "there is no  %s widget, you should check the config is right?", config.viewClassPath)
      return
    end
    local focusWidget
    if type(config.widgetName) == "string" then
      focusWidget = WidgetUI[config.widgetName]
      if nil == focusWidget then
        LogDebug("NewPlayerGuide", "widget name is %s is not found!", config.widgetName)
        return
      end
    else
      local childWidget = WidgetUI
      for i = 1, #config.widgetName do
        childWidget = childWidget[config.widgetName[i]]
        if nil == childWidget then
          LogDebug("NewPlayerGuide", "widget name is %s is not found!", config.widgetName[i])
          return
        end
      end
      focusWidget = childWidget
    end
    if config.revertFunc then
      function config.wrapRevertFunc()
        config.revertFunc(WidgetUI)
      end
    end
    self:DestoryTimeoutTimer()
    if config.showfunc then
      config.showfunc(WidgetUI)
    end
    GameFacade:SendNotification(NotificationDefines.ShowPlayerGuideCmd, {
      widget = focusWidget,
      extras = config.extras,
      callfunc = function()
        GameFacade:SendNotification(NotificationDefines.ApartmentNewGuideHideTarget)
        LogDebug("NewPlayerGuide", "you click the %s index  widget ", tostring(self.showCurIndex))
        if config.clickfunc then
          config.clickfunc(WidgetUI)
        end
        if config.continue then
          self:ShowNextStep()
        end
        config.wrapRevertFunc = nil
      end,
      handleKeyFunc = config.handleKeyFunc and function(key, inputEvent)
        if config.handleKeyFunc(key, inputEvent) then
          if config.continue then
            LogDebug("NewPlayerGuide", "you key handled  the %s index  widget ", tostring(self.showCurIndex))
            self:ShowNextStep()
          end
          return true
        end
        return false
      end
    })
  elseif config.getTargetFunc then
    local actor = config.getTargetFunc()
    if nil == actor then
      return
    end
    local position, size = config.getPositionAndSize(actor)
    self:DestoryTimeoutTimer()
    GameFacade:SendNotification(NotificationDefines.ShowPlayerGuideCmd, {
      position = position,
      size = size,
      extras = {focusActor = actor},
      callfunc = function()
        GameFacade:SendNotification(NotificationDefines.ApartmentNewGuideHideTarget)
        if config.clickfunc then
          config.clickfunc(actor)
        end
        if config.continue then
          self:ShowNextStep()
        end
      end
    })
  end
end
function NewPlayerGuideTriggerProxy:GetWidgetArrByPath(WidgetPath)
  local WidgetClass = LoadClass(WidgetPath)
  return self:GetWidgetArr(WidgetClass)
end
function NewPlayerGuideTriggerProxy:GetWidgetArr(WidgetClass)
  local BaseWidgetPath = "/Script/UMG.UserWidget"
  local BaseWidgetClass = LoadClass(BaseWidgetPath)
  local Arr = UE.TArray(BaseWidgetClass)
  UE4.UWidgetBlueprintLibrary.GetAllWidgetsOfClass(LuaGetWorld(), Arr, WidgetClass, false)
  return Arr
end
function NewPlayerGuideTriggerProxy:CreateTimeoutTimer(delayTime, intervalTime)
  delayTime = delayTime or 0.5
  intervalTime = intervalTime or 0.5
  if 0 == delayTime then
    self.TimeoutTask = TimerMgr:AddTimeTask(intervalTime, intervalTime, 0, function()
      self:ShowCurFocusWidget()
    end)
    self:ShowCurFocusWidget()
  else
    self.TimeoutTask = TimerMgr:AddTimeTask(delayTime, intervalTime, 0, function()
      self:ShowCurFocusWidget()
    end)
  end
end
function NewPlayerGuideTriggerProxy:DestoryTimeoutTimer()
  if self.TimeoutTask then
    self.TimeoutTask:EndTask()
    self.TimeoutTask = nil
  end
end
function NewPlayerGuideTriggerProxy:CheckStep(step)
  if self.showCurIndex and self.showCurIndex == step then
    return true
  end
  return false
end
function NewPlayerGuideTriggerProxy:ShowRevertFunc(step)
  if self.showCurIndex == step then
    local config = self.triggerConfig[self.showCurIndex]
    if config and config.wrapRevertFunc then
      config.wrapRevertFunc()
      config.wrapRevertFunc = nil
    end
  end
end
return NewPlayerGuideTriggerProxy
