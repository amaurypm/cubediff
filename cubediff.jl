#!/usr/bin/env julia

using ArgParse

function parse_commandline()
    s = ArgParseSettings()
    s.description = "Subtract two electrostatic potential maps, contained in Gaussian cube files, and generate a new electrostatic potential map with the difference."
    s.version = "0.9"
    s.add_version = true

    @add_arg_table! s begin
        "--mute", "-m"
            help = "mute all output messages during program execution"
            action = :store_true
        "map1"
            help = "target electrostatic potential map"
            required = true
        "map2"
            help = "reference electrostatic potential map"
            required = true
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        println("  $arg  =>  $val")
    end
end

main()
