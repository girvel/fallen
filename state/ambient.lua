local sound = require("tech.sound")


--- @overload fun(): state_ambient
local ambient, module_mt, static = Module("state.ambient")

--- @class state_ambient
--- @field disabled boolean
--- @field _paused boolean
--- @field _current_music sound
local base = {
  music = {
    sound("assets/sounds/music/doom.mp3", 0.1),
    sound("assets/sounds/music/drone_ambience.mp3", 0.5),
    sound("assets/sounds/music/drone_1.mp3", 0.3),
    sound("assets/sounds/music/drone_2.mp3", 0.1),
  },

  --- @param self state_ambient
  --- @return nil
  update = function(self)
    if self.disabled or self._paused then return end
    local x, y = unpack(-Query(State.player).position or -Vector.one * math.huge)
    love.audio.setPosition(x, y, 0)
    local last_track = self._current_music
    if last_track and last_track.source:isPlaying() then return end
    while #self.music > 1 and self._current_music == last_track do
      self._current_music = Random.choice(self.music)
    end
    self._current_music:play()
  end,

  --- @param self state_ambient
  --- @param value boolean
  --- @return nil
  set_paused = function(self, value)
    self._paused = value
    if value then
      self._current_music:stop()
    else
      self._current_music:play()
    end
  end,
}

module_mt.__call = function(_)
  return Table.extend({
    disabled = false,
    _paused = false,
    _current_music = nil,
  }, base)
end

return ambient
