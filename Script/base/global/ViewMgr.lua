local ViewMgr = {}
function ViewMgr:OpenPage(worldObject, name, newIns, openData)
  UE4.LuaBridge.LuaOpenPage(worldObject, name, newIns, openData)
end
function ViewMgr:ClosePage(worldObject, uiPageName)
  UE4.LuaBridge.LuaClosePage(worldObject, uiPageName)
end
function ViewMgr:HidePage(worldObject, uiPageName)
  UE4.LuaBridge.LuaHidePage(worldObject, uiPageName)
end
function ViewMgr:PushPage(worldObject, uiName, openData, bNewBusiness)
  UE4.LuaBridge.LuaPushPage(worldObject, uiName, openData, bNewBusiness)
end
function ViewMgr:PopPage(worldObject, uiName)
  UE4.LuaBridge.LuaPopPage(worldObject, uiName)
end
function ViewMgr:CloseAllPageExclude(worldObject, uiPageNameTable)
  UE4.LuaBridge.LuaCloseAllPageEX(worldObject, uiPageNameTable)
end
function ViewMgr:SetAllPageLstVisibility(worldObject, isVisible)
  UE4.LuaBridge.LuaSetAllPageLstVisibility(worldObject, isVisible)
end
return ViewMgr
