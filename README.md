# Lavoisier Chemical Engineering Process Simulator

## What?

Lavoisier pretends to be a chemical process simulator, using numpy and the python ecosystem to provide a CAPE-OPEN-compatible system of sofware and tools.

## Why?
at this moment, there is no such thing as a chemical process simulator in python. we are here to provide that.

## How?
By leveraging the computational power of numpy. engineers around the world are familiarized with python and numpy, and we'll try to bring those tools to the world of chemical engineering.

The following components are necessary for a minimum viable product:
* Chemical component database: Leveraging the power of the HDF5 standard
* Material object component: responsible for holding the chemical data of a flow.
* Thermodynamic engine:  responsible for the temperature and presure dependent properties and phase calculation. we would want to provide at least some cubic models (Peng-robinson and Soave-Redling-Kwong), some activity models (NRTL, Wilson), and the technical standards for water. if we have time and technical skill, a we may implement a WR-SAFT solver (just doing that has a merit of his own)
* Solver engine: responsible of calculating solutions for the ecuations (numpy has us covered right here)
* Unit operation module: Operations on the material flows, like mixing, reactors, pumps, compressors, etc

After those blocks are done, the second part of the simulation enviroment development starts, we need to build the following:

* A flowsheet executive: capable of converting a flow diagram in a set of ecuations to solve
* a GUI, for easy flowsheeting of the chemical process.

## When?
I can't answer that yet.

## Who?
at the time, we are two (2) chemical engineering graduates, from the University of Concepción, Chile.

## Can i join?

Of course!, we dont have nothing, but you can start by reading the cape-open implementation.any help would be appreciated! 





