from antlr4 import *
from antlr4.InputStream import InputStream

if __name__ is not None and "." in __name__:
    from .qsequenceLexer import qsequenceLexer
    from .qsequenceParser import qsequenceParser
    from .EvalVisitor import EvalVisitor
else:
    from qsequenceLexer import qsequenceLexer
    from qsequenceParser import qsequenceParser
    from EvalVisitor import EvalVisitor


import sys
import json

def mainfunc(inputstr):
    input_stream = InputStream(inputstr)
    lexer = qsequenceLexer(input_stream)
    token_stream = CommonTokenStream(lexer)
    parser = qsequenceParser(token_stream)
    tree = parser.prog()

    evalVisitor = EvalVisitor()
    Eval=evalVisitor.visit(tree)

    return json.dumps(Eval)

if __name__=='__main__':
    print('Main--------------------------------')
    #sys.argv=['','test.qs']
    #H(1)[CNOT(1,2)]*[X/2(1)-Y/2(2)]X(5)[-X/2(1)Y(2)]*[Y/2(3)X(2)*I(1)Z(2)]
    #H(1)CZ(1,2)Y(2)

    if len(sys.argv) > 1:
        input_stream = FileStream(sys.argv[1])
    else:
        #input_stream = InputStream(sys.stdin.read())
        input_stream = InputStream('H(1)[CNOT(1,2)]*[X/2(1)-Y/2(2)]X(5)[-X/2(1)Y(2)]*[Y/2(3)X(2)*I(1)Z(2)]')

    lexer = qsequenceLexer(input_stream)
    token_stream = CommonTokenStream(lexer)
    parser = qsequenceParser(token_stream)
    tree = parser.prog()

    "print"
    #print(tree.toStringTree(recog=parser))

    evalVisitor = EvalVisitor()
    Eval=evalVisitor.visit(tree)

    import pprint
    pprint.pprint(Eval)
    print('\n\n')
    print(input_stream.strdata)

    print('End--------------------------------')