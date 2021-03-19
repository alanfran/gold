-- A testing module inspired by Go's testing package.

local record testing
    record T
        Log: function(msg: string)
        Fail: function()
        Error: function(msg: string)
        Errorf: function(msg: string, ...: any)
        Failed: function(): boolean
    end

    NewT: function(): T
end

return testing