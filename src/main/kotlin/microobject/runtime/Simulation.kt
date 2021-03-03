package microobject.runtime

import microobject.type.BOOLEANTYPE
import microobject.type.INTTYPE
import microobject.data.LiteralExpr
import microobject.type.DOUBLETYPE
import microobject.type.STRINGTYPE
import org.javafmi.modeldescription.SimpleType
import org.javafmi.wrapper.Simulation
import org.javafmi.wrapper.variables.SingleRead

class SimulatorObject(val path : String, memory : Memory){
    fun read(name: String): LiteralExpr {
        val v = sim.modelDescription.getModelVariable(name)
        if(v.typeName == "Integer") return LiteralExpr(sim.read(name).asInteger().toString(), INTTYPE)
        if(v.typeName == "Boolean") return LiteralExpr(sim.read(name).asBoolean().toString(), BOOLEANTYPE)
        if(v.typeName == "String") return LiteralExpr(sim.read(name).asBoolean().toString(), STRINGTYPE)
        if(v.typeName == "Double") return LiteralExpr(sim.read(name).asBoolean().toString(), DOUBLETYPE)

        throw Exception("Failed to read variable ${v.name}: only Integer variables are supported")
    }
    fun tick(i : Double){
        sim.doStep(i)
    }

    fun write(name: String, res: LiteralExpr) {
        for(mVar in sim.modelDescription.modelVariables){
            if(mVar.name == name){
                if(mVar.causality == "input" && mVar.typeName == "Integer"){
                    sim.write(name).with(res.literal.toInt())
                    break
                } else if(mVar.causality == "input" && mVar.typeName == "Boolean"){
                    sim.write(name).with(res.literal == "True")
                    break
                } else throw Exception("Failed to assign to variable $name")
            }
        }
    }


    private var sim : Simulation = Simulation(path)
    fun terminate() {
        sim.terminate()
    }

    fun dump(obj: String): String {
        var res = "$obj smol:modelName '${sim.modelDescription.modelName}'.\n"
        for(mVar in sim.modelDescription.modelVariables) {
            if(mVar.typeName != "Integer" && mVar.typeName != "Boolean")
                continue
            if(mVar.causality == "input") {
                res += "$obj smol:hasInPort prog:${mVar.name}.\n"
                res += "$obj prog:${mVar.name} ${dumpSingle(sim.read(mVar.name),mVar.type)}.\n"
            }
            if(mVar.causality == "output"){
                res += "$obj smol:hasOutPort prog:${mVar.name}.\n"
                res += "$obj prog:${mVar.name} ${dumpSingle(sim.read(mVar.name),mVar.type)}.\n"
            }
            if(mVar.causality == "parameter"){
                res += "$obj smol:hasStatePort prog:${mVar.name}.\n"
                res += "$obj prog:${mVar.name} ${dumpSingle(sim.read(mVar.name),mVar.type)}.\n"
                mVar.type
            }
        }
        return res
    }

    init {
        for(mVar in sim.modelDescription.modelVariables){
            if(mVar.causality == "input" || mVar.causality == "state"){
                if(!mVar.hasStartValue() && !memory.containsKey(mVar.name))
                    throw Exception("Failed to initialize variable ${mVar.name}: no initial value given")
                if(memory.containsKey(mVar.name)) {
                    if (mVar.typeName == "Integer") sim.write(mVar.name).with(memory[mVar.name]!!.literal.toInt())
                    else if (mVar.typeName == "Boolean") sim.write(mVar.name).with(memory[mVar.name]!!.literal.toBoolean())
                    else if (mVar.typeName == "Double") sim.write(mVar.name).with(memory[mVar.name]!!.literal.toDouble())
                    else /*if (mVar.typeName == "String")*/ sim.write(mVar.name).with(memory[mVar.name]!!.literal.removeSurrounding("\""))
                }
            }
            if((mVar.causality == "output" || mVar.initial == "calculated") && memory.containsKey(mVar.name)) {
                throw Exception("Cannot initialize output or/and calculated variable ${mVar.name}")
            }
        }
    }

    private fun dumpSingle(read : SingleRead, type : SimpleType) : String{
        return when(type){
            is org.javafmi.modeldescription.v2.IntegerType -> read.asInteger().toString()
            is org.javafmi.modeldescription.v1.IntegerType -> read.asInteger().toString()
            is org.javafmi.modeldescription.v2.StringType -> "'"+read.asString()+"'"
            is org.javafmi.modeldescription.v1.StringType -> "'"+read.asString()+"'"
            is org.javafmi.modeldescription.v2.BooleanType -> if(read.asBoolean()) "'1'" else "'0'"
            is org.javafmi.modeldescription.v1.BooleanType -> if(read.asBoolean()) "'1'" else "'0'"
            is org.javafmi.modeldescription.v2.RealType -> read.asDouble().toString()
            is org.javafmi.modeldescription.v1.RealType -> read.asDouble().toString()
            else -> throw java.lang.Exception("Unknown Type")
        }
    }
}