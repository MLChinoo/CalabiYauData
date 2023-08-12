local Command = puremvc_require("patterns/Command")
local MacroCommand = class("MacroCommand", Command)
function MacroCommand:ctor()
  MacroCommand.super.ctor(self)
  self.subCommands = {}
  self:InitializeMacroCommand()
end
function MacroCommand:InitializeMacroCommand()
end
function MacroCommand:AddSubCommand(commandClassRef)
  table.insert(self.subCommands, commandClassRef)
end
function MacroCommand:Execute(note)
  while #self.subCommands > 0 do
    local ref = table.remove(self.subCommands, 1)
    local cmd = ref.new()
    cmd:InitializeNotifier(self.multitonKey)
    cmd:Execute(note)
  end
end
return MacroCommand
