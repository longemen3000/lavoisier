include("Thermo/Thermo.jl")
using .Thermo.UniversalConstants , 
      .Thermo.Compounds

testSize = 50
testResults=Array{Bool,1}(undef, testSize) 
testErrors=Array{String,1}(undef, testSize) 
testCounter = 0

println("")
println("-----------------------------------------------------------")
println("Iniciating tests:")
println("-----------------------------------------------------------")
println("")
testName= "UniversalConstants.getUniversalConstant" 
testCounter+=1
try
    R = UniversalConstants.getUniversalConstant("molarGasConstant")
    testResults[testCounter]=true
    println(string("Test"," N°",testCounter,", ",testName,": Passed"))
catch error
    testResults[testCounter]=false
    println("******************************")
    println(string("Test"," N°",testCounter,", ",testName,": Failed"))
    testErrors[testCounter] = string(error) 
    println(testErrors[testCounter])
    println("******************************")
end

testName= "UniversalConstants.getUniversalConstantList" 
testCounter+=1
try
    R = UniversalConstants.getUniversalConstantList()
    testResults[testCounter]=true
    println(string("Test"," N°",testCounter,", ",testName,": Passed"))
catch error;
    testResults[testCounter]=false
    println("******************************")
    println(string("Test"," N°",testCounter,", ",testName,": Failed"))
    testErrors[testCounter] = string(error) 
    println(testErrors[testCounter])
    println("******************************")
end

testName= "Compounds.getConstPropList" 
testCounter+=1
try
    R = Compounds.getConstPropList()
    testResults[testCounter]=true
    println(string("Test"," N°",testCounter,", ",testName,": Passed"))
catch error;
    testResults[testCounter]=false
    println("******************************")
    println(string("Test"," N°",testCounter,", ",testName,": Failed"))
    testErrors[testCounter] = string(error) 
    println(testErrors[testCounter])
    println("******************************")
end

testName= "Compounds.newCompound" 
testCounter+=1
try
    x1 = Dict{String,String}(
    "ID"=>"compound1",
    "iupacName"=>"sdasd",
    "casRegistryNumber"=>"sdasd112312")


    x2 = Dict{String,Float64}(
        "molecularWeight"=>18.0,
        "criticalTemperature"=>647,
        "criticalPressure"=>220000)


    compound1 = Compound(x1)
    compound2 = Compound(x1,x2,ID="compound2")
    compound3 = Compound(x1,ID="compound3")
    #println(compound1.ID)
    #println(compound2.ID)
    #compoundlist1 = Compounds.newCompoundList([compound1,compound2],["11","22"]) #not valid anymore
    Compoundsz = [compound1,compound2,compound3]
    IDs = map(x->x.StringProperties["ID"],Compoundsz)
    println(IDs)
    compoundlist2 = Compounds.CompoundList(Compoundsz)
    #println(Compounds.GetCompoundList(compoundlist1))
   # println(Compounds.GetNumCompounds(compoundlist2))
    #println(compound1.StringProperties["ID"])
    #println(comp
    println(compoundlist2["molecularWeight"])
    #c2 = Compounds.getCompound(c1,1)

    testResults[testCounter]=true
    println(string("Test"," N°",testCounter,", ",testName,": Passed"))
catch error;
    testResults[testCounter]=false
  println("******************************")
    println(string("Test"," N°",testCounter,", ",testName,": Failed"))
    testErrors[testCounter] = string(error) 
    println(testErrors[testCounter])
    println("******************************")
end








mutable struct po 
    x::Real
    y::Real
end

p1 = po(1,1)
p1.x = 40


passedResults = length(filter(x ->  x== true, testResults)) #usage of filter function
coverage = 100*passedResults/testCounter

println("")
println("-----------------------------------------------------------")
println(string("Tests results:"))
println(string("Total executed tests = ",testCounter))
println(string("Coverage = ",round(coverage,digits=2),"%"))
println("-----------------------------------------------------------")
println("")



#x = newCompound()