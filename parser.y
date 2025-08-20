%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern FILE* yyin;
void yyerror(const char* s);

#define AST_PLUS 1
#define AST_MINUS 2
#define AST_TIMES 3
#define AST_DIVIDE 4
#define AST_EQ 5
#define AST_NEQ 6
#define AST_LT 7
#define AST_GT 8
#define AST_LE 9
#define AST_GE 10

struct symbol {
    char* name;
    double value;
};

#define MAX_SYMBOLS 100
struct symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;

typedef enum {
    AST_NUMBER,
    AST_IDENTIFIER,
    AST_STRING,
    AST_BINARY_OP,
    AST_UNARY_OP,
    AST_ASSIGNMENT,
    AST_PRINT,
    AST_IF,
    AST_FOR,
    AST_SEQUENCE
} ASTNodeType;

typedef struct ASTNode {
    ASTNodeType type;
    union {
        double number;
        char* string;
        struct {
            struct ASTNode* left;
            struct ASTNode* right;
            int operator;
        } binary;
        struct {
            struct ASTNode* operand;
            int operator;
        } unary;
        struct {
            char* name;
            struct ASTNode* value;
        } assignment;
        struct {
            struct ASTNode* expr;
            char* str;
            int is_string;
        } print;
        struct {
            struct ASTNode* condition;
            struct ASTNode* if_branch;
            struct ASTNode* else_branch;
        } if_stmt;
        struct {
            struct ASTNode* init;
            struct ASTNode* condition;
            struct ASTNode* increment;
            struct ASTNode* body;
        } for_stmt;
        struct {
            struct ASTNode* first;
            struct ASTNode* rest;
        } sequence;
    } data;
} ASTNode;

char* safe_strdup(const char* s) {
    if (!s) return NULL;
    char* result = malloc(strlen(s) + 1);
    if (!result) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    strcpy(result, s);
    return result;
}

ASTNode* create_number_node(double value) {
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    node->type = AST_NUMBER;
    node->data.number = value;
    return node;
}

ASTNode* create_identifier_node(char* name) {
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    node->type = AST_IDENTIFIER;
    node->data.string = name;
    return node;
}

ASTNode* create_string_node(char* value) {
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    node->type = AST_STRING;
    node->data.string = value;
    return node;
}

ASTNode* create_binary_node(int operator, ASTNode* left, ASTNode* right) {
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    node->type = AST_BINARY_OP;
    node->data.binary.operator = operator;
    node->data.binary.left = left;
    node->data.binary.right = right;
    return node;
}

ASTNode* create_unary_node(int operator, ASTNode* operand) {
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    node->type = AST_UNARY_OP;
    node->data.unary.operator = operator;
    node->data.unary.operand = operand;
    return node;
}

ASTNode* create_assignment_node(char* name, ASTNode* value) {
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    node->type = AST_ASSIGNMENT;
    node->data.assignment.name = name;
    node->data.assignment.value = value;
    return node;
}

ASTNode* create_print_node(ASTNode* expr, char* str, int is_string) {
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    node->type = AST_PRINT;
    node->data.print.expr = expr;
    node->data.print.str = str;
    node->data.print.is_string = is_string;
    return node;
}

ASTNode* create_if_node(ASTNode* condition, ASTNode* if_branch, ASTNode* else_branch) {
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    node->type = AST_IF;
    node->data.if_stmt.condition = condition;
    node->data.if_stmt.if_branch = if_branch;
    node->data.if_stmt.else_branch = else_branch;
    return node;
}

ASTNode* create_for_node(ASTNode* init, ASTNode* condition, ASTNode* increment, ASTNode* body) {
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    node->type = AST_FOR;
    node->data.for_stmt.init = init;
    node->data.for_stmt.condition = condition;
    node->data.for_stmt.increment = increment;
    node->data.for_stmt.body = body;
    return node;
}

ASTNode* create_sequence_node(ASTNode* first, ASTNode* rest) {
    if (!first) return rest;
    if (!rest) return first;
    
    ASTNode* node = malloc(sizeof(ASTNode));
    if (!node) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    node->type = AST_SEQUENCE;
    node->data.sequence.first = first;
    node->data.sequence.rest = rest;
    return node;
}

int get_symbol_index(const char* name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

double get_symbol_value(const char* name) {
    int index = get_symbol_index(name);
    if (index == -1) {
        fprintf(stderr, "Error: Variable '%s' not defined\n", name);
        return 0.0;
    }
    return symbol_table[index].value;
}

void set_symbol_value(const char* name, double value) {
    int index = get_symbol_index(name);
    if (index == -1) {
        if (symbol_count >= MAX_SYMBOLS) {
            fprintf(stderr, "Error: Symbol table full\n");
            return;
        }
        symbol_table[symbol_count].name = safe_strdup(name);
        symbol_table[symbol_count].value = value;
        symbol_count++;
    } else {
        symbol_table[index].value = value;
    }
}

double eval_expr(ASTNode* node) {
    if (!node) return 0.0;
    
    switch (node->type) {
        case AST_NUMBER:
            return node->data.number;
        
        case AST_IDENTIFIER:
            return get_symbol_value(node->data.string);
        
        case AST_BINARY_OP:
            switch (node->data.binary.operator) {
                case AST_PLUS: 
                    return eval_expr(node->data.binary.left) + eval_expr(node->data.binary.right);
                case AST_MINUS: 
                    return eval_expr(node->data.binary.left) - eval_expr(node->data.binary.right);
                case AST_TIMES: 
                    return eval_expr(node->data.binary.left) * eval_expr(node->data.binary.right);
                case AST_DIVIDE: {
                    double right = eval_expr(node->data.binary.right);
                    if (right == 0) {
                        yyerror("Division by zero");
                        return 0;
                    }
                    return eval_expr(node->data.binary.left) / right;
                }
                case AST_EQ: 
                    return eval_expr(node->data.binary.left) == eval_expr(node->data.binary.right);
                case AST_NEQ: 
                    return eval_expr(node->data.binary.left) != eval_expr(node->data.binary.right);
                case AST_LT: 
                    return eval_expr(node->data.binary.left) < eval_expr(node->data.binary.right);
                case AST_GT: 
                    return eval_expr(node->data.binary.left) > eval_expr(node->data.binary.right);
                case AST_LE: 
                    return eval_expr(node->data.binary.left) <= eval_expr(node->data.binary.right);
                case AST_GE: 
                    return eval_expr(node->data.binary.left) >= eval_expr(node->data.binary.right);
                default:
                    yyerror("Unknown binary operator");
                    return 0;
            }
        
        case AST_UNARY_OP:
            switch (node->data.unary.operator) {
                case AST_MINUS: 
                    return -eval_expr(node->data.unary.operand);
                default:
                    yyerror("Unknown unary operator");
                    return 0;
            }
        
        default:
            yyerror("Invalid expression node");
            return 0;
    }
}

void execute_ast(ASTNode* node) {
    if (!node) return;
    
    switch (node->type) {
        case AST_SEQUENCE:
            execute_ast(node->data.sequence.first);
            execute_ast(node->data.sequence.rest);
            break;
        
        case AST_ASSIGNMENT:
            set_symbol_value(node->data.assignment.name, eval_expr(node->data.assignment.value));
            break;
        
        case AST_PRINT:
            if (node->data.print.is_string) {
                printf("%s\n", node->data.print.str);
            } else {
                printf("%g\n", eval_expr(node->data.print.expr));
            }
            break;
        
        case AST_IF:
            if (eval_expr(node->data.if_stmt.condition)) {
                execute_ast(node->data.if_stmt.if_branch);
            } else if (node->data.if_stmt.else_branch) {
                execute_ast(node->data.if_stmt.else_branch);
            }
            break;
            
        case AST_FOR:
            if (node->data.for_stmt.init)
                execute_ast(node->data.for_stmt.init);
                
            while (eval_expr(node->data.for_stmt.condition)) {
                execute_ast(node->data.for_stmt.body);
                
                if (node->data.for_stmt.increment)
                    execute_ast(node->data.for_stmt.increment);
            }
            break;
            
        default:
            eval_expr(node);
            break;
    }
}

void free_ast(ASTNode* node) {
    if (!node) return;
    
    switch (node->type) {
        case AST_IDENTIFIER:
        case AST_STRING:
            free(node->data.string);
            break;
            
        case AST_BINARY_OP:
            free_ast(node->data.binary.left);
            free_ast(node->data.binary.right);
            break;
            
        case AST_UNARY_OP:
            free_ast(node->data.unary.operand);
            break;
            
        case AST_ASSIGNMENT:
            free(node->data.assignment.name);
            free_ast(node->data.assignment.value);
            break;
            
        case AST_PRINT:
            if (node->data.print.expr) free_ast(node->data.print.expr);
            if (node->data.print.is_string && node->data.print.str) 
                free(node->data.print.str);
            break;
            
        case AST_IF:
            free_ast(node->data.if_stmt.condition);
            free_ast(node->data.if_stmt.if_branch);
            if (node->data.if_stmt.else_branch)
                free_ast(node->data.if_stmt.else_branch);
            break;
            
        case AST_FOR:
            if (node->data.for_stmt.init) free_ast(node->data.for_stmt.init);
            free_ast(node->data.for_stmt.condition);
            if (node->data.for_stmt.increment) free_ast(node->data.for_stmt.increment);
            free_ast(node->data.for_stmt.body);
            break;
            
        case AST_SEQUENCE:
            free_ast(node->data.sequence.first);
            free_ast(node->data.sequence.rest);
            break;
            
        default:
            break;
    }
    
    free(node);
}

ASTNode* program_root = NULL;
%}

%union {
    double num;
    char* id;
    char* str;
    struct ASTNode* ast;
}

%token <num> NUMBER
%token <id> IDENTIFIER
%token <str> STRING

%token PLUS MINUS TIMES DIVIDE ASSIGN
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON
%token IF ELSE FOR PRINT
%token EQ NEQ LT GT LE GE

%type <ast> program statement assignment_stmt if_statement for_statement expr condition assignment_expr

%left EQ NEQ LT GT LE GE
%left PLUS MINUS
%left TIMES DIVIDE
%right ASSIGN
%nonassoc UMINUS

%%

program: 
    /* empty */                      { $$ = NULL; program_root = NULL; }
    | program statement              { $$ = create_sequence_node($1, $2); program_root = $$; }
    ;

statement:
    expr SEMICOLON                          { $$ = $1; }
    | assignment_stmt                       { $$ = $1; }
    | PRINT LPAREN expr RPAREN SEMICOLON    { $$ = create_print_node($3, NULL, 0); }
    | PRINT LPAREN STRING RPAREN SEMICOLON  { $$ = create_print_node(NULL, $3, 1); }
    | if_statement                          { $$ = $1; }
    | for_statement                         { $$ = $1; }
    ;

assignment_stmt:
    IDENTIFIER ASSIGN expr SEMICOLON        { $$ = create_assignment_node($1, $3); }
    ;

assignment_expr:
    IDENTIFIER ASSIGN expr                  { $$ = create_assignment_node($1, $3); }
    ;

if_statement:
    IF LPAREN condition RPAREN LBRACE program RBRACE {
        $$ = create_if_node($3, $6, NULL);
    }
    | IF LPAREN condition RPAREN LBRACE program RBRACE ELSE LBRACE program RBRACE {
        $$ = create_if_node($3, $6, $10);
    }
    ;

for_statement:
    FOR LPAREN assignment_expr SEMICOLON condition SEMICOLON assignment_expr RPAREN LBRACE program RBRACE {
        $$ = create_for_node($3, $5, $7, $10);
    }
    ;

condition:
    expr EQ expr    { $$ = create_binary_node(AST_EQ, $1, $3); }
    | expr NEQ expr { $$ = create_binary_node(AST_NEQ, $1, $3); }
    | expr LT expr  { $$ = create_binary_node(AST_LT, $1, $3); }
    | expr GT expr  { $$ = create_binary_node(AST_GT, $1, $3); }
    | expr LE expr  { $$ = create_binary_node(AST_LE, $1, $3); }
    | expr GE expr  { $$ = create_binary_node(AST_GE, $1, $3); }
    ;

expr:
    NUMBER                      { $$ = create_number_node($1); }
    | IDENTIFIER                { $$ = create_identifier_node($1); }
    | expr PLUS expr            { $$ = create_binary_node(AST_PLUS, $1, $3); }
    | expr MINUS expr           { $$ = create_binary_node(AST_MINUS, $1, $3); }
    | expr TIMES expr           { $$ = create_binary_node(AST_TIMES, $1, $3); }
    | expr DIVIDE expr          { $$ = create_binary_node(AST_DIVIDE, $1, $3); }
    | MINUS expr %prec UMINUS   { $$ = create_unary_node(AST_MINUS, $2); }
    | LPAREN expr RPAREN        { $$ = $2; }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}

int main(int argc, char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Error: Cannot open file '%s'\n", argv[1]);
            return 1;
        }
    }
    
    printf("Simple Programming Language Interpreter\n");
    if (argc <= 1) {
        printf("Interactive mode - Type your code and press Ctrl+Z (Windows) or Ctrl+D (Unix) to execute\n\n");
    }
    
    int parse_result = yyparse();
    
    if (parse_result == 0 && program_root) {
        printf("\nExecuting program...\n");
        execute_ast(program_root);
        free_ast(program_root);
    } else if (parse_result != 0) {
        fprintf(stderr, "Parsing failed\n");
    }
    
    if (argc > 1) {
        fclose(yyin);
    }
    
    for (int i = 0; i < symbol_count; i++) {
        free(symbol_table[i].name);
    }
    
    return parse_result;
}