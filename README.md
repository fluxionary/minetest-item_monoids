# item_monoids

an API for controlling item properties via monoids. useful for
* enchantment mods
* applying penalties or boosts to dig speed and such, based on player attributes or other systems
* when modifying other metadata (e.g. the description) of an item.

### API

create a tool monoid:

```lua
local full_punch_monoid = item_monoids.make_monoid("full_punch", {
    predicate = function(itemstack) -- [optional] should this monoid apply to this stack?
        local def = itemstack:get_definition()
        return def and def.tool_capabilities and def.tool_capabilities.full_punch_interval
    end,
    get_default = function(itemstack) -- [optional] get the default value (otherwise nil)
        return itemstack:get_definition().tool_capabilities.full_punch_interval
    end,
    fold = function(values, default) -- combine the values
        local value = default
        for _, other_value in pairs(values) do
            value = value * other_value
        end
        return value
    end,
    apply = function(full_punch_interval, itemstack) -- [optional] apply the value to the stack
        local tool_capabilities = itemstack:get_tool_capabilities()
        tool_capabilities.full_punch_interval = full_punch_interval
        local meta = itemstack:get_meta()
        meta:set_tool_capabilities(tool_capabilities)
    end,
})

local player
local itemstack = player:get_wielded_item()
if should_slow_punch(player) then
    full_punch_monoid:add_change(itemstack, 4, "punch_penalty")  -- increases the full punch interval 4x
else
    full_punch_monoid:del_change(itemstack, "punch_penalty")
end
```

#### pitfalls

* be careful not to modify the *definition* of a tool, just tool metadata.
