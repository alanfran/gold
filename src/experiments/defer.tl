local defer = {}

local registry: {number:{function}} = {}

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
    end
end

function tracebackHeight(): number
    local traceback = debug.traceback()

    local lines = {}
    for s in string.gmatch(traceback, "[^\r\n]+") do
        lines[#lines+1] = s
    end

    return #lines
end

-- Call sets a function to be executed when the calling function returns.
-- Warning: This is a quick experimental implementation that does not support
-- more than one defer at a time.
function defer.Call(f: function)
    local funcMask = "f"
    local returnMask = "r"

    -- we want to get the traceback height so we can tell when to execute the deferred function
    local n = tracebackHeight()

    -- set up our registry hook if it isn't active
    if debug.gethook() == nil then
        local hook = function()
            -- get the stack trace
            local n2 = tracebackHeight()
            popAll(n2)

        end
        debug.sethook(hook, returnMask)
    end

    -- push the function onto the stack to be executed when the calling function returns
    push(n, f)
end

return defer