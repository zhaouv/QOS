# Generated from qsequence.g4 by ANTLR 4.7
# encoding: utf-8
from antlr4 import *
from io import StringIO
from typing.io import TextIO
import sys

def serializedATN():
    with StringIO() as buf:
        buf.write("\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\13")
        buf.write("\66\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\3\2\3\2\3")
        buf.write("\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3")
        buf.write("\5\3\35\n\3\3\3\3\3\7\3!\n\3\f\3\16\3$\13\3\3\4\3\4\3")
        buf.write("\4\3\4\3\4\7\4+\n\4\f\4\16\4.\13\4\3\4\3\4\3\5\3\5\3\6")
        buf.write("\3\6\3\6\2\3\4\7\2\4\6\b\n\2\2\2\64\2\f\3\2\2\2\4\34\3")
        buf.write("\2\2\2\6%\3\2\2\2\b\61\3\2\2\2\n\63\3\2\2\2\f\r\5\4\3")
        buf.write("\2\r\3\3\2\2\2\16\17\b\3\1\2\17\35\5\6\4\2\20\21\5\6\4")
        buf.write("\2\21\22\7\3\2\2\22\23\5\6\4\2\23\35\3\2\2\2\24\25\7\4")
        buf.write("\2\2\25\26\5\4\3\2\26\27\7\5\2\2\27\30\7\3\2\2\30\31\7")
        buf.write("\4\2\2\31\32\5\4\3\2\32\33\7\5\2\2\33\35\3\2\2\2\34\16")
        buf.write("\3\2\2\2\34\20\3\2\2\2\34\24\3\2\2\2\35\"\3\2\2\2\36\37")
        buf.write("\f\3\2\2\37!\5\4\3\4 \36\3\2\2\2!$\3\2\2\2\" \3\2\2\2")
        buf.write("\"#\3\2\2\2#\5\3\2\2\2$\"\3\2\2\2%&\5\n\6\2&\'\7\6\2\2")
        buf.write("\',\5\b\5\2()\7\7\2\2)+\5\b\5\2*(\3\2\2\2+.\3\2\2\2,*")
        buf.write("\3\2\2\2,-\3\2\2\2-/\3\2\2\2.,\3\2\2\2/\60\7\b\2\2\60")
        buf.write("\7\3\2\2\2\61\62\7\t\2\2\62\t\3\2\2\2\63\64\7\n\2\2\64")
        buf.write("\13\3\2\2\2\5\34\",")
        return buf.getvalue()


class qsequenceParser ( Parser ):

    grammarFileName = "qsequence.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "'*'", "'['", "']'", "'('", "','", "')'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "INT", "GATECHAR", 
                      "WS" ]

    RULE_prog = 0
    RULE_gc = 1
    RULE_expr = 2
    RULE_qubitid = 3
    RULE_gateid = 4

    ruleNames =  [ "prog", "gc", "expr", "qubitid", "gateid" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    T__4=5
    T__5=6
    INT=7
    GATECHAR=8
    WS=9

    def __init__(self, input:TokenStream, output:TextIO = sys.stdout):
        super().__init__(input, output)
        self.checkVersion("4.7")
        self._interp = ParserATNSimulator(self, self.atn, self.decisionsToDFA, self.sharedContextCache)
        self._predicates = None



    class ProgContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def gc(self):
            return self.getTypedRuleContext(qsequenceParser.GcContext,0)


        def getRuleIndex(self):
            return qsequenceParser.RULE_prog

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterProg" ):
                listener.enterProg(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitProg" ):
                listener.exitProg(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitProg" ):
                return visitor.visitProg(self)
            else:
                return visitor.visitChildren(self)




    def prog(self):

        localctx = qsequenceParser.ProgContext(self, self._ctx, self.state)
        self.enterRule(localctx, 0, self.RULE_prog)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 10
            self.gc(0)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class GcContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return qsequenceParser.RULE_gc

     
        def copyFrom(self, ctx:ParserRuleContext):
            super().copyFrom(ctx)


    class TensorgcContext(GcContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a qsequenceParser.GcContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def gc(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(qsequenceParser.GcContext)
            else:
                return self.getTypedRuleContext(qsequenceParser.GcContext,i)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterTensorgc" ):
                listener.enterTensorgc(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitTensorgc" ):
                listener.exitTensorgc(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitTensorgc" ):
                return visitor.visitTensorgc(self)
            else:
                return visitor.visitChildren(self)


    class TensoreContext(GcContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a qsequenceParser.GcContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def expr(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(qsequenceParser.ExprContext)
            else:
                return self.getTypedRuleContext(qsequenceParser.ExprContext,i)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterTensore" ):
                listener.enterTensore(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitTensore" ):
                listener.exitTensore(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitTensore" ):
                return visitor.visitTensore(self)
            else:
                return visitor.visitChildren(self)


    class MultContext(GcContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a qsequenceParser.GcContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def gc(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(qsequenceParser.GcContext)
            else:
                return self.getTypedRuleContext(qsequenceParser.GcContext,i)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterMult" ):
                listener.enterMult(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitMult" ):
                listener.exitMult(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitMult" ):
                return visitor.visitMult(self)
            else:
                return visitor.visitChildren(self)


    class ExpressionContext(GcContext):

        def __init__(self, parser, ctx:ParserRuleContext): # actually a qsequenceParser.GcContext
            super().__init__(parser)
            self.copyFrom(ctx)

        def expr(self):
            return self.getTypedRuleContext(qsequenceParser.ExprContext,0)


        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterExpression" ):
                listener.enterExpression(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitExpression" ):
                listener.exitExpression(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitExpression" ):
                return visitor.visitExpression(self)
            else:
                return visitor.visitChildren(self)



    def gc(self, _p:int=0):
        _parentctx = self._ctx
        _parentState = self.state
        localctx = qsequenceParser.GcContext(self, self._ctx, _parentState)
        _prevctx = localctx
        _startState = 2
        self.enterRecursionRule(localctx, 2, self.RULE_gc, _p)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 26
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,0,self._ctx)
            if la_ == 1:
                localctx = qsequenceParser.ExpressionContext(self, localctx)
                self._ctx = localctx
                _prevctx = localctx

                self.state = 13
                self.expr()
                pass

            elif la_ == 2:
                localctx = qsequenceParser.TensoreContext(self, localctx)
                self._ctx = localctx
                _prevctx = localctx
                self.state = 14
                self.expr()
                self.state = 15
                self.match(qsequenceParser.T__0)
                self.state = 16
                self.expr()
                pass

            elif la_ == 3:
                localctx = qsequenceParser.TensorgcContext(self, localctx)
                self._ctx = localctx
                _prevctx = localctx
                self.state = 18
                self.match(qsequenceParser.T__1)
                self.state = 19
                self.gc(0)
                self.state = 20
                self.match(qsequenceParser.T__2)
                self.state = 21
                self.match(qsequenceParser.T__0)
                self.state = 22
                self.match(qsequenceParser.T__1)
                self.state = 23
                self.gc(0)
                self.state = 24
                self.match(qsequenceParser.T__2)
                pass


            self._ctx.stop = self._input.LT(-1)
            self.state = 32
            self._errHandler.sync(self)
            _alt = self._interp.adaptivePredict(self._input,1,self._ctx)
            while _alt!=2 and _alt!=ATN.INVALID_ALT_NUMBER:
                if _alt==1:
                    if self._parseListeners is not None:
                        self.triggerExitRuleEvent()
                    _prevctx = localctx
                    localctx = qsequenceParser.MultContext(self, qsequenceParser.GcContext(self, _parentctx, _parentState))
                    self.pushNewRecursionContext(localctx, _startState, self.RULE_gc)
                    self.state = 28
                    if not self.precpred(self._ctx, 1):
                        from antlr4.error.Errors import FailedPredicateException
                        raise FailedPredicateException(self, "self.precpred(self._ctx, 1)")
                    self.state = 29
                    self.gc(2) 
                self.state = 34
                self._errHandler.sync(self)
                _alt = self._interp.adaptivePredict(self._input,1,self._ctx)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.unrollRecursionContexts(_parentctx)
        return localctx

    class ExprContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def gateid(self):
            return self.getTypedRuleContext(qsequenceParser.GateidContext,0)


        def qubitid(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(qsequenceParser.QubitidContext)
            else:
                return self.getTypedRuleContext(qsequenceParser.QubitidContext,i)


        def getRuleIndex(self):
            return qsequenceParser.RULE_expr

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterExpr" ):
                listener.enterExpr(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitExpr" ):
                listener.exitExpr(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitExpr" ):
                return visitor.visitExpr(self)
            else:
                return visitor.visitChildren(self)




    def expr(self):

        localctx = qsequenceParser.ExprContext(self, self._ctx, self.state)
        self.enterRule(localctx, 4, self.RULE_expr)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 35
            self.gateid()
            self.state = 36
            self.match(qsequenceParser.T__3)
            self.state = 37
            self.qubitid()
            self.state = 42
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==qsequenceParser.T__4:
                self.state = 38
                self.match(qsequenceParser.T__4)
                self.state = 39
                self.qubitid()
                self.state = 44
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 45
            self.match(qsequenceParser.T__5)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class QubitidContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def INT(self):
            return self.getToken(qsequenceParser.INT, 0)

        def getRuleIndex(self):
            return qsequenceParser.RULE_qubitid

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterQubitid" ):
                listener.enterQubitid(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitQubitid" ):
                listener.exitQubitid(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitQubitid" ):
                return visitor.visitQubitid(self)
            else:
                return visitor.visitChildren(self)




    def qubitid(self):

        localctx = qsequenceParser.QubitidContext(self, self._ctx, self.state)
        self.enterRule(localctx, 6, self.RULE_qubitid)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 47
            self.match(qsequenceParser.INT)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx

    class GateidContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def GATECHAR(self):
            return self.getToken(qsequenceParser.GATECHAR, 0)

        def getRuleIndex(self):
            return qsequenceParser.RULE_gateid

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterGateid" ):
                listener.enterGateid(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitGateid" ):
                listener.exitGateid(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitGateid" ):
                return visitor.visitGateid(self)
            else:
                return visitor.visitChildren(self)




    def gateid(self):

        localctx = qsequenceParser.GateidContext(self, self._ctx, self.state)
        self.enterRule(localctx, 8, self.RULE_gateid)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 49
            self.match(qsequenceParser.GATECHAR)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx



    def sempred(self, localctx:RuleContext, ruleIndex:int, predIndex:int):
        if self._predicates == None:
            self._predicates = dict()
        self._predicates[1] = self.gc_sempred
        pred = self._predicates.get(ruleIndex, None)
        if pred is None:
            raise Exception("No predicate with index:" + str(ruleIndex))
        else:
            return pred(localctx, predIndex)

    def gc_sempred(self, localctx:GcContext, predIndex:int):
            if predIndex == 0:
                return self.precpred(self._ctx, 1)
         




