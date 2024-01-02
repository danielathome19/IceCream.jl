# IceCream.jl — Never use println() to debug in Julia again.

IceCream.jl is a Julia port of the [icecream](https://github.com/gruns/icecream) library for Python.

Do you ever use `print()` or `println()` to debug your code? Of course you do. IceCream, or `@ic` for short, makes print debugging a little sweeter.

`@ic()` is like `println()`, but better:

* It prints both expressions/variable names and their values.
* It's 60% faster to type.
* Data structures are pretty printed.
* Output is syntax highlighted.
* It optionally includes program context: filename, parent class, parent function, and line number.

```julia
using IceCream

@ic "Hello, world!"
@ic_log "Hello, world!"
```

```sh
>>> ic| program.jl:Main:3 > ("Hello, world!", "Hello, world!")
>>> ic| "Hello, world!"
```

## Installation

```julia
] add IceCream
```

## Usage

```julia
using IceCream
@ic "Hello, world!"  # or @ic("Hello, world!")
```

## Documentation

IceCream.jl offers a variety of functions:

* `@ic`: Debugging macro to print variable names and their values.
* `@ic_log`: Macro for logging with optional color support.
* `ic_configure`: Function to configure global settings.
* `ic_configure_color`: Set the color of the printed output.
* `ic_configure_single`: Configure individual settings.
* `ic_enable`: Enable IceCream debugging.
* `ic_disable`: Disable IceCream debugging.

### Configuration options

* `include_context`: Enable/disable the inclusion of program context (must be enabled for the following options to take effect).
* `include_datetime`: Enable/disable the inclusion of the current date and time.
* `include_absolute_path`: Enable/disable the inclusion of the absolute path to the file.
* `include_filename`: Enable/disable the inclusion of the filename.
* `include_modulename`: Enable/disable the inclusion of the module name.
* `include_methodname`: Enable/disable the inclusion of the method name.  (TODO: this is currently unsupported by Julia; instead, pass the method name as the first symbol to `@ic`; e.g., `@ic :myfunc "Hello"`.)
* `include_line_number`: Enable/disable the inclusion of the line number.
* `include_color`: Enable/disable the inclusion of color.
* `new_prefix`: Change the prefix used to indicate new output (default: `ic| `).
* `enabled`: Enable/disable IceCream debugging.