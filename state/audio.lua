local random = require("utils.random")


return function()
  return {
    music = {
      Common.volumed_sounds("assets/sounds/music/doom.mp3", 0.1)[1],
      Common.volumed_sounds("assets/sounds/music/drone_ambience.mp3", 0.5)[1],
    },
    current_music = nil,
    disable_ambient = false,

    update = function(self)
      local x, y = unpack(-Query(State.player).position or {-999, -999})
      love.audio.setPosition(x, y, 0)
      if self.disable_ambient then return end
      local current_track = self.current_music
      if -Query(current_track):isPlaying() then return end
      while #self.music > 1 and self.current_music == current_track do
        self.current_music = random.choice(self.music)
      end
      self.current_music:play()
    end,

    play = function(self, source, sound, min, max)
      local x, y = unpack(source.position)
      sound:setPosition(x, y, 0)
      sound:setAttenuationDistances(min or 5, max or 20)
      sound:play()
    end,
  }
end
