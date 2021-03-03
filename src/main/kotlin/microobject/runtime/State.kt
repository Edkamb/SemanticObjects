package microobject.runtime

import microobject.data.LiteralExpr
import microobject.data.Statement
import microobject.main.Settings
import microobject.type.*
import java.util.*

//This will be used for snapshots
class State(initStack  : Stack<StackEntry>, initHeap: GlobalMemory, simMemory: SimulationMemory, initInfo : StaticTable, private val settings: Settings) {
    private val stack: Stack<StackEntry> = initStack.clone() as Stack<StackEntry>
    private val heap: GlobalMemory = initHeap.toMutableMap()
    private val staticInfo: StaticTable = initInfo.copy()
    private val simulation : SimulationMemory = simMemory.toMap().toMutableMap()

    companion object{
        val HEADER =
        """
        @prefix owl: <http://www.w3.org/2002/07/owl#> .
        @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
        @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
        @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
        """.trimIndent()

        val VOCAB = this::class.java.classLoader.getResource("vocab.owl").readText()

        val MINIMAL =
        """                     
        smol:null rdf:type owl:NamedIndividual , smol:Object .
        prog:_Entry_ rdf:type owl:NamedIndividual , smol:Class .
        
        """.trimIndent()
    }

    fun dump() : String{
        //Builds always known information and meta data
        var res = settings.prefixes() + "\n"+HEADER + "\n" + VOCAB  + "\n" + MINIMAL


        res += staticInfo.dumpClasses()

        //dumps individuals
        var i = 0
        for(obj in heap.keys){
            res += "run:${obj.literal} smol:instanceOf prog:${(obj.tag as BaseType).name}.\n"
            res += "run:${obj.literal} rdf:type owl:NamedIndividual , smol:Object.\n"
            //and their fields
            for(store in heap[obj]!!.keys) {
                val target = heap[obj]!!.getOrDefault(store, LiteralExpr("ERROR"))
                res += "run:${obj.literal} prog:$store "
                res += if(target.tag == ERRORTYPE || target.tag == STRINGTYPE)
                    "${target.literal}.\n"
                else if(target.literal == "null")
                    "smol:${target.literal}.\n"
                else
                    "run:${target.literal}.\n"
                i++
            }
        }

        // dumps processes
        res += "\n"
        var prevStackEntry: StackEntry? = null
        for (stackEntry in stack){
            if (prevStackEntry != null){
                res += "run:pro${prevStackEntry.id} smol:nextOnStack run:pro${stackEntry.id}.\n"
            }
            prevStackEntry = stackEntry
            res += "run:pro${stackEntry.id} rdf:type smol:Process.\n"
            res += "run:pro${stackEntry.id} smol:runsOnObject run:${stackEntry.obj}.\n"
            for ((key, value) in stackEntry.store){
                if (key != "this" && key.first() != '_') {
                    res += "run:pro${stackEntry.id} prog:${key} run:${value}.\n"
                }
            }
            res += "run:pro${stackEntry.id} smol:active prog:stmt${stackEntry.active.hashCode()}.\n"
            res += stackEntry.active.getRDF()
        }

        // dumps simulation processes
        for(obj in simulation.keys){
            res += "run:${obj.literal} rdf:type owl:NamedIndividual , smol:Simulation.\n"
            val sim = simulation.getValue(obj)
            res += sim.dump("run:${obj.literal}")
        }
        return res + "\n" + settings.background
    }
}



/*
We use the term "heap" NOT in the sense of C and other low-level here.
Heap memory is barely the opposite of local memory, we have no assumptions about the memory.
 */
typealias Memory = MutableMap<String, LiteralExpr>       // Maps variable names to values
typealias GlobalMemory = MutableMap<LiteralExpr, Memory>  // Maps object name literals to local memories
typealias SimulationMemory = MutableMap<LiteralExpr, SimulatorObject>  // Maps object name literals to local memories
typealias FieldEntry = List<Pair<String, Type>>                   //list of fields
typealias MethodEntry = Pair<Statement, List<String>> //method body and list of parameters

data class StaticTable(
    val fieldTable: Map<String, FieldEntry>,               // This maps class names to their fields
    val methodTable: Map<String, Map<String, MethodEntry>>, // This maps class names to a map that maps method names to their definition
    val hierarchy: MutableMap<String, MutableSet<String>> = mutableMapOf()
) { // DOWNWARDS class hierarchy
    override fun toString(): String =
"""
Class Hierarchy : $hierarchy 
FieldTable      : $fieldTable 
MethodTable     : $methodTable 
""".trimIndent()

    private fun getSuper(name : String) : String?{
        for(obj in hierarchy.entries){
            for(obj2 in obj.value){
                if(obj2 == name) return obj.key
            }
        }
        return null
    }

    fun getSuperMethod(className : String, methodName : String) : MethodEntry?{
        var current = getSuper(className)
        while(current != null && current != "Object"){
            if(!methodTable.containsKey(current)) return null
            if(methodTable[current]!!.containsKey(methodName)) return methodTable[current]!![methodName]
            current = getSuper(current)
        }
        return null
    }

    fun dumpClasses() : String{
        var res = ""
        for(obj in fieldTable){
            res += "prog:${obj.key} rdf:type smol:Class.\n"
            res += "prog:${obj.key} rdf:type owl:Class.\n"
            for(obj2 in obj.value){
                res += "prog:${obj.key} smol:hasField prog:${obj2.first}.\n"
                res += "prog:${obj2.first} rdf:type smol:Field.\n"
                if(obj2.second == INTTYPE || obj2.second == STRINGTYPE) {
                    res += "prog:${obj2.first} rdf:type owl:DatatypeProperty.\n"
                } else {
                    res += "prog:${obj2.first} rdf:type owl:FunctionalProperty.\n"
                    res += "prog:${obj2.first} rdf:type owl:ObjectProperty.\n"
                }
                res += "prog:${obj2.first} rdfs:domain prog:${obj.key}.\n"
            }
        }

        //records all methods
        for(obj in methodTable){
            for(obj2 in obj.value){
                res += "prog:${obj.key} smol:hasMethod prog:${obj2.key}.\n"
                res += "prog:${obj2.key} rdf:type owl:NamedIndividual , smol:Method.\n"
            }
        }

        //records type hierarchy
        for(obj in hierarchy.entries){
            for(obj2 in obj.value){
                res += "prog:$obj2 smol:extends prog:${obj.key}.\n"
            }
        }

        return res
    }
}

data class StackEntry(val active: Statement, val store: Memory, val obj: LiteralExpr, val id: Int)