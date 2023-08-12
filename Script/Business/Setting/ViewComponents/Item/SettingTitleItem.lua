local SettingTitleItem = class("SettingTitleItem", PureMVC.ViewComponentPanel)
function SettingTitleItem:InitView(args)
  if args.title then
    self.title:SetText(args.title)
  end
end
return SettingTitleItem
