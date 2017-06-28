function chi = processTomoData2Rho(data)
    rho = cell(1,4);
    for ii = 1:size(data,1)
        rho{ii} = sqc.qfcns.stateTomoData2Rho(squeeze(data(ii,:,:)));
    end
    
%     rho{1} = [0,0;0,1];
%     rho{2} = [1,0;0,0];
%     rho{3} = [0.5,0.5;0.5,0.5];
%     rho{4} = [0.5,-0.5i;0.5i,0.5];
    
    r = [rho{1},...
        rho{3}+1j*rho{4}-(1+1j)*(rho{1}+rho{2})/2;...
        rho{3}-1j*rho{4}-(1-1j)*(rho{1}+rho{2})/2,...
        rho{2}];
%     lambda = [1 0 0 1; 0 1 1 0; 0 1 -1 0; 1 0 0 -1];
     lambda = [1 0 0 1; 0 1 1 0; 0 1j -1j 0; 1 0 0 -1];
    chi = conj(lambda)*r*lambda.'/4;
end