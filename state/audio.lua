local random = require("utils.random")
local sound = require("tech.sound")


return Module("state.audio", function()
  return {
    music = {
      sound.multiple("assets/sounds/music/doom.mp3", 0.1)[1],
      sound.multiple("assets/sounds/music/drone_ambience.mp3", 0.5)[1],
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

    play = function(self, source, this_sound, size)
      local limits = self.sound_sizes[size or "small"]
      assert(limits, "Incorrect sound size %s; sounds can be small, medium or large" % tostring(size))
      local x, y = unpack(source.position)
      this_sound.source:setPosition(x, y, 0)
      this_sound.source:setAttenuationDistances(unpack(limits))
      this_sound.source:setRolloff(2)
      this_sound.source:play()
    end,

    play_static = function(self, this_sound)
      this_sound.source:stop()
      if this_sound.source:getChannelCount() == 1 then this_sound.source:setRelative(true) end
      this_sound.source:play()
    end,
  }
end)
