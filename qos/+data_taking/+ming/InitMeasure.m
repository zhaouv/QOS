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
QS.SS('s170725');
QS.CreateHw();
ustcaddaObj = ustcadda_v1.GetInstance();
% qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
qubits = {'q10','q9','q8','q7','q6','q5','q4','q3','q2','q1'};
dips = [6.58990 6.62315 6.64151 6.65922 6.68244 6.70705 6.75451 6.79346 6.81783 6.84831]*1e9; % by qubit index
