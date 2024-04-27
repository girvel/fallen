local main_font

love.load = function()
  main_font = love.graphics.newFont("fonts/BigBlueTerm437NerdFontMono-Regular.ttf", 24)
end

love.draw = function()
  love.graphics.print("@", main_font, 400, 300)
end
