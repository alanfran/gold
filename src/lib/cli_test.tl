local testing = require("testing")
local assert = require("assert")

local cli = require("cli")


function TestNew(t: testing.T)

    local flags: {cli.Flag} = {
        {
            LongName = "flag",
            ShortName = "f",
        },
        {
            LongName = "thing",
            ShortName = "t",
        },
        {
            LongName = "unused",
            ShortName = "u",
        },
    }

    -- expect:
    -- generated help message

    local runner = cli.New(flags, {})
    local err = runner.Run({"test", "-f", "value", "--thing", "ok", "quoted string1", "--", "--unused", "posarg3"})
    assert.Nil(t, err)


    -- test flag parsing

    local value, ok = runner.Value("flag")
    assert.Equal(t, true, ok)
    assert.Equal(t, "value", value)

    value, ok = runner.Value("thing")
    assert.Equal(t, true, ok)
    assert.Equal(t, "ok", value)

    value, ok = runner.Value("unused")
    assert.Equal(t, false, ok)
    assert.Equal(t, nil, value)

    value, ok = runner.Value("zarf")
    assert.Equal(t, false, ok)
    assert.Equal(t, nil, value)

    -- positional arguments
    
    -- value, ok = runner.Arg(1)
    -- assert.Equal(t, true, ok)
    -- assert.Equal(t, "quoted string1", value)
end