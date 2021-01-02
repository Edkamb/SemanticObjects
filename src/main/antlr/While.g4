grammar While;
/**
TODO: casts
      unit
      constraints on generics
      name clash generics
      drop special treatment of atomic types
      overrides
**/
@header {
package antlr.microobject.gen;
}
//Strings
STRING : '"' .*? '"' ;

//Whitespace and comments
WS           : [ \t\r\n\u000C]+ -> channel(HIDDEN);
COMMENT      : '/*' .*? '*/' -> channel(HIDDEN) ;
LINE_COMMENT : '//' ~[\r\n]* -> channel(HIDDEN) ;

//Keywords
TRUE : 'True';
FALSE : 'False';
SKIP_S : 'skip';
NULL : 'null';
EQ : '=';
NEQ : '<>';
LT : '<';
GT : '>';
LEQ : '<=';
GEQ : '>=';
RETURN : 'return';
ASS : ':=';
DOT : '.';
SEMI : ';';
IF : 'if';
FI : 'fi';
THEN : 'then';
NEW : 'new';
ELSE : 'else';
WHILE : 'while';
DO : 'do';
MAIN : 'main';
THIS: 'this';
OPARAN : '(';
CPARAN : ')';
PLUS : '+';
MULT : '*';
MINUS : '-';
AND : '&';
OR : '|';
PRINTLN : 'print';
CLASS : 'class';
END : 'end';
EXTENDS : 'extends';
ACCESS : 'access';
DERIVE : 'derive';
BREAKPOINT : 'breakpoint';
RULE : 'rule';
COMMA : ',';

//Names etc.
fragment DIG : [0-9];
fragment LET : [a-zA-Z_];
fragment LOD : LET | DIG;
NAME : LET LOD*;
CONSTANT :  DIG+;

namelist : NAME (COMMA NAME)*;

//Entry point
program : (class_def)+ MAIN statement END;

//classes
class_def : CLASS (LT namelist GT)? NAME (EXTENDS NAME)? OPARAN paramList? CPARAN  method_def* END;
method_def : (builtinrule=RULE)? type NAME OPARAN paramList? CPARAN statement END;

//Statements
statement :   SKIP_S SEMI                                                                                                                               # skip_statment
			| (declType = type)? expression ASS expression SEMI                                                                                         # assign_statement
			| RETURN expression SEMI                                                                                                                    # return_statement
			| ((declType = type)? target=expression ASS)? expression DOT NAME  OPARAN (expression (COMMA expression)*)? CPARAN SEMI                     # call_statement
			| (declType = type)? target=expression ASS NEW NAME (LT namelist GT)? OPARAN (expression (COMMA expression)*)? CPARAN SEMI                  # create_statement
			| BREAKPOINT (OPARAN expression CPARAN)? SEMI                                                                                               # debug_statement
			| PRINTLN OPARAN expression CPARAN SEMI                                                                                                     # output_statement
			| (declType = type)? target=expression ASS ACCESS OPARAN query=expression (COMMA expression (COMMA expression)*)? CPARAN SEMI               # sparql_statement
			| (declType = type)? target=expression ASS DERIVE OPARAN query=expression CPARAN SEMI                                                       # owl_statement
			| IF expression THEN statement (ELSE statement)? END next=statement?                                                                        # if_statement
            | WHILE expression DO statement END next=statement?                                                                                         # while_statement
            | statement statement                                                                                                                       # sequence_statement
            ;


//Expressions
expression :      THIS                           # this_expression
                | THIS DOT NAME                  # field_expression
                | NAME                           # var_expression
                | CONSTANT                       # const_expression
                | TRUE                           # true_expression
                | FALSE                          # false_expression
                | STRING                         # string_expression
                | NULL                           # null_expression
                | expression DOT NAME			 # external_field_expression
                | expression PLUS expression     # plus_expression
                | expression MINUS expression    # minus_expression
                | expression MULT expression     # mult_expression
                | expression EQ expression       # eq_expression
                | expression NEQ expression      # neq_expression
                | expression GEQ expression      # geq_expression
                | expression LEQ expression      # leq_expression
                | OPARAN expression CPARAN       # nested_expression
                ;

type : NAME                #simple_type
     | NAME LT typelist GT #nested_type
     ;
typelist : type (COMMA type)*;
param : type NAME;
paramList : param (COMMA param)*;
