% GM, 2017/6/22
if exist('ustcaddaObj','var')
    ustcaddaObj.close()
end
if (~isempty(instrfind))
    fclose(instrfind);
    delete(instrfind);
end
clear all
clc
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\Dropbox\MATLAB GUI\USTC Measurement System\settings');
QS.SU('Ming');
QS.SS('s170627');
QS.CreateHw();
ustcaddaObj = ustcadda_v1.GetInstance();
% qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
qubits = {'q10','q9','q8','q7','q6','q5','q4','q3','q2','q1'};
dips = [6.50926 6.55372 6.59601 6.63229 6.68206 6.71959 6.76125 6.78996 6.80369 6.84277]*1e9; % by qubit index
