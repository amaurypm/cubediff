#!/usr/bin/env julia

using ArgParse
using Images
using Printf
import Base.-

function parse_commandline()
    s = ArgParseSettings()
    s.description = "Subtract two electrostatic potential maps, contained in Gaussian cube files, and generate a new electrostatic potential map with the difference."
    s.version = "1.0"
    s.add_version = true

    @add_arg_table! s begin
        "map1"
            help = "target electrostatic potential map"
            required = true
        "map2"
            help = "reference electrostatic potential map"
            required = true
    end

    return parse_args(s)
end

struct GaussianCube
    header::String
    size::Tuple{Int, Int, Int}
    voxels::Array{Float64, 3}
end

"""
    parse_cube(filename::String)

Parse a Gaussian cube phimap file, `filename`, containg a electrostatic potential map and return a proper GaussianCube object.
"""
function parse_cube(filename::String)
    counter = 0
    header = ""
    (x, y, z) = (0, 0, 0)
    natoms = 1
    voxels = Float64[]
    open(filename, "r") do input_file
        for line in eachline(input_file)
            counter += 1
            if counter <= 6 + natoms
                header *= (line * "\n")
                if counter == 3
                    natoms = parse(Int, split(line)[1])
                elseif counter == 4
                    x = parse(Int, split(line)[1])
                elseif counter == 5
                    y = parse(Int, split(line)[1])
                elseif counter == 6
                    z = parse(Int, split(line)[1])
                end

            else
                line = strip(line)
                for field in split(line)
                    push!(voxels, parse(Float64, field))
                end
            end
        end
    end
    if x*y*z != length(voxels)
        write(stderr, "ERROR: Number of voxels read from $filename does not correspond with map dimensions.")
        exit(1)
    end
    voxels = reshape(voxels, x, y, z)
    GaussianCube(header, (x,y,z), voxels)
end

"""
    write_cube(filename::String, cube::GaussianCube)

Write a electrostatic map, contained in a GaussianCube object, into a file named `filename`, in a Gaussian cube format.
"""
function write_cube(filename::String, cube::GaussianCube)
    open(filename, "w") do output_file
        write(output_file, cube.header)
        counter = 0
        for voxel in cube.voxels
            counter += 1
            @printf(output_file, "%13.5e", voxel)
            if counter % 6 == 0
                write(output_file, "\n")
            elseif counter % cube.size[1] == 0
                counter = 0
                write(output_file, "\n")
            end
        end
    end
end

function -(cube1::GaussianCube, cube2::GaussianCube)
    header = cube1.header
    dimensions = cube1.size
    tmp_map = cube1.voxels
    if cube2.size != cube1.size
        tmp_map = cube1.voxels - imresize(cube2.voxels, dimensions)
    else
        tmp_map = cube1.voxels - cube2.voxels
    end

    GaussianCube(header, dimensions, tmp_map)
end

function main()
    parsed_args = parse_commandline()
    if isfile(parsed_args["map1"]) && isfile(parsed_args["map2"])
        cube1 = nothing
        cube2 = nothing
        try
            cube1 = parse_cube(parsed_args["map1"])
            cube2 = parse_cube(parsed_args["map2"])
        catch
            write(stderr, "ERROR: Couldn't parse provided map files, please check they are proper Gaussian cube files.")
            exit(1)
        end

        diff_cube = cube1 - cube2
        output_filename = joinpath(dirname(parsed_args["map1"]), "diff_"*splitext(basename(parsed_args["map1"]))[1]*"_"*parsed_args["map2"])
        write_cube(output_filename, diff_cube)
    else
        write(stderr, "ERROR: At least one of the provided file names does not correspond with a real file.\n")
        exit(1)
    end
end

main()
