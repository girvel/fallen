describe("lib.type", function()
  _G.Keyword = require("lib.keyword")
  local typex = require("lib.type")

  it("remembers parent factory", function()
    local custom_type = typex .. function(parent_type, value)
      return {
        parent_type = parent_type,
        value = value,
        double_value = value * 2,
      }
    end

    assert.same(
      {
        __type = custom_type,
        parent_type = custom_type,
        value = 10,
        double_value = 20,
      },
      custom_type(10)
    )
  end)
end)
