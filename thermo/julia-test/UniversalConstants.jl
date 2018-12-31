__precompile__()

module UniversalConstants
export getUniversalConstant,getUniversalConstantList

UniversalConstantDict = Dict{String,Real}("standardAccelerationOfGravity" => 9.80665,
"avogadroConstant" => 6.02214199e+23,
"boltzmannConstant" => 1.3806503e-23,
"molarGasConstant" => 8.314472,
"plankConstant" =>6.626070150e-34,
"speedOfLightInVacuum"=> 299792458,
"standardAccelerationOfGravity"=> 9.80665,
"idealGasStateReferencePressure"=> 101325)

getUniversalConstant(str::String) = UniversalConstantDict[str]
getUniversalConstantList()= collect(keys(UniversalConstantDict))
end  