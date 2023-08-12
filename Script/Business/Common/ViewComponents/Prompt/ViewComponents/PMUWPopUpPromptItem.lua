local PMUWPopUpPromptItem = class("PMUWPopUpPromptItem", PureMVC.ViewComponentPanel)
function PMUWPopUpPromptItem:OnInitialized()
  PMUWPopUpPromptItem.super.OnInitialized(self)
end
function PMUWPopUpPromptItem:InitView(data)
  self._data = data
  self.Text_BlinkMsg:SetText(self._data.msg)
end
function PMUWPopUpPromptItem:PlayShowAni()
  if self.ShowAnimation then
    self:PlayAnimation(self.ShowAnimation, 0, 1, UE4.EUMGSequencePlayMode.Forward, 1, false)
  end
end
return PMUWPopUpPromptItem
