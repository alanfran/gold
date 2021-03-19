local defer = {}

local registry: {number:{function}} = {}
local isHookSet = false

local function push(n: number, f: function)
    -- init logic

    if registry[n] == nil then
        registry[n] = {}
    end
    local len = #registry[n]
    registry[n][len+1] = f
end

local function popAll(n: number)
    -- validation
    if registry[n] == nil then
        return
    end

    local len = #registry[n]
    if len == 0 then
        return
    end

    -- execute the functions, Last In First Out
    for i=len,1,-1 do
        registry[n][i]()
    end

    registry[n] = nil

    -- cleanup

    -- if there are no more defers on the stack,
    -- remove our hook function to speed up the VM

    local len: number = 0
    for _,_ in pairs(registry) do
        len = len+1
    end
    
    if len == 0 then
        debug.sethook()
        isHookSet = false
    end
end

function stackHeight(): number
    -- find the bottom of the stack
    local n = 3
    while true do
        local info = debug.getinfo(n, "")
        if info == nil then
            return n
        end
        n = n + 1
    end
end

-- Call sets a function to be executed when the calling function returns.
-- Warning: This uses the debug library and may not work or break your code.
-- And any pending defers will slow down program execution significantly, eg: 70 times slower.
function defer.Call(f: function)
    local funcMask = "f"
    local returnMask = "r"

    -- we want to get the stack height so we can tell when to execute the deferred function
    local n = stackHeight()
    -- print(n)

    -- set up our registry hook if it isn't active
    if not isHookSet then
        local hook = function()
            -- get the stack trace
            local n2 = stackHeight()
            popAll(n2)

        end
        debug.sethook(hook, returnMask)
        isHookSet = true
    end

    -- push the function onto the stack to be executed when the calling function returns
    push(n, f)
end

return defer