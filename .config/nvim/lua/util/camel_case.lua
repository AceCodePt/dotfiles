local M = {}

-- Define the core conversion function
-- This function takes a string and converts it to camelCase.
-- It handles snake_case, kebab-case, and space separated words.
-- e.g., "Hello world", "hello_world", "Hello-World" all become "helloWorld"
function M.to_camel_case(str)
	-- Step 1: Replace hyphens, underscores, and newlines with spaces.
	-- The hyphen must be at the end of the set to be treated as a literal.
	local s = str:gsub("[_\n-]", " ")

	-- Step 2: Capitalize the first letter of each word.
	s = s:gsub("(%w)(%w*)", function(first, rest)
		return first:upper() .. rest:lower()
	end)

	-- Step 3: Remove all spaces.
	s = s:gsub(" ", "")

	-- Step 4: Make the very first character lowercase.
	s = s:sub(1, 1):lower() .. s:sub(2)

	return s
end

-- Define a function to be called from the command and keymap.
-- It gets the visually selected text, applies the conversion,
-- and replaces the original selection.
function M.convert_selection_to_camel()
	local mode = vim.fn.mode()

	-- Get selection positions and normalize them to handle upward selection.
	local pos1 = vim.fn.getpos("'<")
	local pos2 = vim.fn.getpos("'>")
	local start_pos, end_pos
	if pos1[2] > pos2[2] or (pos1[2] == pos2[2] and pos1[3] > pos2[3]) then
		start_pos, end_pos = pos2, pos1
	else
		start_pos, end_pos = pos1, pos2
	end
	local start_line, start_col = start_pos[2], start_pos[3]
	local end_line, end_col = end_pos[2], end_pos[3]

	-- For block selections, process each line independently to preserve structure.
	if mode == "\22" then -- Check for block mode (Ctrl-V)
		local new_lines = {}
		for i = start_line, end_line do
			local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
			if line then
				local prefix = line:sub(1, start_col - 1)
				local middle = line:sub(start_col, end_col)
				local suffix = line:sub(end_col + 1)
				table.insert(new_lines, prefix .. M.to_camel_case(middle) .. suffix)
			end
		end
		vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)
	else -- Handle normal (v) and line (V) visual modes.
		local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
		if not lines or #lines == 0 then
			return
		end

		local selection_text
		if start_line == end_line then
			selection_text = lines[1]:sub(start_col, end_col)
		else
			local parts = {}
			table.insert(parts, lines[1]:sub(start_col))
			for i = 2, #lines - 1 do
				table.insert(parts, lines[i])
			end
			table.insert(parts, lines[#lines]:sub(1, end_col))
			selection_text = table.concat(parts, "\n")
		end

		local converted_text = M.to_camel_case(selection_text)

		vim.api.nvim_buf_set_text(0, start_line - 1, start_col - 1, end_line - 1, end_col, { converted_text })
	end
end

return M
