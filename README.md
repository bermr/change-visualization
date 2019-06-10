# Package changesmap

##Introduction

With the changesmap package the user is able to directly visualize the changes happening in a simulation. The ChangeMap type is similar to the Map type, defined in the base package.
This tool was developed as a package for [TerraME](https://github.com/TerraME/terrame/wiki), a modeling and simulation platform developed by INPE.
The code of this package is open-source and is available in the [project page at GitHub](https://github.com/bermr/changesmap).

##Classes

This package defines one class, the ChangeMap.
With this map, the amount of change happening in each Cell of a CellularSpace can be visualized in three types: Moment, Accumulation and Trail.\
The moment map shows the change in each timestep. If some attribute's value at t is different from it's value at t - 1, there was change at that location.\
The accumulation map calculates the change in each Cell at every timestep and adds to some sort of stack. At the end of the simulation, the cells with the most value change will have the same color.\
The trail map uses colors to show how long has the change happened in a Cell. As time goes by, a Cell with no change loses it's color and the ones with change gets the maximum color again.

##Installation

 To use any of the functions and types in this [package](https://github.com/TerraME/terrame/wiki/Packages), you must first download and install this package into your TerraME platform. This package is available for download on the releases tab of the git hub project.

 After downloading the .zip file, open the TerraME platform, select "install new package" and choose the "changesmap.zip" file. To be able to use an installed package in your programs, you must first import it using:
> import("changesmap")
