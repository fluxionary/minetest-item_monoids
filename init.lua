item_monoids = fmod.create()

local f = string.format

local ItemMonoid = futil.class1()

function ItemMonoid:_init(name, def)
	self._name = name
	self._predicate = def.predicate
	self._get_default = def.get_default
	self._fold = def.fold
	self._apply = def.apply
end

function ItemMonoid:_get_values(meta)
	local key = f("tm:%s", self._name)
	return minetest.deserialize(meta:get_string(key)) or {}
end

function ItemMonoid:_set_values(meta, values)
	local key = f("tm:%s", self._name)
	meta:set_string(key, minetest.serialize(values))
end

function ItemMonoid:add_change(itemstack, value, id)
	if self._predicate and not self._predicate(itemstack) then
		return
	end
	local meta = itemstack:get_meta()
	local values = self:_get_values(meta)
	values[id] = value
	self:_set_values(meta, values)
	local default
	if self._get_default then
		default = self._get_default(itemstack)
	end
	local folded = self._fold(values, default)
	if self._apply then
		self._apply(folded, itemstack)
	end
	return folded
end

function ItemMonoid:del_change(itemstack, id)
	if self._predicate and not self._predicate(itemstack) then
		return
	end
	local meta = itemstack:get_meta()
	local values = self:_get_values(meta)
	values[id] = nil
	self:_set_values(meta, values)
	local default
	if self._get_default then
		default = self._get_default(itemstack)
	end
	local folded = self._fold(values, default)
	if self._apply then
		self._apply(folded, itemstack)
	end
	return folded
end

function ItemMonoid:value(itemstack)
	if self._predicate and not self._predicate(itemstack) then
		return
	end
	local meta = itemstack:get_meta()
	local values = self:_get_values(meta)
	local default
	if self._get_default then
		default = self._get_default(itemstack)
	end
	return self._fold(values, default)
end

item_monoids.make_monoid = ItemMonoid
