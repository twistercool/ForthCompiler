This is the repository for my Forth Compiler Project
In order to run it, you have to have the following CLI tools installed: 
- the Ammonite REPL (therefore scala and the JVM)
- the LLVM CLI tools (llc and lli for now)

You can write forth code in any .txt file (but please use .fth) in the same directory as the other files and you can get the Abstract Syntax Tree by writing:
  amm Parser.sc parseFile <filename>
  
To use the Interpreter, use the following command:
  amm Interpreter.sc runFile <filename>
  
You can also compile the code to LLVM-IR and get a .ll file with the command:
  amm CodeGeneration.sc write <filename>
  
Finally, to compile and run a Forth file, use the following command:
  amm CodeGeneration.sc run <filename>
