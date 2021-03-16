-- A testing module inspired by Go's testing package.

local record testing
    record T
        Log: function(self: T, msg: string)
        Fail: function(self: T)
        Error: function(self: T, msg: string)
        Errorf: function(self: T, msg: string, ...: any)
        Failed: function(self: T): boolean

        isFailed: boolean
        logLines: {string}
    end

    NewT: function(): T
end

-- Log prints a message to STDOUT after the test finishes.
function testing.T:Log(msg: string)
    -- append to the log lines for this test
    -- to be printed by the test runner
    self.logLines[#self.logLines+1] = msg
end

-- Fail marks the test as failed.
function testing.T:Fail()
    self.isFailed = true
end

function testing.T:Failed(): boolean
    return self.isFailed
end

-- Error is equivalent to calling Log and Fail
function testing.T:Error(msg: string)
    self:Fail()
    self:Log(msg)
end

function testing.T:Errorf(msg:string, ...: any)
    self:Error(string.format(msg, ...))
end

-- NewT creates a new test context.
function testing.NewT(): testing.T
    local t = setmetatable({
        isFailed = false,
        logLines = {},
    } as testing.T, { __index = testing.T })
    
    return t
end

return testing