item_monoids = fmod.create()

local f = string.format

local ItemMonoid = futil.class1()

function ItemMonoid:_init(name, def)
	self.name = name
	self.predicate = def.predicate
	self.get_default = def.get_default
	self.fold = def.fold
	self.apply = def.apply
end

function ItemMonoid:_get_values(meta)
	local key = f("tm:%s", self.name)
	return minetest.deserialize(meta:get_string(key)) or {}
end

function ItemMonoid:_set_values(meta, values)
	local key = f("tm:%s", self.name)
	meta:set_string(key, minetest.serialize(values))
end

function ItemMonoid:add_change(itemstack, value, id)
	if self.predicate and not self.predicate(itemstack) then
		return
	end
	local meta = itemstack:get_meta()
	local values = self:_get_values(meta)
	values[id] = value
	self:_set_values(meta, values)
	local default
	if self.get_default then
		default = self.get_default(itemstack)
	end
	local folded = self.fold(values, default)
	if self.apply then
		self.apply(folded, itemstack)
	end
	return folded
end

function ItemMonoid:del_change(itemstack, id)
	if self.predicate and not self.predicate(itemstack) then
		return
	end
	local meta = itemstack:get_meta()
	local values = self:_get_values(meta)
	values[id] = nil
	self:_set_values(meta, values)
	local default
	if self.get_default then
		default = self.get_default(itemstack)
	end
	local folded = self.fold(values, default)
	if self.apply then
		self.apply(folded, itemstack)
	end
	return folded
end

function ItemMonoid:value(itemstack, key)
	if self.predicate and not self.predicate(itemstack) then
		return
	end
	local meta = itemstack:get_meta()
	local values = self:_get_values(meta)
	if key then
		return values[key]
	end
	local default
	if self.get_default then
		default = self.get_default(itemstack)
	end
	return self.fold(values, default)
end

item_monoids.make_monoid = ItemMonoid
