local RedDotNode = require("Business/RedDot/RedDotNode")
local RedDotTree = {}
RedDotTree.root = nil
function RedDotTree:Init()
  RedDotTree.root = RedDotNode.new("Main")
  for _, name in pairs(RedDotModuleDef.ModuleName) do
    self:InsertNode(name)
  end
end
function RedDotTree:InsertNode(inName)
  if nil == inName or "" == inName then
    return
  end
  if self:FindNode(inName) then
    return
  end
  local node = RedDotTree.root
  node.passCnt = node.passCnt + 1
  local pathList = string.split(inName, ".")
  for index = 2, #pathList do
    local path = pathList[index]
    if nil == node.children[path] then
      node.children[path] = RedDotNode.new(path)
    end
    node = node.children[path]
    node.passCnt = node.passCnt + 1
  end
  node.endCnt = node.endCnt + 1
end
function RedDotTree:FindNode(inName)
  if nil == inName or "" == inName then
    return nil
  end
  local node = RedDotTree.root
  local pathList = string.split(inName, ".")
  for index = 2, #pathList do
    local path = pathList[index]
    if nil == node.children[path] then
      return nil
    end
    node = node.children[path]
  end
  if node.endCnt > 0 then
    return node
  end
end
function RedDotTree:DeleteNode(inName)
  if nil == inName or "" == inName then
    return nil
  end
  if nil == self:FindNode(inName) then
    LogDebug("RedDotTree", "//找不到节点：(%s)", inName)
    return
  end
  local node = RedDotTree.root
  node.passCnt = node.passCnt - 1
  local pathList = string.split(inName, ".")
  for index = 2, #pathList do
    local path = pathList[index]
    local childNode = node.children[path]
    childNode.passCnt = childNode.passCnt - 1
    if 0 == childNode.passCnt then
      node.children[path] = nil
      return
    end
    node = childNode
  end
  node.endCnt = node.endCnt - 1
end
function RedDotTree:ChangeRedDotCnt(inName, inDelta)
  local targetNode = self:FindNode(inName)
  if nil == targetNode then
    LogDebug("RedDotTree", "//找不到节点：(%s)", inName)
    return
  end
  if inDelta < 0 and targetNode.redDotCnt + inDelta < 0 then
    inDelta = -targetNode.redDotCnt
  end
  local node = RedDotTree.root
  local pathList = string.split(inName, ".")
  local tempNode = {}
  local tempName = {}
  for index = 2, #pathList do
    local path = pathList[index]
    local currentName = table.concat(pathList, ".", 1, index)
    local childNode = node.children[path]
    childNode.redDotCnt = childNode.redDotCnt + inDelta
    node = childNode
    table.insert(tempNode, node)
    table.insert(tempName, currentName)
  end
  for i = 1, #tempNode do
    for _, cb in pairs(tempNode[i].updateCb) do
      cb(tempNode[i].redDotCnt, tempName[i])
    end
  end
end
function RedDotTree:SetRedDotCnt(inName, inCnt)
  if inCnt < 0 then
    return
  end
  local targetNode = self:FindNode(inName)
  if nil == targetNode then
    LogDebug("RedDotTree", "//找不到节点：(%s)", inName)
    return
  end
  local delta = inCnt - targetNode.redDotCnt
  if 0 == delta then
    return
  end
  local node = RedDotTree.root
  local pathList = string.split(inName, ".")
  local tempNode = {}
  local tempName = {}
  for index = 2, #pathList do
    local path = pathList[index]
    local currentName = table.concat(pathList, ".", 1, index)
    local childNode = node.children[path]
    childNode.redDotCnt = childNode.redDotCnt + delta
    if childNode.redDotCnt < 0 then
      childNode.redDotCnt = 0
    end
    node = childNode
    table.insert(tempNode, node)
    table.insert(tempName, currentName)
  end
  for i = 1, #tempNode do
    for _, cb in pairs(tempNode[i].updateCb) do
      cb(tempNode[i].redDotCnt, tempName[i])
    end
  end
end
function RedDotTree:Bind(inName, inCb)
  local node = self:FindNode(inName)
  if nil == node then
    return
  end
  table.insert(node.updateCb, inCb)
end
function RedDotTree:Unbind(inName)
  local node = self:FindNode(inName)
  if nil == node then
    return
  end
  node.updateCb = {}
end
function RedDotTree:GetRedDotCnt(inName)
  local node = self:FindNode(inName)
  if nil == node then
    return 0
  end
  return node.redDotCnt or 0
end
return RedDotTree
