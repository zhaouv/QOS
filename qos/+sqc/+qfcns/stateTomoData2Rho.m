function rho = stateTomoData2Rho(data)


    sigmaz = [1,0;0,-1];
    sigmax = [0,1;1,0];
    sigmay = [0,-1i;1i,0];
    
    I = [1,0;0,1];
    X2p = expm(-1j*(pi/2)*sigmax/2);
    % X2m = expm(-1j*(-pi/2)*sigmax/2);

    % Y2p = expm(-1j*(pi/2)*sigmay/2);
    Y2m = expm(-1j*(-pi/2)*sigmay/2);
    
    numQs = round(log(size(data,1))/log(3));
    switch numQs
        case 1
            data = data*[1;-1];
            rho = (data(3)*sigmaz + data(2)*sigmay + data(1)*sigmax+eye(2))/2;
        case 2
            
            data(:,[2,3]) = data(:,[3,2]);
            
            u = {Y2m,X2p,I};
            U = cell(3,3);
            for ii = 1:3
                for jj = 1:3
                    U{ii,jj} = kron(u{ii},u{jj});
                end
            end

            R = NaN(36,16);
            for ii = 1:4
                for jj = 1:4
                    for kk = 1:4
                        for ui = 1:3
                            for uj = 1:3
                                u_ = U{ui,uj};
                                R((kk-1)*9+(ui-1)*3+uj,(ii-1)*4+jj) = ...
                                   u_(kk,ii)*conj(u_(kk,jj));
                            end
                        end
                    end
                end
            end

            D = NaN(36,1);
            for kk = 1:4
                for ui = 1:3
                    for uj = 1:3
                        D((kk-1)*9+(ui-1)*3+uj) = ...
                            data((ui-1)*3+uj,kk);
                    end
                end
            end

            rho_ = R\D;

            rho = NaN(4,4);
            for ii = 1:4
                for jj = 1:4
                    rho(ii,jj) = rho_((ii-1)*4+jj);
                end
            end
        otherwise 
            error('TODO');
    end
end