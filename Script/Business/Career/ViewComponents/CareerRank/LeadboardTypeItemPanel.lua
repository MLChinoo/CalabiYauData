local LeadboardTypeItemPanel = class("LeadboardTypeItemPanel", PureMVC.ViewComponentPanel)
function LeadboardTypeItemPanel:ListNeededMediators()
  return {}
end
function LeadboardTypeItemPanel:OnListItemObjectSet(listItemObject)
  self.name = listItemObject.name
  self.Txt_BtnName:SetText(self.name)
end
return LeadboardTypeItemPanel
