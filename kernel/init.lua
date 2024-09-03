local kernel = {}

kernel.initialize = function()
  require("kernel.globals")()
  require("kernel.callbacks")()
end

return kernel
