if __name__ is not None and "." in __name__:
    from .qsequenceParser import qsequenceParser
    from .qsequenceVisitor import qsequenceVisitor
else:
    from qsequenceParser import qsequenceParser
    from qsequenceVisitor import qsequenceVisitor


class EvalVisitor(qsequenceVisitor):

    def visitProg(self, ctx:qsequenceParser.ProgContext):
        gatelist=self.visit(ctx.gc())
        return gatelist

    def visitTensorgc(self, ctx:qsequenceParser.TensorgcContext):
        gc0 = self.visit(ctx.gc(0))
        gc1 = self.visit(ctx.gc(1))
        if len(gc0)>=len(gc1):
            for index,one in enumerate(gc1):
                gc0[index].extend(one)
            return gc0
        else:
            for index in range(len(gc0)):
                gc0[index].extend(gc1[index])
                gc1[index]=gc0[index]
            return gc1


    def visitTensore(self, ctx:qsequenceParser.TensoreContext):
        expr0 = self.visit(ctx.expr(0))
        expr1 = self.visit(ctx.expr(1))
        return [[expr0,expr1]]


    def visitMult(self, ctx:qsequenceParser.MultContext):
        gc0 = self.visit(ctx.gc(0))
        gc1 = self.visit(ctx.gc(1))
        gc0.extend(gc1)
        return gc0


    def visitExpression(self, ctx:qsequenceParser.ExpressionContext):
        expr = self.visit(ctx.expr())
        return [[expr]]


    def visitExpr(self, ctx:qsequenceParser.ExprContext):
        gateid = ctx.gateid().getText()
        qubitid=[one.getText() for one in ctx.qubitid()]
        return (gateid,qubitid)







