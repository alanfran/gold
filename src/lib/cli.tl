local errors = require("errors")

local record cli
    record CLI
        Run: function(args: {string}): errors.Error
    end
    record Flag
        ShortName: string
        LongName: string
        Description: string
        Default: any
    end
    record Command
        Name: string
        Func: function(args: {string}): errors.Error
    end

    New: function(flags: {Flag}, commands: {Command}): CLI
end

local type Flag = cli.Flag 
local type Command = cli.Command

local type privateCLI = record
    commands: {string:Command}
    flags: {string:Flag}
end



local function run(private: privateCLI, args: {string}): errors.Error
    -- how to parse
    -- check arg[1] against the list of subcommands first
    -- then fall back to parsing the base flags
end

function cli.New(flags: {Flag}, commands: {Command}): cli
    local c = {}
    local private = {
        commands = {},
        flags = {},
    }

    for i,flag in ipairs(flags) do
        private.flags[#private.flags+1] = flags[i]
    end

    for i,command in ipairs(commands) do
        private.commands[#private.commands+1] = commands[i]
    end

    function c.Run(args: {string}): errors.Error
        return run(private, args)
    end

    return c
end

return cli