dice - a trivial cli dice roller
================================

This is a simple cli tool that can simulate arbitrary dice rolls for you. The
main goal was however to build something using using `yacc(1)` and `lex(1)`.

Usage
-----

This program reads form `stdin` and writes output to `stdout`.

To roll a dice, use the usual RPG notation, eg.  `3d6` means "roll three
six-sided dice". This tool is case insensitive, so `3d6` and `3D6` are
equivalent. If you want to roll only one dice, you can omit the dice quantity
(`1d6` is equivalent to `d6`).

You can also give postive constant values and use the `+` operator for addition.

If you want to roll multiple dice in one row, delimit the expressions with `;`.

If any input can not be interpreted, `<error>` will be written as a result.

Example:

    # input
    2d6
    100 + d10
    d10; d10; d10
    invalid input
    
    # output
    8
    104
    4; 5; 4
    <error>

Build
-----

This program was written on FreeBSD und uses BSD `make(1)` to build the
executable.

    make dice                   # build the executable
    
    make -D WITH_LIBEDIT dice   # build the executable with `libedit` based
                                # line editing
    
    make clean                  # remove build artifacts

