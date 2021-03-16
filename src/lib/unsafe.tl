local unsafe = {}

local errors = require("errors")

-- Call executes the given function and catches and returns any error that is 
-- thrown. The function return value is ignored, so you should use a lambda
-- function and closure semantics.
-- 
-- Example:
-- 
--     local err = unsafe.Call(function()
--        local _ = string.format("this will throw an error %v")
--     end)
-- 
--     print(err)
--     -- [string "your.module"]:10: bad argument #2 to 'format' (no value)
function unsafe.Call(f: function): errors.Error
    local ok, errorMessage = pcall(f)
    if not ok then
        return errors.New(errorMessage as string)
    end

    return nil
end

return unsafe