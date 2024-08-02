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
      local x, y = unpack(-Query(State.player).position or -Vector.one * math.huge)
      love.audio.setPosition(x, y, 0)
      if self.disable_ambient then return end
      local current_track = self.current_music
      if -Query(current_track):isPlaying() then return end
      while #self.music > 1 and self.current_music == current_track do
        self.current_music = random.choice(self.music)
      end
      self:play_static(self.current_music)
    end,

    sound_sizes = {
      small = {
        1, 10,
      },
      medium = {
        7, 20,
      },
      large = {
        15, 30,
      },
    },

    play = function(self, source, sound, size)
      local limits = self.sound_sizes[size or "small"]
      assert(limits, "Incorrect sound size %s; sounds can be small, medium or large" % tostring(size))
      local x, y = unpack(source.position)
      sound:setPosition(x, y, 0)
      sound:setAttenuationDistances(unpack(limits))
      sound:setRolloff(2)
      sound:play()
    end,

    play_static = function(self, sound)
      if sound:getChannelCount() == 1 then sound:setRelative(true) end
      sound:play()
    end,
  }
end
