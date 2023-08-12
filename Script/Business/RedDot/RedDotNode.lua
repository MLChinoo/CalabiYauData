local RedDotNode = class("RedDotNode")
function RedDotNode:ctor(inName)
  self.name = inName
  self.passCnt = 0
  self.endCnt = 0
  self.redDotCnt = 0
  self.children = {}
  self.updateCb = {}
end
return RedDotNode
