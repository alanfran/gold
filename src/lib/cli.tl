local errors = require("errors")

-- TODO: 
-- * --flag=foo syntax

local record cli
    record CLI
        Run: function(args: {string}): errors.Error
        Value: function(key: string): string, boolean
    end
    record Flag
        ShortName: string
        LongName: string
        Description: string
        Default: any
        -- Type: FlagType
    end
    record Command
        Name: string
        Func: function(args: {string}): errors.Error
    end
    -- enum FlagType
    --     "string"
    --     "number"
    --     "boolean"
    -- end

    New: function(flags: {Flag}, commands: {Command}): CLI
end

local type CLI = cli.CLI
local type Flag = cli.Flag 
local type Command = cli.Command

local type privateCLI = record
    commands: {string:Command}
    flags: {string:Flag}

    values: {string:string}
    positionalArgs: {string}
end

local function run(private: privateCLI, args: {string}): errors.Error
    local endOfOptions = false

    local len = #args
    local i = 1

    while true do
        if i > len then
            break
        end

        -- TODO: subcommand

        -- flags have 0 or 1 arguments, where booleans are set to true with no following value
        -- --real foo
        -- --someBoolean 
        if private.flags[args[i]] and not endOfOptions then
            -- TODO: if it's a boolean, set it to true

            if len < i + 1 then
                return errors.Newf("no value for %s", args[i])
            end

            local key = private.flags[args[i]].LongName

            private.values[key] = args[i+1]
            i = i + 2
        elseif args[i] == "--" then
            endOfOptions = true
            i = i+1
        else
            private.positionalArgs[#private.positionalArgs+1] = args[i]
            i = i+1
        end
    end
end

function cli.New(flags: {Flag}, commands: {Command}): CLI
    local c = {}
    local private = {
        commands = {},
        flags = {},
        values = {},
        positionalArgs = {}
    }

    for k,_ in ipairs(flags) do
        local shortFlag = "-"..flags[k].ShortName
        local longFlag = "--"..flags[k].LongName
        private.flags[shortFlag] = flags[k]
        private.flags[longFlag] = flags[k]
    end

    for k,_ in ipairs(commands) do
        private.commands[#private.commands+1] = commands[k]
    end

    function c.Run(args: {string}): errors.Error
        return run(private, args)
    end

    function c.Value(key: string): any, boolean
        if private.values[key] == nil then
            return nil, false
        end
        
        return private.values[key], true
    end

    return c
end

return cli