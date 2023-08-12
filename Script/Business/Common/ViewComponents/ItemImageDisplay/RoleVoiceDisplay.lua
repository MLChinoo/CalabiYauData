local RoleVoiceDisplay = class("RoleVoiceDisplay", PureMVC.ViewComponentPanel)
function RoleVoiceDisplay:ListNeededMediators()
  return {}
end
function RoleVoiceDisplay:Construct()
  RoleVoiceDisplay.super.Construct(self)
end
function RoleVoiceDisplay:SetVoiceImage(itemId)
  if self.Image_Icon and itemId then
    local img = GameFacade:RetrieveProxy(ProxyNames.ItemsProxy):GetAnyItemDisplayImg(itemId)
    if img then
      self:SetImageByTexture2D_MatchSize(self.Image_Icon, img)
    end
  end
end
function RoleVoiceDisplay:PlayRoleVoice()
  if self.ParamName and self.ParamValue_High then
    if self.Image_VoiceUp then
      local MIDynamic = self.Image_VoiceUp:GetDynamicMaterial()
      if MIDynamic then
        MIDynamic:SetScalarParameterValue(self.ParamName, self.ParamValue_High)
      end
    end
    if self.Image_VoiceBG then
      local MIDynamic = self.Image_VoiceBG:GetDynamicMaterial()
      if MIDynamic then
        MIDynamic:SetScalarParameterValue(self.ParamName, self.ParamValue_High)
      end
    end
  end
end
function RoleVoiceDisplay:StopRoleVoice()
  if self.ParamName and self.ParamValue_Low then
    if self.Image_VoiceUp then
      local MIDynamic = self.Image_VoiceUp:GetDynamicMaterial()
      if MIDynamic then
        MIDynamic:SetScalarParameterValue(self.ParamName, self.ParamValue_Low)
      end
    end
    if self.Image_VoiceBG then
      local MIDynamic = self.Image_VoiceBG:GetDynamicMaterial()
      if MIDynamic then
        MIDynamic:SetScalarParameterValue(self.ParamName, self.ParamValue_Low)
      end
    end
  end
end
return RoleVoiceDisplay
