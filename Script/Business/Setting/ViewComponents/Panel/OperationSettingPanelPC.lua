local OperationSettingPanelPC = class("OperationSettingPanelPC", PureMVC.ViewComponentPanel)
local OperationSettingPanelMediator = require("Business/Setting/Mediators/OperationSettingPanelMediator")
function OperationSettingPanelPC:ListNeededMediators()
  return {OperationSettingPanelMediator}
end
function OperationSettingPanelPC:InitializeLuaEvent()
end
function OperationSettingPanelPC:InitView(args, extras)
  if args and args.subIndex then
    self.targetIndex = args.subIndex
  end
end
function OperationSettingPanelPC:GetTargetIndex()
  return self.targetIndex or 1
end
return OperationSettingPanelPC
