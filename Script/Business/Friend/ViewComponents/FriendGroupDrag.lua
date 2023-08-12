local FriendGroupDrag = class("FriendGroupDrag", PureMVC.ViewComponentPanel)
function FriendGroupDrag:ctor(proxyName, data)
  self.super.ctor(self, proxyName, data)
end
function FriendGroupDrag:ListNeededMediators()
  return {}
end
function FriendGroupDrag:InitializeLuaEvent()
end
function FriendGroupDrag:InitWidget(inGroupName)
  if self.Text_GroupName then
    self.Text_GroupName:SetText(inGroupName)
  end
end
return FriendGroupDrag
