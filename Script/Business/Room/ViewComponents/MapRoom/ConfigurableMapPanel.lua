local ConfigurableMapPanel = class("ConfigurableMapPanel", PureMVC.ViewComponentPanel)
function ConfigurableMapPanel:ListNeededMediators()
  return {}
end
function ConfigurableMapPanel:Construct()
  ConfigurableMapPanel.super.Construct(self)
end
function ConfigurableMapPanel:Destruct()
  ConfigurableMapPanel.super.Destruct(self)
end
function ConfigurableMapPanel:InitMapInfo(mapId)
  self:ShowMapLocationText(mapId)
end
return ConfigurableMapPanel
