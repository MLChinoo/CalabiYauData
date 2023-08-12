local PlayerCardLevelItemPanel = class("PlayerCardLevelItemPanel", PureMVC.ViewComponentPage)
function PlayerCardLevelItemPanel:InitializeLuaEvent()
  LogDebug("PlayerCardLevelItemPanel", "Init lua event")
end
function PlayerCardLevelItemPanel:InitInfo(levelNum, levelBox)
  if levelNum and levelNum > 0 and self.Txt_levelName then
    self.Txt_levelName:SetText(tostring(levelNum))
  end
  if levelBox and self.Image_box_name then
    self:SetImageByPaperSprite(self.Image_box_name, levelBox)
  end
end
return PlayerCardLevelItemPanel
