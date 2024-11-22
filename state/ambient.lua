local sound = require("tech.sound")


local ambient, module_mt, static = Module("state.ambient")

ambient._base = static {
  music = static .. {
    sound("assets/sounds/music/doom.mp3", 0.1),
    sound("assets/sounds/music/drone_ambience.mp3", 0.5),
  },

  update = static .. function(self)
    local x, y = unpack(-Query(State.player).position or -Vector.one * math.huge)
    love.audio.setPosition(x, y, 0)
    if self.disabled then return end
    local current_track = self.current_music
    if current_track and current_track.source:isPlaying() then return end
    while #self.music > 1 and self.current_music == current_track do
      self.current_music = Random.choice(self.music)
    end
    love.audio.play(self.current_music.source)
  end,
}

module_mt.__call = function(_)
  return Table.extend({
    current_music = nil,
    disabled = false,
  }, ambient._base)
end

return ambient
