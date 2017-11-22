function rho = stateTomoData2Rho(data,phaseCorrection)
% data: 3^n by 2^n
% row: {'Y2p','X2m','I'} => {'sigma_x','sigma_y','sigma_z'}(abbr.: {X,Y,Z})
%       1Q: {X}, {Y} ,{Z}
%       2Q: {q2:X q1:X}, {q2:X q1:Y}, {q2:X q1:I},... ,{q2:Z q1:Z}
%       X（Y）指把X（Y）翻转到Z轴，实际操作的矩阵是Y（X）
% colomn: P|00>,|01>,|10>,|11>
% qubit labeled as: |qubits{2},qubits{1}>
% in case of 2Q data(3,2): {qubits{2}:X qubits{1}:I} P|01> (|qubits{2},qubits{1}>)

    I = [1,0;0,1];
    sigma(:,:,1) = [0,1;1,0];
    sigma(:,:,2) = [0,-1i;1i,0];
    sigma(:,:,3) = [1,0;0,-1];

    single_mesure_matrix(:,:,1) = sigma(:,:,1);
    single_mesure_matrix(:,:,2) = sigma(:,:,2);
    single_mesure_matrix(:,:,3) = sigma(:,:,3);
    single_mesure_matrix(:,:,4) = I;
    
%single_trans_matrix(:,:,1)=expm(1j*(pi/4)*sigma(:,:,2));
%single_trans_matrix(:,:,2)=expm(-1j*(pi/4)*sigma(:,:,1));
%single_trans_matrix(:,:,3)=I;
%single_trans_matrix(:,:,4)=I;
    %X2p = expm(-1j*(pi/2)*sigmax/2);
    %X2m = expm(-1j*(-pi/2)*sigmax/2);
    %Y2p = expm(-1j*(pi/2)*sigmay/2);
    %Y2m = expm(-1j*(-pi/2)*sigmay/2);
    
    %求拉直化的U矩阵
    numQs = round(log(size(data,1))/log(3));
    
    if nargin < 2
        phaseCorrection = [];
    elseif numel(phaseCorrection) ~= numQs
        error('length of phaseCorrection not equal to number of qubits');
    end
    
    U=zeros(2^(2*numQs),4^numQs);
    for ii=1:4^numQs
        Measure_matrix=1;
        qubit_base_index_matrix=transform_index_fun(numQs,ii,4);
        for jj=1:numQs
            Measure_matrix=kron(single_mesure_matrix(:,:,qubit_base_index_matrix(jj)),Measure_matrix);
        end
        for jj=1:2^numQs
            U((jj-1)*2^numQs+1:(jj)*2^numQs,ii)=Measure_matrix(:,jj);
        end
    end
    
    %根据U矩阵中的测量基矢选择方式生成对应的期望（拉直化的P）
    p_order_index=zeros(1,4^numQs);
    for ii=1:4^numQs
        p_order_index(ii)=0;
        qubit_base_index_matrix=transform_index_fun(numQs,ii,4);
        for jj=1:2^numQs
            qubit_base_index_p=transform_index_fun(numQs,jj,2);
            factor=1;
            ii_trans=1;
            qubit_base_index_matrix_test=zeros(1,numQs);
            for kk=1:numQs
                if(qubit_base_index_matrix(kk)==4)
                    qubit_base_index_matrix_test(kk)=qubit_base_index_matrix(kk)-1;
                else
                    qubit_base_index_matrix_test(kk)=qubit_base_index_matrix(kk);
                    factor=factor*(-2*qubit_base_index_p(kk)+3);                    
                end
                ii_trans=ii_trans+3^(kk-1)*(qubit_base_index_matrix_test(kk)-1);
            end
            p_order_index(ii)=p_order_index(ii)+factor*data(ii_trans,jj);
        end 
    end
    
    %求拉直化的rho并将它矩阵化
    rho0=p_order_index/U;
    rho=zeros(2^numQs,2^numQs);
    for ii=1:2^numQs
        rho(ii,:)=rho0((ii-1)*2^numQs+1:ii*2^numQs);
    end
    
    if isempty(phaseCorrection)
        return;
    end
    
    r = [1,0;0,exp(-1j*phaseCorrection(1))];
    for ii = 2:numQs
        r = kron(r,[1,0;0,exp(-1j*phaseCorrection(ii))]);
    end
    rho = r'*rho*r;
end

function qubit_base_index=transform_index_fun(numQs,order_index,count_unit)
%用于下表转化（算法实质类似进制转换）
%order_index：是拉直化坐标
%numQs：新下标个数
%count_unit：新下标进制
%qubit_base_index：新下标（基于比特）的坐标
   old_index=order_index-1;
   qubit_base_index=NaN(1,numQs);
   for ii=1:numQs
       qubit_base_index(ii)=mod(old_index,count_unit)+1;
       old_index=fix(old_index/count_unit);
   end
end