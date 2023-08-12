local ReturnLetterPage = class("ReturnLetterPage", PureMVC.ViewComponentPage)
local TurnCount = 30
local LineCount = 5
local NextWordInterval = 0.1
local NextPageInterval = 0.8
function ReturnLetterPage:ListNeededMediators()
  return {}
end
function ReturnLetterPage:GetPlayerName()
  local proxy = GameFacade:RetrieveProxy(ProxyNames.PlayerProxy)
  local nickName = proxy:GetPlayerAttr(GlobalEnumDefine.PlayerAttributeType.emNick)
  return nickName
end
function ReturnLetterPage:InitCfg()
  local ReturnLetterCfg = ConfigMgr:GetReturnLetterTableRow()
  self.ReturnLetterCfg = {}
  if ReturnLetterCfg then
    ReturnLetterCfg = ReturnLetterCfg:ToLuaTable()
    for key, cfg in pairs(ReturnLetterCfg) do
      self.ReturnLetterCfg[key] = cfg
    end
  end
  self.ReturnLetterCfg = ReturnLetterCfg
end
function ReturnLetterPage:InitializeLuaEvent()
  if self.Button_Bg then
    self.Button_Bg.OnClicked:Add(self, ReturnLetterPage.OnBgClick)
  end
  if self.Button_Play then
    self.Button_Play.OnClicked:Add(self, ReturnLetterPage.OnPlayClick)
  end
  self.bShowing = false
  self.curPage = 1
  self:InitCfg()
  local kaNavigationProxy = GameFacade:RetrieveProxy(ProxyNames.KaNavigationProxy)
  local CurrentRoleId = kaNavigationProxy:GetCurrentRoleId()
  self.currentLetterName = "10001"
  for k, v in pairs(self.ReturnLetterCfg) do
    if tostring(v.RoleId) == tostring(CurrentRoleId) then
      self.currentLetterName = tostring(k)
      break
    end
  end
  self:InitShowLineList()
  self.CurLineText = {
    self.Text_1,
    self.Text_2,
    self.Text_3,
    self.Text_4,
    self.Text_5
  }
  local nickName = self:GetPlayerName()
  local zhi = ConfigMgr:FromStringTable(StringTablePath.ST_Lobby, "Zhi")
  self.TextBlock_Head:SetText(zhi .. " " .. nickName)
  local RoleProxy = GameFacade:RetrieveProxy(ProxyNames.RoleProxy)
  local roleProp = RoleProxy:GetRoleProfile(self.ReturnLetterCfg[self.currentLetterName].RoleId)
  self.TextBlock_End:SetText("- " .. roleProp.NameCn .. " -")
  self:StartShowTextTimer(self.curPage)
end
function ReturnLetterPage:OnBgClick()
  if self.curPage > math.ceil(#self.showLineList / LineCount) then
    self.CanvasPanel_Main:SetVisibility(UE4.ESlateVisibility.Collapsed)
    if self.CloseCallBack then
      self.CloseCallBack()
      self.CloseCallBack = nil
    end
    ViewMgr:ClosePage(self, UIPageNameDefine.ReturnLetterPage)
  else
    self:DestoryShowTextTimer()
    self:DestoryShowNextTimer()
    self:ShowContext(self.curPage)
    self.curPage = self.curPage + 1
    self.showNextTimer = TimerMgr:AddTimeTask(NextPageInterval, 0, 1, function()
      self:StartShowTextTimer(self.curPage)
    end)
  end
end
function ReturnLetterPage:OnPlayClick()
  self:StartShowTextTimer(true)
end
function getByteCountArr(str)
  local realByteCount = #str
  local length = 0
  local curBytePos = 1
  local arr = {}
  while true do
    local step = 1
    local byteVal = string.byte(str, curBytePos)
    byteVal = byteVal or 1
    if byteVal > 239 then
      step = 4
    elseif byteVal > 223 then
      step = 3
    elseif byteVal > 191 then
      step = 2
    else
      step = 1
    end
    arr[#arr + 1] = string.sub(str, curBytePos, curBytePos + step - 1)
    curBytePos = curBytePos + step
    if realByteCount < curBytePos then
      break
    end
  end
  return arr
end
function ReturnLetterPage:InitShowLineList()
  local ContentText = self.ReturnLetterCfg[self.currentLetterName].LetterTitle .. "\n" .. self.ReturnLetterCfg[self.currentLetterName].LetterTitleTwo
  local Arr = getByteCountArr(ContentText)
  local showLineList = {}
  local CurLineIndex = 1
  local ShowStr = ""
  local CurLineCount = 0
  for i, v in ipairs(Arr) do
    if "\n" == v then
      showLineList[CurLineIndex] = ShowStr
      ShowStr = ""
      CurLineIndex = CurLineIndex + 1
      CurLineCount = 0
    else
      ShowStr = ShowStr .. v
      CurLineCount = CurLineCount + 1
      if CurLineCount >= TurnCount then
        showLineList[CurLineIndex] = ShowStr
        ShowStr = ""
        CurLineIndex = CurLineIndex + 1
        CurLineCount = 0
      end
    end
  end
  if CurLineIndex > #showLineList then
    showLineList[#showLineList + 1] = ShowStr
  end
  self.showLineList = showLineList
  table.print(self.showLineList)
end
function ReturnLetterPage:ShowContext(page)
  if self.curPage > math.ceil(#self.showLineList / LineCount) then
    return
  end
  for i, text in ipairs(self.CurLineText) do
    text:SetText("")
  end
  for i, text in ipairs(self.CurLineText) do
    local idx = (page - 1) * 5 + i
    if text and self.showLineList[idx] then
      text:SetText(self.showLineList[idx])
    end
  end
end
function ReturnLetterPage:StartShowTextTimer(page)
  if self.curPage > math.ceil(#self.showLineList / LineCount) then
    return
  end
  local Scale = 1
  self:DestoryShowTextTimer()
  local intervalTime = NextWordInterval / Scale
  local Arr = {}
  for i = 1, 5 do
    local idx = (page - 1) * 5 + i
    if self.showLineList[idx] then
      local tmpArr = getByteCountArr(self.showLineList[idx])
      for _, v in ipairs(tmpArr) do
        Arr[#Arr + 1] = v
      end
      if #tmpArr < TurnCount then
        Arr[#Arr + 1] = "\n"
      end
    end
  end
  local CurCount = 1
  for i, text in ipairs(self.CurLineText) do
    if text then
      text:SetText("")
    end
  end
  local CurrentShowStr = ""
  local CurLineIndex = 1
  local ShowStr = ""
  local CurLineCount = 0
  local ShowStep = 1
  self.showTextTimer = TimerMgr:AddTimeTask(0.1, intervalTime, 0, function()
    local CurShowStep = TurnCount - CurLineCount > ShowStep and ShowStep or TurnCount - CurLineCount
    if CurCount + CurShowStep - 1 > #Arr then
      CurShowStep = #Arr - CurCount + 1
    end
    local CurrentShowChar = table.concat(Arr, "", CurCount, CurCount + CurShowStep - 1)
    if "\n" == CurrentShowChar then
      CurLineCount = 0
      CurrentShowStr = ""
      CurLineIndex = CurLineIndex + 1
    else
      CurrentShowStr = CurrentShowStr .. CurrentShowChar
      local textWidget = self.CurLineText[CurLineIndex]
      if textWidget then
        textWidget:SetText(CurrentShowStr)
      end
      if CurLineCount > TurnCount or CurShowStep < ShowStep then
        CurLineCount = 0
        CurrentShowStr = ""
        CurLineIndex = CurLineIndex + 1
      else
        CurLineCount = CurLineCount + CurShowStep
        if CurLineCount == TurnCount then
          CurLineCount = 0
          CurrentShowStr = ""
          CurLineIndex = CurLineIndex + 1
        end
      end
    end
    if CurShowStep <= 0 then
      CurShowStep = 1
    end
    CurCount = CurCount + CurShowStep
    if CurCount > #Arr then
      self.curPage = self.curPage + 1
      self:DestoryShowTextTimer()
      if self.curPage > math.ceil(#self.showLineList / LineCount) then
        return
      else
        self:DestoryShowNextTimer()
        self.showNextTimer = TimerMgr:AddTimeTask(NextPageInterval, 0, 1, function()
          self:StartShowTextTimer(self.curPage)
        end)
      end
    end
  end)
end
function ReturnLetterPage:DestoryShowTextTimer()
  if self.showTextTimer then
    self.showTextTimer:EndTask()
    self.showTextTimer = nil
  end
end
function ReturnLetterPage:DestoryShowNextTimer()
  if self.showNextTimer then
    self.showNextTimer:EndTask()
    self.showNextTimer = nil
  end
end
function ReturnLetterPage:OnOpen(luaOpenData, nativeOpenData)
  self.CloseCallBack = luaOpenData.CloseCallBack
end
function ReturnLetterPage:LuaHandleKeyEvent(key, inputEvent)
  local keyName = UE4.UKismetInputLibrary.Key_GetDisplayName(key)
  if "Escape" == keyName and inputEvent == UE4.EInputEvent.IE_Released then
    self:OnBgClick()
    return true
  end
  return false
end
function ReturnLetterPage:OnClose()
  self:DestoryShowTextTimer()
  self:DestoryShowNextTimer()
  if self.CloseCallBack then
    self.CloseCallBack()
    self.CloseCallBack = nil
  end
end
return ReturnLetterPage
