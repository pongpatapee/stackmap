local find_map = function(lhs)
	local maps = vim.api.nvim_get_keymap("n")
	for _, value in ipairs(maps) do
		if value.lhs == lhs then
			return value
		end
	end
end

describe("stackmap", function()
	before_each(function()
		require("stackmap")._clear()
		pcall(vim.keymap.del, "n", "asdfasdf")
	end)

	it("can be required", function()
		require("stackmap")
	end)

	it("can push single mapping", function()
		require("stackmap").push("test1", "n", {
			asdfasdf = "echo 'this is test1'",
		})

		local found = find_map("asdfasdf")

		assert.are.same("echo 'this is test1'", found.rhs)
	end)

	it("can push multiple mappings", function()
		local rhs = "echo 'this is a test'"

		require("stackmap").push("test1", "n", {
			["asdf_1"] = rhs .. "1",
			["asdf_2"] = rhs .. "2",
		})

		local found_1 = find_map("asdf_1")
		assert.are.same(rhs .. "1", found_1.rhs)

		local found_2 = find_map("asdf_2")
		assert.are.same(rhs .. "2", found_2.rhs)
	end)

	it("can pop a mapping, existing: no", function()
		require("stackmap").push("test1", "n", {
			asdfasdf = "echo 'this is test1'",
		})

		require("stackmap").pop("test1")
		assert.are.same(find_map("asdfasdf"), nil)
	end)
end)
