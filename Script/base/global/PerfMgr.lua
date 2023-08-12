TimerMgr:AddTimeTask(0, 10, 0, function()
  LogDebug("LuaMemory", "memory: %.2fKB", collectgarbage("count"))
end)
