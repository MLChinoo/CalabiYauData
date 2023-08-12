local SettingComboxSubItem = class("SettingComboxSubItem", PureMVC.ViewComponentPanel)
function SettingComboxSubItem:InitializeLuaEvent()
end
function SettingComboxSubItem:InitView(args)
  self.combox = args.combox
  self.option = args.option
  self.Text_Number:SetText(args.option)
end
return SettingComboxSubItem
