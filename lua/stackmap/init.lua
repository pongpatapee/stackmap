local M = {}

--[[
# Functions we need
- vim.keymap.set({mode}, {lhs}, {rhs}, {opts})                *vim.keymap.set()*

- nvim_get_keymap({mode})                                    *nvim_get_keymap()* 
^^ This is accessed via vim.api 

--]]

--[[
Example usecase
---------------
lua require("stackmap").push("debug_mode", {...})
...

lua require("stackmap").pop("debug_mode")

--]]

M._stack = {}

local find_mapping = function(maps, lhs)
	for _, value in ipairs(maps) do
		if value.lhs == lhs then
			return value
		end
	end
end

M.push = function(name, mode, mappings)
	local maps = vim.api.nvim_get_keymap("n")

	local existing_maps = {}
	for lhs, rhs in pairs(mappings) do
		local existing = find_mapping(maps, lhs)
		if existing then
			existing_maps[lhs] = existing
			-- table.insert(existing_maps, existing)
		end
	end

	M._stack[name] = {
		mode = mode,
		existing = existing_maps,
		mappings = mappings,
	}
	for lhs, rhs in pairs(mappings) do
		-- TODO: make a way to pass options
		vim.keymap.set(mode, lhs, rhs)
	end
end

M.push("debug_mode", "n", {
	[" gs"] = "<cmd>echo 'git status mapping'<CR>",
	[" go"] = "<cmd>echo 'Non-existent git mapping'<CR>",
})

M.pop = function(name)
	local state = M._stack[name]
	M._stack[name] = nil

	for lhs, rhs in pairs(state.mappings) do
		if state.existing[lhs] then
			-- Handle mapping that did exist
			-- TODO: handle options from the table
			vim.keymap.set(state.mode, lhs, state.existing[lhs].rhs)
		else
			-- Handle mapping that did not exist
			vim.keymap.del(state.mode, lhs)
		end
	end
end

M._clear = function()
	M._stack = {}
end

return M
