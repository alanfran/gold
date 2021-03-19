local testing = require("testing")

-- module under test
local assert = require("assert")

-- TODO: more test cases covering all root types: string, number, table, function

function TestEqual(t: testing.T)
    local testCases = {
        {
            a = "foo",
            b = "foo",
            expectedFail = false,
        },
        {
            a = "foo",
            b = "bar",
            expectedFail = true,
        },
    }

    for _, testCase in ipairs(testCases) do
        local subtest = testing.NewT()
        assert.Equal(subtest, testCase.a, testCase.b)
        -- capture the result
        local actualFailed = subtest.Failed()

        -- use a standard comparison and T:Fail
        if testCase.expectedFail ~= actualFailed then
            t.Errorf("expected: %s  actual: %s", testCase.expectedFail, actualFailed)
        end
    end
end

function TestNotEqual(t: testing.T)
    local testCases = {
        {
            a = "foo",
            b = "foo",
            expectedFail = true,
        },
        {
            a = "foo",
            b = "bar",
            expectedFail = false,
        },
    }

    for _, testCase in ipairs(testCases) do
        local subtest = testing.NewT()
        assert.NotEqual(subtest, testCase.a, testCase.b)
        -- capture the result
        local actualFailed = subtest.Failed()

        -- use a standard comparison and T:Fail
        if testCase.expectedFail ~= actualFailed then
            t.Errorf("expected: %s  actual: %s", testCase.expectedFail, actualFailed)
        end
    end
end

function TestTrue(t: testing.T)
    local testCases = {
        {
            a = true,
            expectedFail = false,
        },
        {
            a = false,
            expectedFail = true,
        },
    }

    for _, testCase in ipairs(testCases) do
        local subtest = testing.NewT()
        assert.True(subtest, testCase.a)
        -- capture the result
        local actualFailed = subtest.Failed()

        -- use a standard comparison and T:Fail
        if testCase.expectedFail ~= actualFailed then
            t.Errorf("expected: %s  actual: %s", testCase.expectedFail, actualFailed)
        end
    end
end

function TestFalse(t: testing.T)
    local testCases = {
        {
            a = true,
            expectedFail = true,
        },
        {
            a = false,
            expectedFail = false,
        },
    }

    for _, testCase in ipairs(testCases) do
        local subtest = testing.NewT()
        assert.False(subtest, testCase.a)
        -- capture the result
        local actualFailed = subtest.Failed()

        -- use a standard comparison and T:Fail
        if testCase.expectedFail ~= actualFailed then
            t.Errorf("expected: %s  actual: %s", testCase.expectedFail, actualFailed)
        end
    end
end

function TestNil(t: testing.T)
    local type case = record
        a: any
        expectedFail: boolean
    end

    local testCases: {case} = {
        {
            a = nil,
            expectedFail = false,
        },
        {
            a = "foo",
            expectedFail = true,
        },
        {
            a = 123,
            expectedFail = true,
        },
        {
            a = {key="value"},
            expectedFail = true,
        },
    }

    for _, testCase in ipairs(testCases) do
        local subtest = testing.NewT()
        assert.Nil(subtest, testCase.a)
        -- capture the result
        local actualFailed = subtest.Failed()

        -- use a standard comparison and T:Fail
        if testCase.expectedFail ~= actualFailed then
            t.Errorf("expected: %s  actual: %s", testCase.expectedFail, actualFailed)
        end
    end
end

function TestNotNil(t: testing.T)
    local type case = record
        a: any
        expectedFail: boolean
    end

    local testCases: {case} = {
        {
            a = nil,
            expectedFail = true,
        },
        {
            a = "foo",
            expectedFail = false,
        },
        {
            a = 123,
            expectedFail = false,
        },
        {
            a = {key="value"},
            expectedFail = false,
        },
    }

    for _, testCase in ipairs(testCases) do
        local subtest = testing.NewT()
        assert.NotNil(subtest, testCase.a)
        -- capture the result
        local actualFailed = subtest.Failed()

        -- use a standard comparison and T:Fail
        if testCase.expectedFail ~= actualFailed then
            t.Errorf("expected: %s  actual: %s", testCase.expectedFail, actualFailed)
        end
    end
end

function TestContains(t: testing.T)
    local type case = record
        haystack: any
        needle: any
        expectedFail: boolean
    end

    local testCases: {case} = {
        {
            haystack = "this is a string",
            needle = "a string",
            expectedFail = false,
        },
        {
            haystack = "this is a string",
            needle = "this string is not in the haystack",
            expectedFail = true,
        },
        {
            -- TODO: check the error message in the assertions below
            haystack = "this should give us a wrong type error",
            needle = 1234,
            expectedFail = true,
        },
        {
            haystack = 1234,
            needle = 1234,
            expectedFail = true,
        },
        {
            haystack = {"bar"},
            needle = "bar",
            expectedFail = false,
        },
        {
            haystack = {"bar"},
            needle = "not in the array",
            expectedFail = true,
        },
        {
            haystack = {foo = "bar"},
            needle = "bar",
            expectedFail = false,
        },
        {
            haystack = {foo = "bar"},
            needle = "not in the map",
            expectedFail = true,
        },
        {
            haystack = {
                foo = {"array inside a map"}
            },
            needle = {"array inside a map"},
            expectedFail = false,
        },
    }

    for i, testCase in ipairs(testCases) do
        local subtest = testing.NewT()
        assert.Contains(subtest, testCase.haystack, testCase.needle)
        -- capture the result
        local actualFailed = subtest.Failed()

        -- use a standard comparison and T:Fail
        if testCase.expectedFail ~= actualFailed then
            t.Errorf("i: %d  expected: %s  actual: %s",i, testCase.expectedFail, actualFailed)
        end
    end
end