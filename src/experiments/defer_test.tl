local testing = require("testing")
local assert = require("assert")

local defer = require("experiments.defer")

function TestDefer(t: testing.T)
    local array: {number} = {}
    
    -- define a function that fills the array with values expected if defer
    -- behaves correctly. this should involve at least 2 layers of returns
    local function doSomething()
        
        array[#array+1] = 1
        
        defer.Call(function()
            -- print("should execute third")
            array[#array+1] = 6
            return
        end)

        defer.Call(function()
            -- print("should execute second")
            array[#array+1] = 5
            return
        end)

        array[#array+1] = 2

        local function anotherThing()
            defer.Call(function() 
                -- print("should execute first")
                array[#array+1] = 4
            end)
            array[#array+1] = 3
        end
        anotherThing()

        return
    end

    doSomething()

    assert.Equal(t, {1,2,3,4,5,6}, array)
end

--     with defer, 1000 iterations took: 2.366 ms
--     without defer, 1000 iterations took: 0.035 ms
function TestDeferBenchmark(t: testing.T)

    local function doSomethingWithDefer()
        local function f(): number
            local x, y = 1, 1
            return x + y
        end

        defer.Call(function()
            local x, y = 1, 1
            _G.assert(x + y == 2)
            return
        end)

        local x, y = 1, 1
        _G.assert(x + y == 2)

        -- let's say your average function makes 5 calls itself
        -- that's 5 returns our hook is catching
        for i=1,5 do
            f()
        end 

        return
    end

    local function doSomethingWithoutDefer()
        
        local function f(): number
            local x, y = 1, 1
            return x + y
        end
        f()

        local x, y = 1, 1
        _G.assert(x + y == 2)

        for i=1,5 do
            f()
        end 

        return
    end

    local startTime = os.clock() 
    for i = 1,1000 do
        doSomethingWithDefer()
    end
    local endTime = os.clock()

    local withDefer = endTime - startTime
    t.Log(string.format("with defer, 1,000 iterations took: %s ms", withDefer*1000))



    startTime = os.clock()
    for i = 1,1000 do
        doSomethingWithoutDefer()
    end
    endTime = os.clock()

    local withoutDefer = endTime - startTime
    t.Log(string.format("without defer, 1,000 iterations took: %s ms", withoutDefer*1000))
    t.Log(string.format("overhead ratio: %s", withDefer/withoutDefer))
end