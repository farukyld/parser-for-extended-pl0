you can compile the project using
```shell
make link
```
and run with the example specified in the makefile with
```shell
make run
```
generated parser and lexer codes are put inside `generated_dir`, object files are put inside `temp_dir`.

the name of the output executable is specified as `.proj1.exe` in the makefile.

I created a folder named `src` to include additional source code, but the only code that I needed to use is calling `yyparse` inside `main`. This is because we were only supposed to implement a parser, we were not supposed to implement a semantic control mechanism.
