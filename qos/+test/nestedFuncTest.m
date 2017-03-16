function nestedFcnTest()
    ii = -1;
    function nfcn()
        disp(ii);
    end
    for ii = 1:10
        nfcn();
    end
end