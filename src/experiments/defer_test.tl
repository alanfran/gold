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
            array[#array+1] = 6
            return
        end)
        
        local function two() 
            array[#array+1] = 2
            return
        end
        two()

        local function four()
            local function three()
                array[#array+1] = 3
            end
            three()

            array[#array+1] = 4
            return
        end
        four()

        array[#array+1] = 5
        return
    end

    doSomething()

    assert.Equal(t, {1,2,3,4,5,6}, array)
end