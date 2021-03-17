local defer = {}

-- TODO: 
--   * Implement a deferral registry.
--   * Unit tests:
--     * a function that calls defer multiple times, they should execute in last-in-first-out order
--     * a function calls defer and then calls another function that calls defer
--     * recursive function calls should not mess with each other's defers

-- Call sets a function to be executed when the calling function returns.
-- Warning: This is a quick experimental implementation that does not support
-- more than one defer at a time.
function defer.Call(f: function)
    -- we want this to only run with the calling function returns
    -- and not any other functions it may be calling
    local deferer = debug.getinfo(2, "n")

    debug.sethook(function()
        local parent = debug.getinfo(2, "n")
        if parent.name == deferer.name  then
            -- call the deferred function
            f()

            -- remove the hook
            debug.sethook()
        end
    end, "r")
end

return defer