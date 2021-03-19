-- tl-test 0.2
--
-- Bringing a Go-like test-runner to Teal.
-- 
-- Features:
-- * run on a single file with "tl-test path/to/module"
-- * run for all _test.tl files in a directory
-- * run recursively with "tl-test ./...
-- 
-- TODO:
-- * run a subset of tests with a flag "--run TestFooWithBar", pattern matching
-- * handle multiple args
-- 
-- WONTDO:
-- * Windows support. Use WSL or some kind of bash emulator.

local testing = require("testing")
local errors = require("errors")

-- private fields for our implementation of T
local type privateT = record
    isFailed: boolean
    logLines: {string}
end

-- private factory for an implementation of testing.T and a table containing
-- its private fields
local function newT(): testing.T, privateT
    local t = {}
    local private = {
        isFailed = false,
        logLines = {}
    }
    
    function t.Log(msg: string)
        private.logLines[#private.logLines+1] = msg
    end

    function t.Fail()
        private.isFailed = true
    end

    function t.Error(msg: string)
        t.Log(msg)
        t.Fail()
    end

    function t.Errorf(msg: string, ...: any)
        t.Error(string.format(msg, ...))
    end

    function t.Failed(): boolean
        return private.isFailed
    end

    return t, private
end

-- NewT returns a new test context.
function testing.NewT(): testing.T
    -- do not return the private table
    local t, _ = newT()

    return t
end

-- runFile requires a file, runs any global Test functions, and prints the results.
function runModule(moduleName: string)
    -- the require keyword gets special treatment by the tl compiler
    -- so we need a less special reference to the function
    local dynamicRequire = require
    dynamicRequire(moduleName)

    local passes = 0
    local failures = 0

    local GLOBAL = _G as {string:function(testing.T)}

    for k,testFunction in pairs(GLOBAL) do
        if type(k) == "string" and 
        string.sub(k as string, 1, 4) == "Test" and 
        type(testFunction) == "function" then
            local t, private = newT()

            print(string.format("=== RUN   %s", k))

            testFunction(t)

            if t.Failed() then
                failures = failures + 1
                print(string.format("--- FAIL: %s", k))
            else
                passes = passes + 1
                -- TODO: add time it took to run
                print(string.format("--- PASS: %s", k))
            end

            -- TODO: learn the debug library and add line numbers to T:Log
            -- and T:Fail?
            for _, logLine in ipairs(private.logLines) do
                print(string.format("    %s", logLine))
            end

            -- delete this test from the global namespace so we don't run it again
            -- TODO: a more elegant test registry instead of ad-hoc run/print?
            GLOBAL[k] = nil
        end
    end

    if failures > 0 then
        print("FAIL")
    else
        print("PASS")
    end
end

function pathToModule(file: string): string
    -- HAVE: dir/filename.tl
    -- WANT: dir.filename
    
    -- trim off the .tl extension
    local module = string.sub(file, 1, #file-3)

    -- replace / with .
    module = string.gsub(module, "/", ".")

    return module
end

-- run can run all tests in a module or a directory of modules with recursion using ... notation.
-- Examples:
    --  dir/filename_test.tl    run a single *_test.tl module 
    --  dir/                    run every *_test.tl module in dir/
    --  dir/...                 run every *_test.tl module in dir/ and all subdirectories
function run(path: string): errors.Error
    if not path then
        return errors.New("please select a file or directory")
    end

    local command: string

    -- use recursive mode when the path ends with /...
    if string.sub(path, #path-3, #path) == "/..." then
        -- trim off the /... because find doesn't understand that notation
        path = string.sub(path, 1, #path-4)
        command = [[find ]]..path..[[ -type f -name "*_test.tl" ]]
    else   
        command = [[find ]]..path..[[ -maxdepth 1 -type f -name "*_test.tl"]]
    end

    -- run the command and save the output
    -- of newline delimited file paths
    local fileList = io.popen(command)
    -- each line is a filename
    for filePath in fileList:lines() do
        print(filePath)
        local module = pathToModule(filePath)
        runModule(module)
    end

    return nil
end


-- MAIN

-- tl-test teal/lib/error_test.tl
local err = run(arg[1])
if err then
    print(err.Error())
    os.exit(1)
end
os.exit(0)