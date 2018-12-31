# Lavoisier thermodynamic design bases

Hi, if you are reading this, you are in an early stage of the project, there is a lot to do 
and the complexity is hard. here lies one of the cores of Lavoisier simulator, the thermodynamic engine.
This engine should be capable of providing solutions of temperature and pressure dependent properties for 
the entire list of material objects present in the simulation.

## Engine's pillars:

* Multicore: The engine should be capable of solving flash calculations (T-P , phi-P, phi-T) in each core. this 
can be accomplished by the multiprocessing python API.
* EOS-independent: The engine should be capable of using any EOS, providing the necessary interfase and methods. 
a general flash solver based on hemholtz energy (Hemholz Energy Lagrangian Dual, or HELD) is provided as the main model to implement
* Fast: Harder,Better, Faster, Stronger

## Selected EOS

If we are considering an 1.0 release, this engine should have at least the following EOS:

* Peng-Robinson: The oprah of the EOS, this bad boi is essencial and a bare minimum to have. a good option is to implement a general
Cubic EOS (VdW, VdW, RK, SRK, PR, others if necessary).For liquid density, rackett and costald are good options. A dealbreaker should be the inclusion of various mixing rules other than VdW.
* GERG 2008: Is the standard of natural gas (seriusly, is the standard ISO 20765-2:2015)
* IAPWS : Standard for water properties
* Saft-γ-Mie: Saft equations are one of the most significant breakthroughs in the stoudy of thermodynamic properties, shrinking the gap
between molecular simulations and general EOS. this dangerous boi can use a corresponding states method for his parameters, so
most molecules with the basic critical data can be modeled with this EOS, if there are no other fine-tuned disponible parameters.

## other EOS

* Activity models: a version of Aspen's ELECNRTL would be posible
* UNIFAC, UNIQUAC
* CPA EOS
