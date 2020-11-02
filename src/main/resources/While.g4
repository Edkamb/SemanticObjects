grammar While;


//Whitespace and comments
WS           : [ \t\r\n\u000C]+ -> channel(HIDDEN);
COMMENT      : '/*' .*? '*/' -> channel(HIDDEN) ;
LINE_COMMENT : '//' ~[\r\n]* -> channel(HIDDEN) ;

//Keywords
TRUE : 'true';
FALSE : 'false';
SKIP_S : 'skip';
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
OD : 'od';
THIS: 'this.';
OPARAN : '(';
CPARAN : ')';
PLUS : '+';
MINUS : '-';
AND : '&';
OR : '|';
PRINTLN : 'print';
CLASS : 'class';
END : 'end';
EXTENDS : 'extends';
BREAKPOINT : 'breakpoint';
COMMA : ',';

//Names etc.
fragment DIG : [0-9];
fragment LET : [a-zA-Z_];
fragment LOD : LET | DIG;
NAME : LET LOD*;
CONSTANT :  DIG+ | TRUE | FALSE;

namelist : NAME (COMMA NAME)*;

//Entry point
program : (class_def)+ DO statement OD;

//classes
class_def : CLASS NAME (EXTENDS NAME)? OPARAN namelist? CPARAN  method_def* END;
method_def : NAME OPARAN namelist? CPARAN statement END;

//Statements
statement :   SKIP_S SEMI                                                           # skip_statment
			| expression ASS expression SEMI                                        # assign_statement
			| RETURN expression SEMI                                                # return_statement
			| (target=expression ASS)? expression DOT NAME OPARAN (expression (COMMA expression)*)? CPARAN SEMI    # call_statement
			| target=expression ASS NEW NAME OPARAN (expression (COMMA expression)*)? CPARAN SEMI                  # create_statement
			| BREAKPOINT (OPARAN expression CPARAN)? SEMI                           # debug_statement
			| PRINTLN OPARAN expression CPARAN SEMI                                 # output_statement
			| IF expression THEN statement ELSE statement END statement?            # if_statement
            | WHILE expression DO statement END statement?                          # while_statement
            | statement statement                                                   # sequence_statement
            ;


//Expressions
expression :      THIS NAME                      # field_expression
                | expression DOT NAME			 # external_field_expression
                | NAME                           # var_expression
                | CONSTANT                       # const_expression
                | expression PLUS expression     # plus_expression
                | expression MINUS expression    # minus_expression
                | expression EQ expression       # eq_expression
                | expression NEQ expression      # neq_expression
                | expression GEQ expression      # geq_expression
                | OPARAN expression CPARAN       # nested_expression
                ;


