Gold
===

A collection of modules that make writing [Teal](https://github.com/teal-language/tl) feel more like [Go](https://golang.org/).

## Library

* `testing` - exports a test context type
* `assert` - easy assertions for tests 
* `errors` - exports an error interface and common functions
* `unsafe` - provides the ability to catch lua errors within a lambda and return them as values

## Tools
* `tl-test` - a simple test runner for the `testing.T` interface. Can run all test functions in a single file, or in all `*_test.tl` files under a directory recursively with the `path/...` notation. See `src/lib` for example test files.

## Experiments
 * `defer` - set a function to be executed when the calling function returns

## Notes

* Interfaces can be emulated with record types. See `src/lib/errors.tl` for an example.

## Requirements
* `tl` - the Teal compiler
    
    $ luarocks install tl