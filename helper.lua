
-- Tables

function add_unique(table, value)
    if not contains(table, value) then
        add(table, value)
    end

end

function contains(table, value)
    for _, v in ipairs(table) do
        if v == value then 
            return true
        end
    end
    return false
end

-- Queue

-- Queue implementation
Queue = {}
Queue.__index = Queue

-- Create a new queue
function Queue.new()
    local self = setmetatable({
        items = {}, -- The table to hold queue items
        head = 1,   -- Index of the first element
        tail = 1    -- Index of the next insertion point
    }, Queue)
    return self
end

-- Add an item to the end of the queue
function Queue:enqueue(item)
    self.items[self.tail] = item
    self.tail = self.tail + 1
end

function Queue:enqueue_unique(item)
    if not contains(self.items, item) then
        self.items[self.tail] = item
        self.tail = self.tail + 1
    end

end

-- Remove and return the item from the front of the queue
function Queue:dequeue()
    if self:isempty() then
        return nil
    end
    local item = self.items[self.head]
    self.items[self.head] = nil -- Remove reference
    self.head = self.head + 1
    return item
end

-- Check if the queue is empty
function Queue:isempty()
    return self.head == self.tail
end

-- Peek at the item at the front of the queue without removing it
function Queue:peek()
    if self:isempty() then
        return nil
    end
    return self.items[self.head]
end

-- Get the number of items in the queue
function Queue:size()
    return self.tail - self.head
end

------- TIMER

function timer(interval)
    local last_time = t()  -- Track the last time the function was called
    
    return function()
        local current_time = t()
        -- Check if the interval has passed
        if current_time - last_time >= interval then
            last_time = current_time  -- Update the last time to current time
            return true  -- Indicate that the interval has elapsed
        end
        return false  -- Indicate that the interval has not elapsed
    end
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function table_to_string(t)
    local output = ""
    local visited = {}
    
    local function process(value, indent, is_inline)
        indent = indent or 0
        is_inline = is_inline or false
        
        -- Create indentation
        local spaces = ""
        if not is_inline and indent > 0 then
            spaces = sub("                ", 1, indent)
            while #spaces < indent do
                spaces = spaces..spaces
            end
            spaces = sub(spaces, 1, indent)
        end
        
        -- Handle circular references
        if type(value) == "table" then
            if visited[value] then
                output = output..spaces.."--[[circular reference]]\n"
                return
            end
            visited[value] = true
        end
        
        -- Handle non-table values
        if type(value) ~= "table" then
            if type(value) == "string" then
                output = output..spaces..'"'..value..'"'
            else
                output = output..spaces..tostr(value)
            end
            if not is_inline then
                output = output.."\n"
            end
            return
        end
        
        -- Handle empty table
        local has_items = false
        for _ in pairs(value) do has_items = true; break end
        if not has_items then
            output = output..spaces.."{}"
            if not is_inline then
                output = output.."\n"
            end
            return
        end
        
        -- Special handling for surface_tiles
        if indent > 8 and #value == 1 and type(value[1]) == "table" and next(value[1]) ~= nil then
            process(value[1], indent, true)
            return
        end
        
        -- Check if it's an array-style table
        local is_array = true
        for k in pairs(value) do
            if type(k) ~= "number" or k < 1 or k > #value or flr(k) ~= k then
                is_array = false
                break
            end
        end
        
        if not is_inline then
            output = output..spaces
        end
        
        if is_array then
            -- Process array-style table
            output = output.."{\n"
            for i = 1, #value do
                local v = value[i]
                output = output..sub("                ", 1, indent + 2).."["..i.."] = "
                if type(v) == "table" then
                    process(v, indent + 2, true)
                    if i < #value then
                        output = output..",\n"
                    else
                        output = output.."\n"
                    end
                else
                    if type(v) == "string" then
                        output = output..'"'..v..'"'
                    else
                        output = output..tostr(v)
                    end
                    if i < #value then
                        output = output..",\n"
                    else
                        output = output.."\n"
                    end
                end
            end
            output = output..spaces.."}"
        else
            -- Process dictionary-style table
            output = output.."{\n"
            local first = true
            for k, v in pairs(value) do
                if not first then
                    output = output..",\n"
                end
                first = false
                
                local key_str
                -- Check if key is a valid identifier
                if type(k) == "string" then
                    local first_char = sub(k, 1, 1)
                    local first_ord = ord(first_char)
                    local valid = (first_ord >= 65 and first_ord <= 90) or
                                 (first_ord >= 97 and first_ord <= 122) or
                                 (first_ord == 95)
                    
                    if valid then
                        for i = 1, #k do
                            local c = ord(k, i)
                            if not ((c >= 65 and c <= 90) or
                                   (c >= 97 and c <= 122) or
                                   (c >= 48 and c <= 57) or
                                   (c == 95)) then
                                valid = false
                                break
                            end
                        end
                    end
                    
                    key_str = valid and k or "["..tostr(k).."]"
                else
                    key_str = "["..tostr(k).."]"
                end
                
                output = output..sub("                ", 1, indent + 2)..key_str.." = "
                if type(v) == "table" then
                    process(v, indent + 2, true)
                else
                    if type(v) == "string" then
                        output = output..'"'..v..'"'
                    else
                        output = output..tostr(v)
                    end
                end
            end
            output = output.."\n"..spaces.."}"
        end
        
        if not is_inline then
            output = output.."\n"
        end
    end
    
    process(t, 0)
    return output
end

-- Wrapper function that uses printh with all its options
function print_table(t, filename, overwrite, save_to_desktop)
    local output_str = table_to_string(t)
    
    if filename then
        printh(output_str, filename, overwrite, save_to_desktop)
    else
        printh(output_str)
    end
end

