 # MicroObjects 
 This repository contains an interactive interpreter for a minimal object-oriented language.
 The interpreter can be used to examine the state with SPARQL and SHACL queries.
 
 The project is in a very early stage, and the language performs almost no checks on its input.
 
 ## Examples
 Run with a path to an apache jena installation as the first parameter for the interactive mode.
 No trailing "/", tested only on Linux. Enter `help` for an overview over the available commands.
 
 * examples/double.mo contains a simple doubly linked list example.
 * examples/double.rq contains a SPARQL query to select all `List` elements
 * examples/double.ttl contains a SHACL query that ensures that all objects implement a class
 * examples/double.imo contains a simple test session
 
To run the geo session, run
 ```
./gradlew shadowJar
java -jar build/libs/MicroObjects-0.1-SNAPSHOT-all.jar  -l examples/geo.mo -r examples/geo.imo -b examples/geo.back
```

Set the first parameter of the earthquake to `0` for a non-sealing fault. The model is not faithful to geological process and barely illustrates the debugger.
If the example takes too much time, remove the `-b file` parameter to disable OWL inference for all queries.

To run the test session that demonstrates how inference drives simulation run 
 ```
./gradlew shadowJar
java -jar build/libs/MicroObjects-0.1-SNAPSHOT-all.jar  -l examples/simulate.mo -r examples/simulate.imo
```
Note how the result is an execution of the method `D.n` triggered from the inference engine, not the code. 
Currently, the `rule` modifier is likely to cause errors in other programs, use with care.   

To run the general test session and continue interactively, run
 ```
./gradlew shadowJar
java -jar build/libs/MicroObjects-0.1-SNAPSHOT-all.jar -j </path/to/jena/> -l examples/double.mo -r examples/double.imo
```
