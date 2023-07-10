if IsGame("dance") and GAMESTATE:GetCurrentStyle():GetName() == "single" or GAMESTATE:GetCurrentStyle():GetName() == "versus" then
  _GameEnv = {
    songdir = GAMESTATE:GetCurrentSong():GetSongDir()
  }
  setmetatable(_GameEnv, {
    __index = _G,
    __call = function(self, f)
      setfenv(f or 2, self)
      return f
    end
  })
  loadscript = function(path)
    return assert(loadfile(_GameEnv.songdir .. path))()
  end

  loadscript("lua/debug.lua")


  return Def.ActorFrame{
    OnCommand=function(self) self:sleep(9e9) end,
    loadscript("lua/judgment.lua"),
  }

else
  return Def.Actor{}
end
