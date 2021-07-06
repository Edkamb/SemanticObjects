package no.uio.microobject.main

import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.parameters.options.default
import com.github.ajalt.clikt.parameters.options.flag
import com.github.ajalt.clikt.parameters.options.option
import com.github.ajalt.clikt.parameters.options.switch
import com.github.ajalt.clikt.parameters.types.path
import no.uio.microobject.antlr.WhileLexer
import no.uio.microobject.antlr.WhileParser
import no.uio.microobject.backend.JavaBackend
import no.uio.microobject.data.Translate
import no.uio.microobject.runtime.REPL
import no.uio.microobject.type.TypeChecker
import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import java.io.File
import java.nio.file.Paths
import kotlin.system.exitProcess

data class Settings(val verbose : Boolean,      //Verbosity
                    val outpath : String,       //path of temporary outputs
                    val background : String,    //owl background knowledge
                    val domainPrefix : String,  //prefix used in the domain model (domain:)
                    val progPrefix : String = "https://github.com/Edkamb/SemanticObjects/Program#",    //prefix for the program (prog:)
                    val runPrefix : String  = "https://github.com/Edkamb/SemanticObjects/Run${System.currentTimeMillis()}#",    //prefix for this run (run:)
                    val langPrefix : String = "https://github.com/Edkamb/SemanticObjects#"
                    ){
    fun replaceKnownPrefixes(string: String) : String{
        return string.replace("domain:", "$domainPrefix:")
            .replace("prog:", "$progPrefix:")
            .replace("run:", "$runPrefix:")
            .replace("smol:", "$langPrefix:")
    }
    fun prefixes() : String =
        """@prefix : <urn:> .
           @prefix smol: <${langPrefix}> .
           @prefix prog: <${progPrefix}>.
           @prefix domain: <${domainPrefix}>.
           @prefix run: <${runPrefix}> .""".trimIndent()
}

class Main : CliktCommand() {
    val mainMode by option().switch(
        "--compile" to "compile",
        "-c" to "compile",
        "--execute" to "execute",
        "-e" to "execute",
        "--load" to "repl",
        "-l" to "repl",
    ).default("repl")

//    private val ninteractive by option("--non-interactive","-n",help="Does not enter the interactive shell, but executes the loaded file if no replay file is given.").flag()
//    private val cross        by option("--cross-compile","-c",help="Translates the .smol file loaded with -l into java.").flag()
    private val verbose      by option("--verbose","-v",help="Verbose output.").flag()
    private val tmp          by option("--tmp","-t",help="path to a directory used to store temporary files.").path().default(Paths.get("/tmp/mo"))
    private val replay       by option("--replay","-r",help="path to a file containing a series of shell commands.").path()
    private val input        by option("--input","-i",help="path to a .smol file which is loaded on startup.").path()
    private val back         by option("--back","-b",help="path to a .ttl file that contains OWL class definitions as background knowledge.").path()
    private val domainPrefix by option("--domain","-d",help="prefix for domain:.").default("http://github.com/edkamb/SemanticObjects/ontologies/default#")
    private val jPackage     by option("--package","-p",help="Java package.").default("no.uio.microobject")

    override fun run() {
        org.apache.jena.query.ARQ.init()

        //check that background knowledge exists
        var backgr = ""
        if(back != null){
            val file = File(back.toString())
            if(file.exists()){
                backgr = file.readText()
            }else println("Could not find file for background knowledge: ${file.path}")
        }

        if (input == null && mainMode != "repl"){
            println("Error: please specify an input .smol file using \"--input\".")
            exitProcess(-1)
        }

        if(mainMode == "compile") {
            val lexer = WhileLexer(CharStreams.fromFileName(input.toString()))
            val tokens = CommonTokenStream(lexer)
            val parser = WhileParser(tokens)
            val tree = parser.program()

            val visitor = Translate()
            val pair = visitor.generateStatic(tree)

            val tC = TypeChecker(tree, Settings(verbose, tmp.toString(), backgr, domainPrefix), pair.second)
            tC.check()
            tC.report()

            val backend = JavaBackend(tree, pair.second)
            print(backend.getOutput())
            return
        }

        val repl = REPL( Settings(verbose, tmp.toString(), backgr, domainPrefix))
        if(input != null){
            repl.command("read", input.toString())
        }
        if(replay != null){
            val str = replay.toString()
            File(str).forEachLine {
                if(!it.startsWith("#")) {
                    println("MO-auto> $it")
                    val splits = it.split(" ", limit = 2)
                    val left = if(splits.size == 1) "" else splits[1]
                    repl.command(splits.first(), left)
                }
            }
        }
        if(mainMode == "repl"){
            println("Interactive shell started.")
            do {
                print("MO>")
                val next = readLine() ?: break
                val splits = next.split(" ", limit = 2)
                val left = if(splits.size == 1) "" else splits[1]
            } while (!repl.command(splits.first(), left))
        }else if(replay == null){
            repl.command("auto", "")
        }
        repl.terminate()
    }
}

fun main(args:Array<String>) = Main().main(args)
