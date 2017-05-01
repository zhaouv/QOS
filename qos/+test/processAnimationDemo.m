function processAnimationDemo()

    import sqc.op.logical.gate.*
    initialState = sqc.qs.state('|0>');
%     gates = {Z2m};
    gates = {H,Y,H,X,Y4p,Y2m,Z,Y2p,X4m,Y,X4p,H,X4m,Y};
    sqc.util.processAnimation(gates,initialState);

end