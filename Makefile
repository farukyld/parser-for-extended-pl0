# I got help from chatGPT in some parts of that makefile: https://chat.openai.com/share/d41febf6-a22b-4d15-a0b1-ab6f9ab8afed

# dir names
GENERATED_DIR := generated_dir

GRAMMAR_DIR		:= grammar
SRC_DIR				:= src
TEMP_DIR			:= temp_dir
OUTPUT_DIR		:= .
BISON_FILE 		:= $(GRAMMAR_DIR)/bison.y
FLEX_FILE 		:= $(GRAMMAR_DIR)/flex.l


# file names
LINKED_EXEC 	:= proj1.exe
BISON_PREFIX 	:= parser
FLEX_PREFIX		:= lexer
PARSER_HEADER := $(GENERATED_DIR)/$(BISON_PREFIX).h
BISON_OUTPUT  := $(GENERATED_DIR)/$(BISON_PREFIX).c
FLEX_OUTPUT		:= $(GENERATED_DIR)/$(FLEX_PREFIX).c

SRC_FILES			:= $(wildcard $(SRC_DIR)/*.c)
SRC_GENERATED	:= $(BISON_OUTPUT) $(FLEX_OUTPUT)
OBJ_GENERATED	:= $(patsubst $(GENERATED_DIR)/%.c, $(TEMP_DIR)/%.o, $(SRC_GENERATED))
OBJ_FILES			:= $(OBJ_GENERATED)
OBJ_FILES			+= $(patsubst $(SRC_DIR)/%.c, $(TEMP_DIR)/%.o, $(SRC_FILES))
DEP_FILES			:= $(patsubst %.o, %.d, $(OBJ_FILES))


# flags
BISON_FLAGS		:= --header=$(PARSER_HEADER) --output=$(BISON_OUTPUT)
FLEX_FLAGS		:= -o $(FLEX_OUTPUT)

# below, fno-common disallows multiple tentative definition of a variable (int a; in a header, header included multiple tr.unit.) see: https://man7.org/linux/man-pages/man1/gcc.1.html#:~:text=defined%20without%20an%20initializer%2C%20known%20as%20tentative
COMPILE_FLAGS	:= -fno-common -c -O2 -DPARSER_HEADER=\"$(PARSER_HEADER)\" -I$(CURDIR)
# library conatining some lexer functions I guess.
LINK_FLAGS		:=  -o .$(LINKED_EXEC) -ll

# run
run: .$(LINKED_EXEC)
	@echo "$(GREEN)running executable.$(DEFAULT)"
	./.$(LINKED_EXEC) < inputs/error_input.pl0


# link c files into executable
.$(LINKED_EXEC): $(OBJ_FILES)
	@echo "$(GREEN)linking into an executable$(DEFAULT)"
	gcc $(OBJ_FILES) $(LINK_FLAGS)

# alias for above rule
link: .$(LINKED_EXEC)


# directory creation
$(GENERATED_DIR):
	mkdir -p $(GENERATED_DIR)

$(TEMP_DIR):
	mkdir -p $(TEMP_DIR)



# generate code with bison
$(PARSER_HEADER) $(BISON_OUTPUT): $(BISON_FILE) $(GENERATED_DIR)
	@echo "$(GREEN)generating parser code with bison$(DEFAULT)"
	bison $(BISON_FLAGS) $(BISON_FILE)

# alias for above rule
parser: $(PARSER_HEADER) $(BISON_OUTPUT)

bison_give_counterexamples:
	bison $(BISON_FLAGS) -Wcounterexamples $(BISON_FILE)


# generate code with flex. (the flex file uses header file generated by bison)
# possibly other headers used by lex file will be in the dependencies here
$(FLEX_OUTPUT): $(PARSER_HEADER) $(FLEX_FILE)
	@echo "$(GREEN)generating lexer code with flex$(DEFAULT)"
	flex $(FLEX_FLAGS) $(FLEX_FILE)

# alias for above rule
lexer: $(FLEX_OUTPUT)

# compile c files
$(TEMP_DIR)/%.o: $(GENERATED_DIR)/%.c $(TEMP_DIR)
	@echo "$(GREEN)compiling generated c file$(DEFAULT)"
	gcc $(COMPILE_FLAGS) $< -o $@

$(TEMP_DIR)/%.o: $(SRC_DIR)/%.c $(TEMP_DIR)
	@echo "$(GREEN)compiling user c file$(DEFAULT)"
	gcc $(COMPILE_FLAGS) $< -o $@

objects: $(OBJ_FILES)


# clean
clean:
	@echo "$(GREEN)cleaning$(DEFAULT)"
	rm -rf $(GENERATED_DIR) $(TEMP_DIR)

GREEN := \e[32m
DEFAULT := \e[39m

debug:
	@echo "$(GREEN)src files:$(DEFAULT) $(SRC_FILES)"
	@echo "$(GREEN)obj files:$(DEFAULT) $(OBJ_FILES)"
	@echo "$(GREEN)src generated:$(DEFAULT) $(SRC_GENERATED)"
	@echo "$(GREEN)obj generated:$(DEFAULT) $(OBJ_GENERATED)"
	@echo "$(GREEN)bison flags:$(DEFAULT) $(BISON_FLAGS)"

# .PHONY: $(GENERATED) $(TEMP) debug run parser lexer objects link clean
