local SecondaryNavBar = class("SecondaryNavBar", PureMVC.ViewComponentPanel)
function SecondaryNavBar:InitializeLuaEvent()
  self.curButtonIndex = 1
  self.curMaxIndex = 0
  self.buttonArray = {}
  self.redDotArray = {}
end
function SecondaryNavBar:Construct()
  SecondaryNavBar.super.Construct(self)
end
function SecondaryNavBar:Destruct()
  SecondaryNavBar.super.Destruct(self)
  self:ClearBind()
end
function SecondaryNavBar:GenerateNavbar(barType, selectIndex, exData, navBar)
  local proxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  if not proxy then
    return
  end
  local funcTableRow = proxy:GetFunctionById(barType)
  if not funcTableRow then
    return
  end
  self.UpNavBar = navBar
  if self.DynamicEntryBox_Nav then
    self:ClearRedDot()
    local widgetNum = self.DynamicEntryBox_Nav:GetNumEntries()
    local fixedButtonNum = funcTableRow.SubFunction:Length()
    local dynamicWidgetList = {}
    if funcTableRow.proxy then
      local dynamicProxy = GameFacade:RetrieveProxy(funcTableRow.proxy)
      if dynamicProxy then
        dynamicWidgetList = dynamicProxy:GetEnableList()
      end
    end
    local totalButtonNum = fixedButtonNum + #dynamicWidgetList
    if widgetNum < totalButtonNum then
      local extraEntryNum = totalButtonNum - widgetNum
      for exIndex = 1, extraEntryNum do
        local widget = self.DynamicEntryBox_Nav:BP_CreateEntry()
        table.insert(self.buttonArray, widget)
      end
    end
    local found = 0
    for fIndex = 1, fixedButtonNum do
      local subFuncTableRow = proxy:GetFunctionById(funcTableRow.SubFunction:Get(fIndex))
      if subFuncTableRow and self.buttonArray[fIndex] then
        if subFuncTableRow.RedDot ~= "None" then
          local redDotKey = RedDotModuleDef.ModuleName[subFuncTableRow.RedDot]
          self.redDotArray[redDotKey] = fIndex
          RedDotTree:Bind(redDotKey, function(cnt, inName)
            self:UpdateRedDot(cnt, inName)
          end)
          self:UpdateRedDot(RedDotTree:GetRedDotCnt(redDotKey), redDotKey)
        end
        local style = self:GetButtonStyle(fIndex, totalButtonNum)
        self.buttonArray[fIndex]:InitInfo(style, subFuncTableRow.Name, subFuncTableRow.BluePrint, fIndex, self)
        self.buttonArray[fIndex]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
      found = fIndex
    end
    for dIndex = 1, #dynamicWidgetList do
      found = found + 1
      if self.buttonArray[found] then
        local style = self:GetButtonStyle(found, totalButtonNum)
        local dynamicInfo = dynamicWidgetList[dIndex]
        if type(selectIndex) == "string" and selectIndex == dynamicInfo.strCustom then
          selectIndex = found
          exData = dynamicInfo.strCustom
        end
        self.buttonArray[found]:InitInfo(style, dynamicInfo.name, dynamicInfo.pageName, found, self, dynamicInfo.strCustom)
        self.buttonArray[found]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
    for closeIndex = found + 1, #self.buttonArray do
      if self.buttonArray[closeIndex] then
        self.buttonArray[closeIndex]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
    self.curMaxIndex = totalButtonNum
    self:SetVisibility(self.curMaxIndex > 1 and UE4.ESlateVisibility.SelfHitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self.curButtonIndex = selectIndex or 1
    if self.buttonArray[self.curButtonIndex] then
      self.buttonArray[self.curButtonIndex]:SetChecked(true, exData, true)
    end
  end
end
function SecondaryNavBar:GetButtonStyle(index, total)
  if 1 == index and total > 1 then
    return "left"
  elseif 1 == total or index < total then
    return "middle"
  elseif index == total and total > 1 then
    return "right"
  end
end
function SecondaryNavBar:NotifyActiveButton(buttonIndex)
  if buttonIndex ~= self.curButtonIndex then
    if self.buttonArray[self.curButtonIndex] then
      self.buttonArray[self.curButtonIndex]:SetChecked(false)
    end
    self.curButtonIndex = buttonIndex
    if self.UpNavBar then
      self.UpNavBar.currentSecondNavBar = buttonIndex
    end
  end
end
function SecondaryNavBar:CloseActivePage()
  if 0 == #self.buttonArray then
    return
  end
  for index = 1, self.curMaxIndex do
    if self.buttonArray[index] then
      self.buttonArray[index]:CloseBindPage()
    end
  end
  if self.buttonArray[self.curButtonIndex] then
    self.buttonArray[self.curButtonIndex]:SetChecked(false)
  end
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self:ClearRedDot()
end
function SecondaryNavBar:UpdateRedDot(cnt, redDotKey)
  local index = self.redDotArray[redDotKey]
  if index then
    local bt = self.buttonArray[index]
    if bt then
      bt:SetRedDot(cnt)
    end
  end
end
function SecondaryNavBar:ClearRedDot()
  self:ClearBind()
  for index, value in ipairs(self.buttonArray) do
    if value then
      value:SetRedDot(0)
    end
  end
end
function SecondaryNavBar:ClearBind()
  for key, value in pairs(self.redDotArray) do
    RedDotTree:Unbind(RedDotModuleDef.ModuleName[key])
  end
  self.redDotArray = {}
end
return SecondaryNavBar
