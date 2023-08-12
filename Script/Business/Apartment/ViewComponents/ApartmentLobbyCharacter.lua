require("UnLua")
local ApartmentLobbyCharacter = Class()
function ApartmentLobbyCharacter:Construct()
  self.bubbleWidget = nil
end
function ApartmentLobbyCharacter:Destruct()
  self.bubbleWidget = nil
end
function ApartmentLobbyCharacter:SetBubbleVis(bVis)
  self.bBubbleVis = bVis
  if bVis then
    ViewMgr:OpenPage(self, UIPageNameDefine.SpeakBubblePage)
  else
    ViewMgr:ClosePage(self, UIPageNameDefine.SpeakBubblePage)
  end
end
function ApartmentLobbyCharacter:SetBubblePos()
  if self.bubbleWidget then
    local pos = self:GetBubblePosByHitBoneName("Bip001-Head")
    self.bubbleWidget:AdjustPos(pos)
  end
end
function ApartmentLobbyCharacter:SetBubbleWidget(widget)
  print("Sett widget", widget)
  self.bubbleWidget = widget
  if self.bubbleWidget then
    self:SetBubblePos()
  end
end
return ApartmentLobbyCharacter
