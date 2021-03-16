local testing = require("testing")
local oldAssert = assert
local assert =  require("assert")

local unsafe = require("unsafe")

function TestCall(t: testing.T)
    local testCases = {
        {
            f = function() 
                oldAssert(2+2 == 4)
            end,
            shouldError = false,
            expectedErrorSubstring = "",
        },
        {
            f = function() 
                oldAssert(2+2 == 5)
            end,
            shouldError = true,
            expectedErrorSubstring = "assertion failed!",
        },
        {
            f = function() 
                error("foobar")
            end,
            shouldError = true,
            expectedErrorSubstring = "foobar",
        },
        {
            f = function() 
                string.format("this should error %v")
            end,
            shouldError = true,
            expectedErrorSubstring = "bad argument #2 to 'format'",
        },
    }

    for _, testCase in ipairs(testCases) do

        local err = unsafe.Call(testCase.f)
        
        if testCase.shouldError then
            assert.NotNil(t, err)
            assert.Contains(t, err.Error(), testCase.expectedErrorSubstring)

            -- uncomment for debugging
            -- t:Log(err.Error())
        else
            assert.Nil(t, err)
        end
    end
end