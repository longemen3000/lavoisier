#thermo module, meta/package to reference all other subpackages
module Thermo
include("UniversalConstants.jl") #provides constants
include("Compounds.jl") #provides an structure to store and retrieve compound properties
end
