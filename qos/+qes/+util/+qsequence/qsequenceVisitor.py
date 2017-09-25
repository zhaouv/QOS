# Generated from qsequence.g4 by ANTLR 4.7
from antlr4 import *
if __name__ is not None and "." in __name__:
    from .qsequenceParser import qsequenceParser
else:
    from qsequenceParser import qsequenceParser

# This class defines a complete generic visitor for a parse tree produced by qsequenceParser.

class qsequenceVisitor(ParseTreeVisitor):

    # Visit a parse tree produced by qsequenceParser#prog.
    def visitProg(self, ctx:qsequenceParser.ProgContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by qsequenceParser#Tensorgc.
    def visitTensorgc(self, ctx:qsequenceParser.TensorgcContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by qsequenceParser#Tensore.
    def visitTensore(self, ctx:qsequenceParser.TensoreContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by qsequenceParser#Mult.
    def visitMult(self, ctx:qsequenceParser.MultContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by qsequenceParser#Expression.
    def visitExpression(self, ctx:qsequenceParser.ExpressionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by qsequenceParser#expr.
    def visitExpr(self, ctx:qsequenceParser.ExprContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by qsequenceParser#qubitid.
    def visitQubitid(self, ctx:qsequenceParser.QubitidContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by qsequenceParser#gateid.
    def visitGateid(self, ctx:qsequenceParser.GateidContext):
        return self.visitChildren(ctx)



del qsequenceParser