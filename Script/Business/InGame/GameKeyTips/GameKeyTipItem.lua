local GameKeyTipItem = class("GameKeyTipItem", PureMVC.ViewComponentPanel)
function GameKeyTipItem:Construct()
  self:SetItem(self.ActionName)
end
function GameKeyTipItem:SetItem(InputName)
  if "None" == InputName then
    print("Error : GameKeyTipItem InputName is None")
  end
  local SettingConfigProxy = GameFacade:RetrieveProxy(ProxyNames.SettingConfigProxy)
  local oriData = SettingConfigProxy:GetOriDataByIndexKey(InputName)
  if oriData then
    self.Name:SetText(oriData.name)
  else
    self.Name:SetText(self.KeyText)
  end
  local inputSetting = UE4.UInputSettings.GetInputSettings()
  local arr = UE4.TArray(UE4.FInputActionKeyMapping)
  inputSetting:GetActionMappingByName(InputName, arr)
  local arrNum = arr:Num()
  local ele = arrNum > 0 and arr:Get(arrNum) or nil
  if ele then
    local KeyBursh = UE4.UPMLuaBridgeBlueprintLibrary.GetPMGlobals().UIConfig.KeyBindingBurshDisplayMap:Find(ele.Key)
    if KeyBursh then
      self.Switch_Key:SetActiveWidgetIndex(1)
      self.Img_Mouse:SetBrush(KeyBursh)
    else
      self.Switch_Key:SetActiveWidgetIndex(0)
      self.Key:SetText(UE4.UKismetInputLibrary.Key_GetDisplayName(ele.Key))
    end
  else
    local KeyBursh = UE4.UPMLuaBridgeBlueprintLibrary.GetPMGlobals().UIConfig.KeyBindingBurshDisplayMap:Find(UE4.EKeys.Invalid)
    if KeyBursh then
      self.Switch_Key:SetActiveWidgetIndex(1)
      self.Img_Mouse:SetBrush(KeyBursh)
    else
      self.Switch_Key:SetActiveWidgetIndex(0)
      self.Key:SetText("")
    end
  end
end
return GameKeyTipItem
