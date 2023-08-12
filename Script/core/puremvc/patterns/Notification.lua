local Notification = class("Notification")
function Notification:ctor(name, body, type)
  self.name = name
  self.body = body
  self.type = type
end
function Notification:GetName()
  return self.name
end
function Notification:GetBody()
  return self.body
end
function Notification:SetBody(value)
  self.body = value
end
function Notification:GetType()
  return self.type
end
function Notification:SetType(value)
  self.type = value
end
return Notification
