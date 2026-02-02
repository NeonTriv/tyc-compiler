grammar TyC;

@lexer::header {
from lexererr import *
}

@lexer::members {
def emit(self):
    tk = self.type
    if tk == self.UNCLOSE_STRING:       
        result = super().emit();
        raise UncloseString(result.text[1:]);
    elif tk == self.ILLEGAL_ESCAPE:
        result = super().emit();
        raise IllegalEscape(result.text[1:]);
    elif tk == self.ERROR_TOKEN:
        result = super().emit();
        raise ErrorToken(result.text);
    elif tk == self.ERROR_CHAR:
        result = super().emit();
        raise ErrorToken(result.text); 
    else:
        return super().emit();
}

options{
	language=Python3;
}

// --- PARSER ---
program: decl* EOF;

decl: var_decl | func_decl | struct_decl;

struct_decl: STRUCT ID LB member* RB SEMI;
member: type ID SEMI;

func_decl: (type|VOID)? ID LP param_list? RP block_stmt;

param_list: param COMMA param_list | param;
param: type ID; 

stmt: var_decl | if_stmt | iter_stmt | break_stmt | continue_stmt | return_stmt | block_stmt | expr_stmt | switch_stmt;

block_stmt: LB stmt* RB;

if_stmt: IF LP expr RP stmt (ELSE stmt)?;

iter_stmt: WHILE LP expr RP stmt  | FOR LP (var_decl | expr_stmt | SEMI) expr? SEMI expr? RP stmt;

switch_stmt: SWITCH LP expr RP LB case_list RB;
case_list: case_item case_list | case_item | /* empty */;
case_item: (CASE expr | DEFAULT) COLON stmt*;

break_stmt: BREAK SEMI;
continue_stmt: CONTINUE SEMI;
return_stmt: RETURN expr? SEMI;
expr_stmt: expr SEMI;

var_decl: type var_list SEMI | AUTO ID (ASSIGN expr)? SEMI;

var_list: var_item (COMMA var_item)*;
var_item: ID (ASSIGN expr)?; 

expr: expr1;
expr1: expr2 ASSIGN expr1 | expr2;
expr2: expr2 OR expr3 | expr3;
expr3: expr3 AND expr4 | expr4;
expr4: expr4 (EQ | NEQ) expr5 | expr5;
expr5: expr5 (LT | GT | LE | GE) expr6 | expr6;
expr6: expr6 (ADD | SUB) expr7 | expr7;
expr7: expr7 (MUL | DIV | MOD) expr8 | expr8;
expr8: (NOT | SUB | ADD | INC | DEC) expr8 | expr9;
expr9: expr9 LP expr_list? RP | expr9 DOT ID | expr9 (INC | DEC) | expr10;
expr10: ID | INT_LIT | FLOAT_LIT | STRING_LIT | LP expr RP | LB expr_list? RB; // Thêm struct literal {1, 2}

expr_list: expr (COMMA expr)*;

type: INT | FLOAT | STRING | ID;

//Keyword
AUTO: 'auto';
BREAK: 'break';
CASE: 'case';
CONTINUE : 'continue';
DEFAULT: 'default';
ELSE: 'else';
FLOAT: 'float';
FOR: 'for';
IF: 'if';
INT: 'int';
RETURN: 'return';
STRING: 'string';
STRUCT: 'struct';
SWITCH: 'switch';
VOID: 'void';
WHILE: 'while';

//Operator
ADD: '+';
SUB: '-';
MUL: '*';
DIV: '/';
MOD: '%';
NOT: '!';
EQ: '==';
NEQ: '!=';
LT: '<';
GT: '>';
LE: '<=';
GE: '>=';
OR: '||';
AND: '&&';
INC: '++';
DEC: '--';
ASSIGN: '=';
DOT: '.';

//Separators
SEMI: ';';
COLON: ':';
COMMA: ',';
LP: '(';
RP: ')';
LB: '{';
RB: '}';
LSB: '[';
RSB: ']';

//Literals
FLOAT_LIT: '-'?[0-9]* '.' [0-9]* | '-'?[0-9]* '.' [0-9]+ ('e'|'E')'-'?[0-9]+;
INT_LIT: '-'?[0-9]+;

ID: [a-zA-Z_] [a-zA-Z0-9_]*;

fragment ESCAPE_SEQUENCE: '\\' [bfrnt"\\];
fragment LEGIT_WORD: ~["\\\r\n];

ILLEGAL_ESCAPE:'"' (LEGIT_WORD | ESCAPE_SEQUENCE)* '\\' ~[bfrnt"\\\\];
UNCLOSE_STRING:'"' (LEGIT_WORD|ESCAPE_SEQUENCE)* [\r\n]?;

LINE_COMMENT: '//' ~[\r\n]* -> skip;
BLOCK_COMMENT: '/*' .*? '*/' -> skip;

STRING_LIT: '"' (LEGIT_WORD|ESCAPE_SEQUENCE)* '"' { self.text = self.text[1:-1] };

WS : [ \t\r\n]+ -> skip ; // skip spaces, tabs
ERROR_TOKEN: .;
ERROR_CHAR: .;