# -*- coding: utf-8 -*-


"""qutip的circuit能识别的门的列表
["RX","RY","RZ","SQRTNOT","SNOT","PHASEGATE","CRX","CRY","CRZ","CPHASE","CNOT","CSIGN",
"BERKELEY","SWAPalpha","SWAP","ISWAP","SQRTSWAP","SQRTISWAP","FREDKIN","TOFFOLI","GLOBALPHASE"]
"""
import gc
from qutip import *
import numpy as np
import re
from multiprocessing import Process
from multiprocessing import Queue
from multiprocessing import cpu_count
import time
import sys
import json

#print(re.match(r"(^[a-qs-z]\w*?)(\d+$)","ry90").groups())
gatenum = re.compile(r"(^[a-qs-zA-QS-Z]\w*?)(\d+$)")#多比特门的正则表达式
rtheta = re.compile(r"(^[rR][x-zX-Z])(-?\d+$)")#任意角度旋转的正则表达式
measure = re.compile(r"(^[mM][xzXZ])(-?$)")#测量的正则表达式
measuremsgn = {"-": "","": "-"}
#print(gatenum.match("ry90"))
#gatetype,num=gatenum.match(gate).groups()
#rxyz,theta=rtheta.match(gate).groups()
#mxz,sgn=measure.match(gate).groups()
def init(filename="gateforcal.csv"):
    fin = open(filename, "r")
        
    gatelistT=[line.strip().split(",") for line in fin.readlines()]
    npip=len(gatelistT)#npip个比特
    lenpip=max([len(x) for x in gatelistT])
    
    for i in gatelistT:#补成满的矩阵
        i.extend(["" for i in range(lenpip-len(i))])
    gatelist=[[gatelistT[i][j].upper() for i in range(npip)] for j in range(lenpip)]#大写并转置
    return gatelist

def initfromstring(gatestring=',,ry90,cz1,rx-90,ry-90,,rx-90,cz1,,ry90,rx90#rx-90,ry90,rx90,cz2,,ry90,x,ry-90,cz2,rx-90,ry-90,rx90'):

    gatelistT=[line.split(",") for line in gatestring.split("#")]
    npip=len(gatelistT)#npip个比特
    lenpip=max([len(x) for x in gatelistT])
    
    for i in gatelistT:#补成满的矩阵
        i.extend(["" for i in range(lenpip-len(i))])
    gatelist=[[gatelistT[i][j].upper() for i in range(npip)] for j in range(lenpip)]#大写并转置
    return gatelist

def gatecheck(gate1,gate2):#检查两个门是否是同一组的多比特门
    out=0
    if gatenum.match(gate1) and gatenum.match(gate2):
        gate1,num1=gatenum.match(gate1).groups()
        gate2,num2=gatenum.match(gate2).groups()
        if gate1==gate2 and (int(num1)+1)//2==(int(num2)+1)//2:#12,34,56,78..
            out=(int(num1)+1)//2
    return out#返回该组门是第几组,0表示不是同组多比特门
    
def addonelist(onelist):
    npip=len(onelist)
    oneqc=QubitCircuit(npip)
    for j in range(npip):
        if onelist[j]: #非空
            if not gatenum.match(onelist[j]):#单比特门
                if onelist[j]=="X" or onelist[j]=="Y" or onelist[j]=="Z":
                    onelist[j]="R"+onelist[j]+"180"
                if onelist[j]=="H":#h=ry90*z
                    oneqc.add_gate("RZ", targets=j,arg_value=np.pi,arg_label=180)
                    oneqc.add_gate("RY", targets=j,arg_value=np.pi/2,arg_label=90)
                elif rtheta.match(onelist[j]):#任意角度旋转
                    rxyz,theta=rtheta.match(onelist[j]).groups()
                    oneqc.add_gate(rxyz, targets=j,arg_value=(float(theta)/180*np.pi),arg_label=theta)
                else:
                    oneqc.add_gate(onelist[j], targets=j)
            else: #多比特门
                for k in range(j+1,npip):
                    if gatecheck(onelist[j],onelist[k]): #找到和其同组的门
                        gate,num=gatenum.match(onelist[j]).groups()
                        if gate=="CN" or gate=="CX":
                            gate="CNOT";                        
                        if gate=="ISWAP":
                            oneqc.add_gate(gate, targets=[j,k])
                        elif gate=="CZ":
                            if int(num)%2:
                                oneqc.add_gate("CSIGN", targets=k, controls=j,arg_value=np.pi,arg_label=180)
                            else:
                                oneqc.add_gate("CSIGN", targets=j, controls=k,arg_value=np.pi,arg_label=180)
                        elif int(num)%2:
                            oneqc.add_gate(gate, targets=k, controls=j)
                        else:
                            oneqc.add_gate(gate, targets=j, controls=k)
    return oneqc

def convertonegate(gate,index,oneqc_N):
    U_list = []
    if True:
        if gate.name == "RX":
            U_list.append([index,rx(gate.arg_value, oneqc_N, gate.targets[0])])
        elif gate.name == "RY":
            U_list.append([index,ry(gate.arg_value, oneqc_N, gate.targets[0])])
        elif gate.name == "RZ":
            U_list.append([index,rz(gate.arg_value, oneqc_N, gate.targets[0])])
        elif gate.name == "SQRTNOT":
            U_list.append([index,sqrtnot(oneqc_N, gate.targets[0])])
        elif gate.name == "SNOT":
            U_list.append([index,snot(oneqc_N, gate.targets[0])])
        elif gate.name == "PHASEGATE":
            U_list.append([index,phasegate(gate.arg_value, oneqc_N,
                                            gate.targets[0])])
        if gate.name == "CRX":
            U_list.append([index,controlled_gate(rx(gate.arg_value),
                                                N=oneqc_N,
                                                control=gate.controls[0],
                                                target=gate.targets[0])])
        elif gate.name == "CRY":
            U_list.append([index,controlled_gate(ry(gate.arg_value),
                                                N=oneqc_N,
                                                control=gate.controls[0],
                                                target=gate.targets[0])])
        elif gate.name == "CRZ":
            U_list.append([index,controlled_gate(rz(gate.arg_value),
                                                N=oneqc_N,
                                                control=gate.controls[0],
                                                target=gate.targets[0])])
        elif gate.name == "CPHASE":
            U_list.append([index,cphase(gate.arg_value, oneqc_N,
                                        gate.controls[0], gate.targets[0])])
        elif gate.name == "CNOT":
            U_list.append([index,cnot(oneqc_N,
                                    gate.controls[0], gate.targets[0])])
        elif gate.name == "CSIGN":
            U_list.append([index,csign(oneqc_N,
                                        gate.controls[0], gate.targets[0])])
        elif gate.name == "BERKELEY":
            U_list.append([index,berkeley(oneqc_N, gate.targets)])
        elif gate.name == "SWAPalpha":
            U_list.append([index,swapalpha(gate.arg_value, oneqc_N,
                                            gate.targets)])
        elif gate.name == "SWAP":
            U_list.append([index,swap(oneqc_N, gate.targets)])
        elif gate.name == "ISWAP":
            U_list.append([index,iswap(oneqc_N, gate.targets)])
        elif gate.name == "SQRTSWAP":
            U_list.append([index,sqrtswap(oneqc_N, gate.targets)])
        elif gate.name == "SQRTISWAP":
            U_list.append([index,sqrtiswap(oneqc_N, gate.targets)])
        elif gate.name == "FREDKIN":
            U_list.append([index,fredkin(oneqc_N, gate.controls[0],
                                        gate.targets)])
        elif gate.name == "TOFFOLI":
            U_list.append([index,toffoli(oneqc_N, gate.controls,
                                        gate.targets[0])])
        elif gate.name == "GLOBALPHASE":
            U_list.append([index,globalphase(gate.arg_value, oneqc_N)])
    return U_list

def parallel_propagators(oneqc,qout,qin):
    """
    Propagator matrix calculator for N qubits returning the individual
    steps as unitary matrices operating from left to right.

    Returns
    -------
    U_list : list
        Returns list of unitary matrices for the qubit circuit.

    """
    # oneqc.propagators() 的并行版
    # return oneqc.propagators()
    global tstart
    U_list = []
    oneqc_N=oneqc.N
    oneqc_num=len(oneqc.gates)
    
    for index,gate in zip(range(oneqc_num),oneqc.gates):
        qin.put((gate,index,oneqc_N))
    numout=0
    
    while numout<oneqc_num:
        if not qout.empty():
            ulist = qout.get()
            U_list.extend(ulist)
            numout+=1
        else:
            time.sleep(0.00001)
    
    U_list.sort(key = lambda indexgate: indexgate[0])
    
    return [gate for index,gate in U_list]
    
def kernelcal(qout,qin):
    while True:
        if qin.empty():
            time.sleep(0.00001)
        else:
            gate,index,oneqc_N=qin.get()
            qout.put(convertonegate(gate,index,oneqc_N))

def gatecal(gatelist=None):
    global tstart
    if gatelist == None:
        gatelist = init("gateforcal.csv")
    #npip=len(gatelist[0])
    #lenpip=len(gatelist)
    
    def calcal(propagator,qcp):
        
        for gate in qcp:
            propagator=gate.data*propagator
        
        return propagator
    
    kernelnum = cpu_count()
    qout = Queue() #for output
    qin = Queue() #for input
    pros = []
    for i in range(kernelnum):
        kernelprocess = Process(target = kernelcal, args = (qout,qin))
        kernelprocess.start()
        pros.append(kernelprocess)


    gatelist0=gatelist.pop(0)

    qcp=parallel_propagators(addonelist(gatelist0),qout,qin)

    propagator=qcp.pop(0).data.getcol(0)
    propagator=calcal(propagator,qcp)
    
    del qcp
    gc.collect()
    
    for onelist in gatelist:
        #qc.gates.extend(addonelist(onelist).gates)

        qcp=parallel_propagators(addonelist(onelist),qout,qin)
        #qcp=addonelist(onelist).propagators()
        
        propagator=calcal(propagator,qcp)
        del qcp
        gc.collect()
        
    #propagator[0b01000]
    #output=abs(propagator.dag()[0][0]**2)
    #print(propagator)

    
    for kernelprocess in pros:
        kernelprocess.terminate()
    
    #return str(propagator.toarray().transpose()[0].tolist()).replace('(','').replace(')','')
    return propagator

'''
from file:
ProbabilityAmplitude=gatecal(init("gateforcal18.csv"))
'''
def mainfunc(gatestring):
    if len(sys.argv)<=2:
        ProbabilityAmplitude=gatecal(initfromstring(gatestring))
    else:
        ProbabilityAmplitude=gatecal(init(sys.argv[2]))
    ProbabilityAmplitudeAsList=ProbabilityAmplitude.toarray().transpose()[0].tolist()
    RealList=[a.real for a in ProbabilityAmplitudeAsList]
    ImagList=[a.imag for a in ProbabilityAmplitudeAsList]
    print(json.dumps(
        {'real':RealList,'imag':ImagList}
    ))



if __name__ == '__main__':
    try:
        gatestring=sys.argv[1]
    except IndexError as e:
        gatestring=',,ry90,cz1,rx-90,ry-90,,rx-90,cz1,,ry90,rx90#rx-90,ry90,rx90,cz2,,ry90,x,ry-90,cz2,rx-90,ry-90,rx90'
    mainfunc(gatestring)
    


