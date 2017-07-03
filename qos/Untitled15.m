mI = [1,0;0,1];
mX = [0,1;1,0];
mY = [0,-1i;1i,0];

mX2p = expm(-1j*(pi/2)*mX/2);
mX2m = expm(-1j*(-pi/2)*mX/2);

mY2p = expm(-1j*(pi/2)*mY/2);
mY2m = expm(-1j*(-pi/2)*mY/2);

singleQGateSet_m = {mI, mX, mY, mX*mY,...
                                mY2p*mX2p, mY2m*mX2p, mY2p*mX2m, mY2m*mX2m,...
                                mX2p*mY2p, mX2m*mY2p, mX2p*mY2m, mX2m*mY2m,...
                                mX2p, mX2m, mY2p, mY2m,...
                                mX2p*mY2p*mX2m, mX2p*mY2m*mX2m,...
                                mY2p*mX, mY2m*mX, mX2p*mY, mX2m*mY,...
                                mX2p*mY2p*mX2p, mX2m*mY2p*mX2m};
                            
numGates = numel(singleQGateSet_m);

tbl = NaN*ones(numGates,numGates);
for ii = 1:numGates
    for jj = 1:numGates
        mij = singleQGateSet_m{ii}*singleQGateSet_m{jj};
        for kk = 1:numGates
            mi = singleQGateSet_m{kk}*mij;
            if abs(mi(1,2)) + abs(mi(2,1)) < 0.0001 &&...
                    (abs(angle(mi(1,1)) - angle(mi(2,2))) < 0.0001 ||...
                    abs(abs(angle(mi(1,1)) - angle(mi(2,2)))- 2*pi) < 0.0001)
                break;
            end
            if kk == 24
                error('error!');
            end
        end
        tbl(ii,jj) = kk;
    end
end
