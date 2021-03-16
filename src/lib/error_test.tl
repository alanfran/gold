local testing = require("testing")
local assert = require("assert")

-- module under test
local errors = require("errors")

function TestSimpleError(t: testing.T)
    local testCases = {
        {message = "foo"},
        {message = "bar"},
        {message = "cannoli"}
    }

    for _, testCase in ipairs(testCases) do
        local e = errors.New(testCase.message)

        assert.Equal(t, testCase.message, e.Error())
    end
end

function TestFormattedError(t: testing.T)
    local testCases = {
        {
            error = errors.Newf("here's an easy %s", "one"),
            expected = "here's an easy one" 
        },
        {
            error = errors.Newf("here's a medium %s with %d, %d, %d", "one", 1, 2, 3),
            expected = "here's a medium one with 1, 2, 3" 
        },
    }

    for _, testCase in ipairs(testCases) do
        assert.Equal(t, testCase.expected, testCase.error.Error())
    end
end

function TestWrappedError(t: testing.T)
    local testCases = {
        {
            error = errors.Wrap(nil, "message0"),
            expected  = "message0"
        },
        {
            error = errors.Wrap(errors.New("error0"), "message0"),
            expected  = "message0: error0"
        },
        {
            error = errors.Wrap(
                errors.Wrap(errors.New("error0"), "message0"), 
                "message1"
            ),
            expected = "message1: message0: error0"
        },
        {
            error = errors.Wrap(
                errors.Wrap(
                    errors.Wrap(errors.New("message0"), "message1"), 
                    "message2"
                ),
                "message3"
            ),
            expected = "message3: message2: message1: message0"
        },
    }

    for _, testCase in ipairs(testCases) do
        assert.Equal(t , testCase.expected, testCase.error.Error())
    end
end

function TestErrorWithLineNumber(t: testing.T)

    -- NewErrorWithLineNumber returns an error that references the line number of the parent
    -- function call.
    --
    -- Example:
    -- 
    --     local err = FunctionThatCanError()
    --     print(err.Error())
    --     -- [..teal.lib.error_test:86] error message
    local function NewErrorWithLineNumber(msg: string): errors.Error
        local info = debug.getinfo(3, "lS")

        return errors.Newf("[%s:%s] %s", info.source, info.currentline, msg)
    end

    local function FunctionThatReturnsError(): errors.Error
        -- let's just fail
        local err = NewErrorWithLineNumber("hello world")
        return err
    end
    
    local e = FunctionThatReturnsError()

    assert.Equal(t, "[..src.lib.error_test:94] hello world", e.Error())
end