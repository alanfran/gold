local testing = require("testing")

-- inspired by github.com/stretchr/testify

-- TODO:
--   * implement better printing for table types

local assert = {}

-- TODO: refactor into a deep module
local function deepEqual(a: any, b: any): boolean
    if type(a) ~= type(b) then
        return false
    end

    if type(a) == "string" then
        return a == b
    end

    if type(a) == "number" then
        return a == b
    end

    if type(a) == "table" then
        for k,v in pairs(a as table) do
            if not deepEqual((a as table)[k], (b as table)[k]) then
                return false
            end
        end
    end

    if type(a) ~= "table" then
        -- TODO: replace panic with error return
        error(string.format("Unexpected type: ", type(a)))
        return false
    end

    return true
end

-- Equal fails the test if the expected and actual values are not equal.
function assert.Equal(t: testing.T, expected: any, actual: any)
    if not deepEqual(expected, actual) then
        t.Error(string.format(
            "Not equal: \nexpected: %s\nactual: %s", expected, actual
        ))
    end
end

-- NotEqual fails the test if the expected and actual values are equal.
function assert.NotEqual(t: testing.T, expected: any, actual: any)
    if deepEqual(expected, actual) then
        t.Error(string.format(
            "%s is equal to %s", expected, actual
        ))
    end
end

-- Nil fails the test if the value is not nil.
function assert.Nil(t: testing.T, a: any)
    if a ~= nil then
        t.Error("expected value to be nil")
    end
end

-- NotNil fails the test if the value is nil.
function assert.NotNil(t: testing.T, a: any)
    if a == nil then
        t.Error("expected value to not be nil")
    end
end

-- True fails the test if the value is false.
function assert.True(t: testing.T, a: boolean)
    if not a then
        t.Error(string.format("Should be true: %q", a))
    end
end

-- False fails the test if the value is true.
function assert.False(t: testing.T, a: boolean)
    if a then
        t.Error(string.format("Should be false: %q", a))
    end
end

-- Contains fails the test if the haystack does not contain a value equal to
-- the needle.
function assert.Contains(t: testing.T, haystack: any, needle: any)
    local tHaystack = type(haystack)
    local tNeedle = type(needle)

    if tHaystack == "string" then
        if tNeedle ~= "string" then
            t.Error("wrong type for needle: expected string")
            return
        end
        
        local matches = string.match(haystack as string, needle as string)
        if not matches then
            t.Errorf([[%s does not contain %s]], haystack, needle)
            return
        end
    elseif tHaystack == "number" then
        t.Error("unsupported: a number is not a collection")
        return
    elseif tHaystack == "function" then
        t.Error("unsupported type: a function is not a collection")
        return
    elseif tHaystack == "table" then
        local found = false
        for _,v in pairs(haystack as table) do
            if deepEqual(v, needle) then
                found = true
                break
            end
        end
        if not found then
            t.Errorf("collection did not contain %s", needle)
            return
        end
        return
    else
        t.Errorf("unrecognized type: %s", tHaystack)
    end
end

return assert