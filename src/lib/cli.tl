local errors = require("errors")

-- This module implements a simple command line argument parser with support
-- for flags and positional arguments.
local record cli
    record CLI
        Run: function(args: {string}): errors.Error
        Value: function(key: string): any, boolean
        Arg: function(n: integer): string, boolean
        Args: function(): {string}
    end
    record Flag
        ShortName: string
        LongName: string
        Description: string
        Default: any
        Type: FlagType
    end
    record Command
        Name: string
        Func: function(args: {string}): errors.Error
    end
    enum FlagType
        "string"
        "number"
        "boolean"
    end

    New: function(flags: {Flag}, commands: {Command}): CLI
end

local type CLI = cli.CLI
local type Flag = cli.Flag 
local type Command = cli.Command

local type privateCLI = record
    -- map from both short and long name to Command
    commands: {string:Command}
    -- map from both short and long name to Flag
    flags: {string:Flag}

    -- map from long name to value
    values: {string:any}
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

        -- TODO: subcommands

        -- parse flags
        if private.flags[args[i]] and not endOfOptions then
            local flag = private.flags[args[i]]
            local key = flag.LongName

            -- Boolean flags are a special case that can have 0 arguments.
            if flag.Type == "boolean" then
                if len > i and args[i+1] == "true" then
                    private.values[key] = true
                    i = i + 2
                elseif len > i and args[i+1] == "false" then
                    private.values[key] = false
                    i = i + 2
                else
                    private.values[key] = true
                    i = i + 1
                end
            else 
                -- every other flag type has 1 argument separated by a space
                if len < (i + 1) then
                    return errors.Newf("no value for %s", args[i])
                end
    
                private.values[key] = args[i+1]
                i = i + 2
            end
        elseif args[i] == "--" then
            endOfOptions = true
            i = i+1
        else
            private.positionalArgs[#private.positionalArgs+1] = args[i]
            i = i+1
        end
    end
end

local function copy(old: {string}): {string}
    local new = {}
    for k,v in ipairs(old) do
        new[k] = v
    end
    return new
end

function cli.New(flags: {Flag}, commands: {Command}): CLI
    local c = {}
    local private: privateCLI = {
        commands = {},
        flags = {},
        values = {},
        positionalArgs = {}
    }

    -- Initialization

    for k, flag in ipairs(flags) do
        local shortFlag = "-"..flag.ShortName
        local longFlag = "--"..flag.LongName

        -- add to flag registry
        private.flags[shortFlag] = flags[k]
        private.flags[longFlag] = flags[k]

        -- set default value
        private.values[flag.LongName] = flag.Default
    end

    for k,command in ipairs(commands) do
        private.commands[command.Name] = commands[k]
    end

    -- Method implementations

    function c.Run(args: {string}): errors.Error
        return run(private, args)
    end

    function c.Value(key: string): any, boolean
        if private.values[key] == nil then
            return nil, false
        end
        
        return private.values[key], true
    end

    function c.Arg(i: integer): string, boolean
        local len = #private.positionalArgs
        if i > len then
            return nil, false
        end

        return private.positionalArgs[i], true
    end

    function c.Args(): {string}
        -- return a copy so consumers can't mutate our private data
        return copy(private.positionalArgs)
    end

    return c
end

return cli