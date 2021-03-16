-- errors module inspired by Go
local record errors
    -- Error is an interface type.
    record Error
        Error: function(): string
    end

    New: function(string): Error
    Newf: function(string, any): Error
    Unwrap: function(Error): Error
end

-- localize the Error type for brevity
local type Error = errors.Error

-- wrappedError provides type information for the compiler.
local type wrappedError = record
    Error: function(): string
    Unwrap: function(): Error
end

-- New returns a new Error based on the given message.
function errors.New(message: string): Error
    return {
        Error = function(): string
            return message
        end,
    }
end

-- New returns a new Error based on the given format string.
function errors.Newf(formatString: string, ...: any): Error
    local msg = string.format(formatString, ...)

    return errors.New(msg)
end

-- Wrap returns a new error that wraps another.
-- Example: 
--  local e = errors.Wrap(errors.New("cause"), "something happened")
--  e.Error() == "something happened: cause"
function errors.Wrap(sourceError: Error, message: string): Error
    if sourceError == nil then
        return errors.New(message)
    end

    return {
        Error = function(): string
            return string.format("%s: %s", message, sourceError.Error())
        end,
        Unwrap = function(): Error
            return sourceError
        end,
    }
end

-- Unwrap returns the error wrapped inside the given error, or nil if there is none.
function errors.Unwrap(err: Error): Error
    if (err as wrappedError).Unwrap == nil then
        return nil
    end

    return (err as wrappedError).Unwrap()
end

return errors