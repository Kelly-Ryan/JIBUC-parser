%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

extern int yylineno;
extern FILE *yyin;

struct identifier {
	const char *name;
	size_t size;
};

int identifierCount = 0;
struct identifier identifiers[100];
void addIdentifier(const char *name, const char *size);
bool checkIdentifierExists(const char *s);
void intToId(const int integer, const char *id);
void idToId(const char *id1, const char *id2);
%}

%error-verbose

%union {
    char *sval;
    int ival;
}

%token <sval> IDENTIFIER
%token <sval> SIZE
%token <ival> INTEGER
%token START BODY MOVE ADD TO INPUT PRINT TEXT SEMICOLON FINISH TERMINATOR INVALID

%%

program: start declarations body finish { printf("\nProgram is well-formed."); };

start: START TERMINATOR ;

declaration: SIZE IDENTIFIER TERMINATOR { addIdentifier($2, $1); } ;

declarations: declaration | declaration declarations ;

body: BODY TERMINATOR actions ;

action: assignments | inputs | printOutputs ;

actions: action | action actions ;

assignment: MOVE IDENTIFIER TO IDENTIFIER TERMINATOR { idToId($2, $4); }
	    | MOVE INTEGER TO IDENTIFIER TERMINATOR { intToId($2, $4); }
    	| ADD IDENTIFIER TO IDENTIFIER TERMINATOR { idToId($2, $4); }
    	| ADD INTEGER TO IDENTIFIER TERMINATOR { intToId($2, $4); };

assignments: assignment | assignment assignments ;

input: INPUT IDENTIFIER TERMINATOR { checkIdentifierExists($2); };

inputs: input | input inputs ;

output: IDENTIFIER SEMICOLON { checkIdentifierExists($1); }
	| TEXT SEMICOLON
	| output IDENTIFIER SEMICOLON { checkIdentifierExists($2); }
	| output TEXT SEMICOLON ;

printOutput: PRINT TEXT TERMINATOR
	| PRINT output TEXT TERMINATOR
	| PRINT output IDENTIFIER TERMINATOR { checkIdentifierExists($3); };

printOutputs: printOutput | printOutput printOutputs ;

finish: FINISH TERMINATOR ;

%%

int main() {
    while(!feof(yyin)) {
        yyparse();
        return 0;
    }
}

yyerror (const char *s) {
    printf("\nProgram is invalid.\n");
    fprintf(stderr, "At line no. %d, %s\n", yylineno, s);
}

// add identifier struct containing variable name and size to identifiers array
void addIdentifier(const char *name, const char *size) {
    if(!checkIdentifierExists(name)) {
	identifiers[identifierCount].name = name;
        identifiers[identifierCount].size = strlen(size);
        identifierCount++;
    } else {
    	printf("\n%s is already declared.\nProgram invalid.", name);
    	exit(EXIT_SUCCESS);
    }
}

// check if identifier has been declared - add duplicate check
bool checkIdentifierExists(const char *s) {
    int i = 0;
    while(i < identifierCount) {
        if(strcmp(identifiers[i].name, s) == 0) {
            return true;
        }
        i++;
    }
    return false;
}

void intToId(const int integer, const char *id) {
    // check id exists
    if(checkIdentifierExists(id)) {
        // get integer size
        size_t intSize = snprintf(NULL, 0, "%i", (integer));

        // get size of id
        int i = 0;
        size_t idSize = 0;
        while(i < identifierCount) {
            if(strcmp(identifiers[i].name, id) == 0) {
                idSize = identifiers[i].size;
                break;
            }
            i++;
        }

        // compare integer and id sizes
        if(intSize > idSize) {
            printf("\nLine no. %d: variable %s must be of smaller or equal capacity to variable %s. Program invalid.",
                   yylineno, integer, id);
            exit(EXIT_SUCCESS);
        }
    } else {
        printf("\n%s not declared. Program invalid.", id);
        exit(EXIT_SUCCESS);
    }
}

void idToId(const char *id1, const char *id2) {
    // check if identifiers have been declared
    if(checkIdentifierExists(id1)) {
        if(checkIdentifierExists(id2)) {
            // get size of id1
            int i = 0;
            size_t id1Size = 0;
            while(i < identifierCount) {
                if(strcmp(identifiers[i].name, id1) == 0) {
                    id1Size = identifiers[i].size;
                    break;
                }
                i++;
            }

            // get size of id2
            int j = 0;
            size_t id2Size = 0;
            while(j < identifierCount) {
                if(strcmp(identifiers[j].name, id2) == 0) {
                    id2Size = identifiers[j].size;
                    break;
                }
                j++;
            }

            // compare sizes of id1 and id2
            if(id1Size > id2Size) {
                printf("\nLine no. %d: variable %s must be of smaller or equal capacity to variable %s. Program invalid.",
                       yylineno, id1, id2);
                exit(EXIT_SUCCESS);
            }
        } else {
	        printf("\n%s not declared. Program invalid.", id2);
            exit(EXIT_SUCCESS);
        }
    } else {
    	printf("\n%s not declared. Program invalid.", id1);
        exit(EXIT_SUCCESS);
    }
}