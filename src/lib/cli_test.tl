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
            LongName = "unused3",
            ShortName = "u",
        },
        {
            LongName = "bool",
            ShortName = "b",
            Type = "boolean"
        },
        {
            LongName = "defaulter1",
            ShortName = "d",
            Default = "unset_default_value"
        },
    }

    -- expect:
    -- generated help message

    local runner = cli.New(flags, {})

    -- parse a mix of positional args and flags
    -- contains boolean with 0 args
    -- contains "--" followed by a flag that should be parsed as a positional arg
    local err = runner.Run({"test1", "-f", "value", "--thing", "ok", "--bool", "quoted string2", "--", "--unused3", "posarg4"})
    assert.Nil(t, err)


    -- test flag parsing

    local value, ok = runner.Value("flag")
    assert.True(t, ok)
    assert.Equal(t, "value", value)

    value, ok = runner.Value("thing")
    assert.True(t, ok)
    assert.Equal(t, "ok", value)

    value, ok = runner.Value("unused")
    assert.Equal(t, false, ok)
    assert.Equal(t, nil, value)

    value, ok = runner.Value("zarf")
    assert.Equal(t, false, ok)
    assert.Equal(t, nil, value)

    value, ok = runner.Value("bool")
    assert.True(t, ok)
    assert.Equal(t, true, value)

    -- positional arguments
    
    assert.Equal(t, {"test1", "quoted string2", "--unused3", "posarg4"}, runner.Args())

    value, ok = runner.Arg(1)
    assert.True(t, ok)
    assert.Equal(t, "test1", value)

    value, ok = runner.Arg(2)
    assert.True(t, ok)
    assert.Equal(t, "quoted string2", value)

    value, ok = runner.Arg(3)
    assert.True(t, ok)
    assert.Equal(t, "--unused3", value)

    value, ok = runner.Arg(4)
    assert.True(t, ok)
    assert.Equal(t, "posarg4", value)

    -- default value
    value, ok = runner.Value("defaulter1")
    assert.True(t, ok)
    assert.Equal(t, "unset_default_value", value)
end