grammar qsequence;

prog : gc ;

gc : expr                           # Expression
    | expr '*' expr                 # Tensore
    | '[' gc ']' '*' '[' gc ']'     # Tensorgc
    | gc gc                         # Mult
    ;

expr : gateid '(' qubitid (',' qubitid)* ')' ;

qubitid : INT ;

gateid : GATECHAR ;

INT : [0-9]+ ;
GATECHAR : ( [a-zA-Z0-9] | '-' | '+' | '/' )+ ;
WS  :   [ \t\r\n]+ -> skip ;
