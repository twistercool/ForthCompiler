This is the Forth Compiler final year Project
In order to run it, you have to have the following CLI tools installed: 
- The Ammonite REPL (therefore scala and the JVM)
- The LLVM tools
- Clang

You can write forth code in a .fth file in the same working directory as the compilation files

You can get the parse tree by writing:
  amm Parser.sc parseFile <filename>
  
Although it does not have the latest features, to use the Interpreter, use the following command:
  amm Interpreter.sc runFile <filename>
  
You can also compile the code to LLVM-IR and get a .ll file with the command:
  amm CodeGeneration.sc compileFile <filename>
  
Finally, to compile and run a Forth file, use the following command:
  amm CodeGeneration.sc run <filename>
