function rho = stateTomoData2Rho(data)
    sigmaz = [1,0;0,-1];
    sigmax = [0,1;1,0];
    sigmay = [0,-1i;1i,0];
    data = data*[1;-1];
    rho = (data(3)*sigmaz + data(2)*sigmay + data(1)*sigmax+eye(2))/2;
end