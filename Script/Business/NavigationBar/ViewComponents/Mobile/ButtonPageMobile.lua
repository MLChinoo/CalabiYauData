local ButtonPageMobile = class("ButtonPageMobile", PureMVC.ViewComponentPage)
function ButtonPageMobile:InitializeLuaEvent()
  self.curButtonIndex = 1
  self.barType = -1
  self.pageNameArray = {}
  self.pageTypeArray = {}
  self.redDotArray = {}
end
function ButtonPageMobile:OnOpen(luaOpenData, nativeOpenData)
  if self.ReturnButton then
    self.ReturnButton.OnClickEvent:Add(self, self.OnReturnClick)
  end
  if self.NavigationBar then
    self.NavigationBar.OnItemCheckEvent:Add(self.OnNavigationBarClick, self)
  end
end
function ButtonPageMobile:OnShow(luaOpenData, nativeOpenData)
  if nativeOpenData and self.barType ~= nativeOpenData.ParentBusinessType then
    self.barType = nativeOpenData.ParentBusinessType
    local selectIndex = nativeOpenData.ButtonIndex or 1
    self:GenerateNavbar(self.barType, selectIndex)
  end
end
function ButtonPageMobile:OnClose()
  if self.ReturnButton then
    self.ReturnButton.OnClickEvent:Remove(self, self.OnReturnClick)
  end
  if self.NavigationBar then
    self.NavigationBar.OnItemCheckEvent:Remove(self.OnNavigationBarClick, self)
  end
  self:ClearBind()
end
function ButtonPageMobile:OnNavigationBarClick(index)
  self.curButtonIndex = index
  ViewMgr:PushPage(self, self.pageNameArray[index])
  self:SetReturnBtnName(self.pageTypeArray[index])
end
function ButtonPageMobile:OnReturnClick()
  ViewMgr:PopPage(self, self.pageNameArray[self.curButtonIndex])
end
function ButtonPageMobile:GenerateNavbar(barType, selectIndex)
  local proxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
  if not proxy then
    return
  end
  local funcTableRow = proxy:GetFunctionMobileById(barType)
  if not funcTableRow then
    return
  end
  local subFuncLen = funcTableRow.SubFunction:Length()
  if subFuncLen > 0 then
    self:ClearBind()
    local datas = {}
    self.pageNameArray = {}
    self.pageTypeArray = {}
    self.curButtonIndex = selectIndex
    for index = 1, subFuncLen do
      local subFuncTableRow = proxy:GetFunctionMobileById(funcTableRow.SubFunction:Get(index))
      if subFuncTableRow then
        if subFuncTableRow.RedDot ~= "None" then
          local redDotKey = RedDotModuleDef.ModuleName[subFuncTableRow.RedDot]
          self.redDotArray[redDotKey] = index
          RedDotTree:Bind(redDotKey, function(cnt, inName)
            self:UpdateRedDot(cnt, inName)
          end)
        end
        local data = {}
        data.barIcon = subFuncTableRow.IconItem
        data.barName = subFuncTableRow.Name
        data.customType = index
        datas[index] = data
        self.pageNameArray[index] = subFuncTableRow.BluePrint
        self.pageTypeArray[index] = subFuncTableRow.Id
      end
    end
    self.NavigationBar:UpdateBar(datas)
    self.NavigationBar:SetBarCheckStateByCustomType(selectIndex)
    self:SetReturnBtnName(self.pageTypeArray[selectIndex])
    for key, value in pairs(self.redDotArray) do
      self:UpdateRedDot(RedDotTree:GetRedDotCnt(key), key)
    end
  end
end
function ButtonPageMobile:UpdateRedDot(cnt, redDotKey)
  local index = self.redDotArray[redDotKey]
  if index then
    self.NavigationBar:SetRedDot(index, cnt)
  end
end
function ButtonPageMobile:ClearBind()
  for key, value in pairs(self.redDotArray) do
    RedDotTree:Unbind(RedDotModuleDef.ModuleName[key])
  end
  self.redDotArray = {}
end
function ButtonPageMobile:SetReturnBtnName(tabType)
  if self.ReturnButton then
    local basicFunctionProxy = GameFacade:RetrieveProxy(ProxyNames.BasicFunctionProxy)
    local configRow = basicFunctionProxy:GetFunctionMobileById(tabType)
    if configRow then
      self.ReturnButton:SetButtonName(configRow.Name)
    end
  end
end
return ButtonPageMobile
