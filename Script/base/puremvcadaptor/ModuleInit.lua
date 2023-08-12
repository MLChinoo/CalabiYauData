local ModuleInit = class("ModuleInit")
ModuleInit.Proxys = {}
ModuleInit.Commands = {}
function ModuleInit:Init()
  local GameFacade = GameFacade
  if not GameFacade then
    return
  end
  local bSuccess, errorMsg, ClassObject
  for k, v in pairs(self.Proxys) do
    if v.Name and v.Path then
      bSuccess, errorMsg = pcall(require, v.Path)
      if bSuccess then
        ClassObject = require(v.Path)
        GameFacade:RegisterProxy(ClassObject.new(v.Name))
      else
        LogError("ModuleInit:Init-Proxys", [[
File require error !!! 
 Error = %s]], errorMsg)
      end
    else
      LogError("ModuleInit:Init-Proxys", "Name or Path not config !!! Index=%s, Name=%s, Path=%s", k, v.Name, v.Path)
    end
  end
  for k, v in pairs(self.Commands) do
    if v.Name and v.Path then
      bSuccess, errorMsg = pcall(require, v.Path)
      if bSuccess then
        ClassObject = require(v.Path)
        GameFacade:RegisterCommand(v.Name, ClassObject)
      else
        LogError("ModuleInit:Init-Proxys", [[
File require error !!! 
 Error = %s]], errorMsg)
      end
    else
      LogError("ModuleInit:Init-Commands", "Name Or Path not config !!! Index=%s, Name=%s, Path=%s", k, v.Name, v.Path)
    end
  end
end
function ModuleInit:Clear()
  local GameFacade = GameFacade
  if not GameFacade then
    return
  end
  local err_handle = function(err, name, path)
    LogError("ModuleInit:Clear-Commands", "Name=%s, Path=%s, error is %s", name, path, err)
  end
  for i, v in pairs(self.Proxys) do
    if v.Name and v.Path then
      xpcall(function()
        GameFacade:RemoveProxy(v.Name)
      end, function(err)
        err_handle(err, v.Name, v.Path)
      end)
    end
  end
  for i, v in pairs(self.Commands) do
    if v.Name and v.Path then
      GameFacade:RemoveCommand(v.Name)
    end
  end
end
return ModuleInit
