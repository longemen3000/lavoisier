__precompile__()
module Compounds

export Compound,getConstPropList,newCompound,
GetCompoundList,getConstPropList,property


StringPropertiesBaseDict = begin 
    Dict{String,Union{Missing,String}}(
    "ID"=>missing,
    "commonName"=>missing,
    "iupacName"=>missing,
    "casRegistryNumber"=>missing,
    "chemicalFormula"=>missing,
    "SMILESformula"=>missing,
    "compoundType"=>"Standard") #For future solid, ionic, bacterial and other interactions
end
ValuePropertiesBaseDict = begin
    Dict{String,Float64}(
    "molecularWeight"=>NaN,
    "criticalTemperature"=>NaN,
    "criticalPressure"=>NaN,
    "criticalVolume"=>NaN,
    "criticalCompressibilityFactor"=>NaN,
    "criticalDensity"=>NaN,
    "acentricFactor"=>NaN,
    "dipoleMoment"=>NaN,
    "parachor"=>NaN,
    "gyrationRadius"=>NaN,
    "associationParameter"=>NaN,
    "diffusionVolume"=>NaN,
    "vanderwaalsArea"=>NaN,
    "energyLennardJones"=>NaN,
    "lengthLennardJones"=>NaN,
    "normalBoilingPoint"=>NaN,
    "heatOfVaporizationAtNormalBoilingPoint"=>NaN,
    "normalFreezingPoint"=>NaN,
    "heatOfFusionAtNormalFreezingPoint"=>NaN,
    "liquidDensityAt25C"=>NaN,
    "liquidVolumeAt25C"=>NaN,
    "idealGasGibbsFreeEnergyOfFormationAt25C"=>NaN,
    "idealGasEnthalpyOfFormationAt25C"=>NaN,
    "standardFormationEnthalpySolid"=>NaN,
    "standardFormationEnthalpyLiquid"=>NaN,
    "standardFormationEnthalpyGas"=>NaN,
    "standardFormationGibbsEnergySolid"=>NaN,
    "standardFormationGibbsEnergyLiquid"=>NaN,
    "standardFormationGibbsEnergyGas"=>NaN,
    "standardEntropySolid"=>NaN,
    "standardEntropyLiquid"=>NaN,
    "standardEntropyGas"=>NaN,
    "triplePointTemperature"=>NaN,
    "triplePointPressure"=>NaN,
    "BornRadius"=>NaN,
    "charge"=>NaN,
    "StandardEnthalpyAqueousDilution"=>NaN,
    "StandardGibbsAqueousDilution"=>NaN)
end

ArrayPropertiesBaseDict = begin 
    Dict{String,Dict{String,Float64}}(
    "DebugConstants"=>Dict{String,Float64}(
    "empty"=>NaN)
)
end

struct Compound
    #stores an individual compound, and its constant properties
    StringProperties::Dict{String,Union{Missing,String}}
    ValueProperties::Dict{String,Float64}
    ArrayProperties::Dict{String,Dict{String,Float64}}
end

struct CompoundList
    #stores a set of compounds, and its constant properties
    Compounds::Array{Compound,1}
    CompoundsID::Array{String,1}
    #strArr:: Array{String,1}
end 

#Base extensions to structs
Base.length(S::CompoundList) = length(S.CompoundsID)
Base.iterate(S::CompoundList, state=1) = state > length(S) ? nothing : (S.compounds[state], state+1)


function Base.getindex(S::CompoundList, i)
1 <= i <= length(S) || throw(BoundsError(S, i))
return S.compounds[i]
end
function Base.getindex(list::CompoundList, prop::String)
    if haskey(ValuePropertiesBaseDict, prop)
        xxx = map(x->x.ValueProperties[prop],list.Compounds)
    elseif haskey(StringPropertiesBaseDict, prop) 
        xxx= map(x->x.StringProperties[prop],list.Compounds)
    elseif haskey(ArrayPropertiesBaseDict, prop)
        xxx= map(x->x.ArrayProperties[prop],list.Compounds)
    else throw("Property doesnt exist.")
    end
    return xxx
    end

function newCompound(StringProperties =StringPropertiesBaseDict, x2=ValuePropertiesBaseDict,x3=ArrayPropertiesBaseDict; ID::String = "") # not standard, but useful
    if ID==""
        return Compound(merge(StringPropertiesBaseDict,StringProperties),merge(ValuePropertiesBaseDict,x2),merge(ArrayPropertiesBaseDict,x3))  
    else
        xx = merge(StringPropertiesBaseDict,StringProperties)
        xx["ID"]=ID
        return Compound(xx,merge(ValuePropertiesBaseDict,x2),merge(ArrayPropertiesBaseDict,x3))  
    end
end



function getCompound(list::CompoundList)
return(list.Compounds)
end

function getCompound(list::CompoundList,ID::String="")
    if ID==""
    return(list.Compounds)
    else
        list.Compounds(ID)
    end
#SetCompoundProperty()
end

function newCompoundList(Compoundsz::Array{Compound})
    IDs = map(x->x.StringProperties["ID"],Compoundsz)
    if allunique(IDs) || throw("one or more IDs of the compound list are diferent.")
        return CompoundList(Compoundsz,IDs)
    else
        
   end
end


#function GetCompoundConstant(;props::Array{String};compIds::Array{String}=[])

function property(list::CompoundList,prop::String)
if haskey(ValuePropertiesBaseDict, prop)
    xxx = map(x->x.ValueProperties[prop],list.Compounds)
elseif haskey(StringPropertiesBaseDict, prop) 
    xxx= map(x->x.StringProperties[prop],list.Compounds)
elseif haskey(ArrayPropertiesBaseDict, prop)
    xxx= map(x->x.ArrayProperties[prop],list.Compounds)
else throw("Property doesnt exist.")
end
return xxx
end


#Cape OPEN functions
function GetCompoundList(list::CompoundList)
return[
    property(list,"ID"),
    property(list,"chemicalFormula"),
    property(list,"commonName"),
    property(list,"normalBoilingPoint"),
    property(list,"molecularWeight"),
    property(list,"casRegistryNumber"),
    ]
end

function GetNumCompounds(list::CompoundList)
    return length(list)
end

getConstPropList() = vcat(collect(keys(StringPropertiesBaseDict)),collect(keys(ValuePropertiesBaseDict)))

## IMPLEMENT THE FOLLOWING ON ALL OBJECTS (examples from julialang docs)
#Base.iterate(S::Squares, state=1) = state > S.count ? nothing : (state*state, state+1)
#Base.eltype(::Type{Squares}) = Int # Note that this is defined for the type
Base.length(S::CompoundList) = length(S.CompoundsID)




#END OF MODULE
end      






