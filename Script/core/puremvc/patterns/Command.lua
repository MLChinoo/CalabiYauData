local Notifier = puremvc_require("patterns/Notifier")
local Command = class("Command", Notifier)
function Command:ctor()
  Command.super.ctor(self)
end
function Command:Execute(notification)
end
return Command
