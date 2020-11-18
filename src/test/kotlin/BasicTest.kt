
import io.kotlintest.specs.StringSpec
import microobject.runtime.REPL
import kotlin.test.assertNotNull

class BasicTest : StringSpec() {
    private val repl = REPL("", "/tmp/mo/out.ttl", false, "")

    init {
        "parsing double"{
            val input = this::class.java.classLoader.getResource("double.mo").file
            repl.initInterpreter(input)
            assertNotNull(repl.interpreter)
        }
        "parsing geo"{
            val input = this::class.java.classLoader.getResource("geo.mo").file
            repl.initInterpreter(input)
            assertNotNull(repl.interpreter)
        }
        "parsing simulate"{
            val input = this::class.java.classLoader.getResource("simulate.mo").file
            repl.initInterpreter(input)
            assertNotNull(repl.interpreter)
        }
        "parsing test"{
            val input = this::class.java.classLoader.getResource("test.mo").file
            repl.initInterpreter(input)
            assertNotNull(repl.interpreter)
        }
    }
}