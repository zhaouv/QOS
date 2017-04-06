# -*- coding: utf-8 -*-

# % zhaouv https://zhaouv.github.io/

# https://www.python.org/ftp/python/3.4.4/python-3.4.4.amd64.msi

# addpath('C:\Python34\Doc')
# addpath('C:\Python34\DLLs')
# addpath('C:\Python34')
# pyversion C:\Python34\python.exe


'''
mod = py.importlib.import_module('python.saveJson');    
py.importlib.reload(mod);    
result=cell(mod.func1('aaa.txt',{'da_boards{2}','name'},'s"testname"'))

'''

import re
# some regular expression used later 
linenotes=re.compile(r'^([^/]*)(//[^\n]*\n)$')
    #split row -> 'string'    '//notestr\n'
fieldnum=re.compile(r'^([^\{^\}]*?)\{(\d*)\}$')
    #split 'da_boards{2}' -> 'da_boards'   '2'
keyvalue=re.compile(r'^([^:]*:\s*)([^:]*)$')
    #split '    "class": "sync.ustc_da_v1",  \n' -> '    "class": '   '"sync.ustc_da_v1",  \n'
valuetype=re.compile('^(\s*)(.*?)(\s*,\s*|\s*)$')
    #split '"sync.ustc_da_v1",  \n' -> '"sync.ustc_da_v1"'   ',  \n'


#data structure

#filelists
#|----------filelist
#           |----------['string','note']

#filelists=[[['{','// da setting\n'],['    "class": "sync.ustc_da_v1",\n',''],['}','']]]
#-->
#{//da setting
#    "class": "sync.ustc_da_v1",
#}


#Entrance
def func1(fullfilename,fields,value):
    filelist=readfile(fullfilename)
    errornum,filelists=func2([filelist],fields,value)
    if errornum==0.0:#0.0 for succeed
        writefile(filelists,fullfilename)
    return errornum,
 
#recursion for layers
def func2(filelists,fields,value):
    leftlists=[]
    nextfilelists=[]
    rightlists=[]
    
    field=fields[0]
    fields=fields[1:]
    if fieldnum.match(field):
        field,num=fieldnum.match(field).groups()
        num=int(num)
    else:
        num=0

    filelist=filelists[0]
    for filelist2 in filelists[1:]:
        filelist.extend(filelist2)
    
    #last layer  
    if len(fields)==0:  
        errornum,filelist=func3(filelist,field,value)
        leftlists.extend([filelist])
        leftlists.extend(rightlists)
        return errornum,leftlists
        
    #not last layer 
    out_numketbra=0;
    for index in range(len(filelist)):
        #out_brace-matching
        if '{' in filelist[index][0]:
            out_numketbra+=1
        if '}' in filelist[index][0]:
            out_numketbra-=1
        field_str=filelist[index][0].split('{')[0]
        #(field in field_str)
        if re.match('\\s*"'+field+'"\\s*:', field_str) and out_numketbra==1 :# find key
            if num!=0:
                numketbra=0
                index0=index
                for index1 in range(index,len(filelist)):
                    #brace-matching
                    if '{' in filelist[index1][0]:
                        index0 = index1 if numketbra==0 else index0
                        numketbra+=1
                    if '}' in filelist[index1][0]:
                        numketbra-=1
                        num = num-1 if numketbra==0 else num
                    #goto next layer
                    if num==0:
                        sa0,sb0=filelist[index0][0].split('{')
                        sa,sb=filelist[index1][0].split('}')
                        leftlists.append(filelist[0:index0])
                        leftlists.append([[sa0,'']])
                        nextfilelists.append([['{'+sb0,filelist[index0][1]]])
                        nextfilelists.append(filelist[index0+1:index1])
                        nextfilelists.append([[sa+'}','']])
                        rightlists.append([[sb,filelist[index1][1]]])
                        rightlists.append(filelist[index1+1:])
                        #recursion
                        errornum,filelists=func2(nextfilelists,fields,value)
                        leftlists.extend(filelists)
                        leftlists.extend(rightlists)
                        return errornum,leftlists            
                return 4.0,[] #index error        
            if True:
                num=1
                numketbra=0
                index0=index
                for index1 in range(index,len(filelist)):
                    if '{' in filelist[index1][0]:
                        index0 = index1 if numketbra==0 else index0
                        numketbra+=1
                    if '}' in filelist[index1][0]:
                        numketbra-=1
                        num = num-1 if numketbra==0 else num
                    if num==0:
                        sa0,sb0=filelist[index0][0].split('{')
                        sa,sb=filelist[index1][0].split('}')
                        leftlists.append(filelist[0:index0])
                        leftlists.append([[sa0,'']])
                        nextfilelists.append([['{'+sb0,filelist[index0][1]]])
                        nextfilelists.append(filelist[index0+1:index1])
                        nextfilelists.append([[sa+'}','']])
                        rightlists.append([[sb,filelist[index1][1]]])
                        rightlists.append(filelist[index1+1:])
                        #recursion
                        errornum,filelists=func2(nextfilelists,fields,value)
                        leftlists.extend(filelists)
                        leftlists.extend(rightlists)
                        return errornum,leftlists            
    return 5.0,[] #not found key
  
#Recursive endpoint : lastlayer  
def func3(filelist,field,value):
    out_numketbra=0;
    for index in range(len(filelist)):
        #out_brace-matching
        if '{' in filelist[index][0]:
            out_numketbra+=1
        if '}' in filelist[index][0]:
            out_numketbra-=1
        field_str=filelist[index][0].split('{')[0]
        if re.match('\\s*"'+field+'"\\s*:', field_str) and out_numketbra==1 :
            keystr,valuestr=keyvalue.match(filelist[index][0]).groups()
            while(valuestr=='' or re.match('^\s*$',valuestr)):
                keystr=''
                index+=1
                valuestr=filelist[index][0]
            vs,va,vb=valuetype.match(valuestr).groups()
            if value[0] =='s' and not va[0] in '\'\"':#string
                return 1.0,[]#type error
            if value[0] == 'a':#array
                if not va[0] == '[':
                    return 1.0,[]
                if not va[-1] == ']':
                    filelist[index][0]=keystr+vs+value[1:]
                    numketbra=1;
                    for index1 in range(index+1,len(filelist)):
                        if '[' in filelist[index1][0]:
                            numketbra+=1
                        if ']' in filelist[index1][0]:
                            numketbra-=1
                        if numketbra==0:
                            sa,sb=filelist[index1][0].split(']')
                            filelist[index1][0]=sb
                            return 0.0,filelist
                        vs,va,vb=re.match('^(\s*)(.*?)(\s*)$', filelist[index1][0]).groups()
                        filelist[index1][0]=vs+vb
            if value[0] == 'n' and va[0] in '\'\"[{':#number
                return 1.0,[]
            filelist[index][0]=keystr+vs+value[1:]+vb
            return 0.0,filelist #succeed
    return 5.0,[] #not found key
    
#read file and turn it into list of ['string','note']
def readfile(filename):
    fin = open(filename, "r")
    filelist_=[]
    filelist=fin.readlines()
    for index in range(len(filelist)):
        if linenotes.match(filelist[index]):
            before,note=linenotes.match(filelist[index]).groups()
            filelist[index]=[before,note]
        else:
            filelist[index]=[filelist[index],'']
    for i in filelist:
        a=i[0].split('{')
        for j in a[:-1]:
            filelist_.append([j,''])
            filelist_.append(['\n{\n',''])           
        filelist_.append([a[-1],i[1]])
    filelist=[]
    for i in filelist_:
        a=i[0].split('}')
        for j in a[:-1]:
            filelist.append([j,''])
            filelist.append(['\n}\n',''])            
        filelist.append([a[-1],i[1]])
    return filelist

def writefile(strlists,filename):
    fout = open(filename, 'w')
    fstr=''
    for strlist in strlists:
        for i in strlist:
            fstr+=i[0]
            fstr+=i[1]
    fout.write(fstr.replace('\n{\n','{').replace('\n}\n','}'))
    fout.close()


#filelist=readfile("aaa.txt")
#errornum,filelists=func2([filelist],("da_chnl_map{3}","ch3"),'s"asedssa"')
#errornum,filelists=func2([filelist],("layer2","carray"),'a[3,4,1]')
#func1("aaa.txt",("channels","xy_q","instru"),'s"safdf"')
#func1("aaa.txt",("da_chnl_map{3}","ch3"),'s"asyrsa"')
#func1("aaa.txt",("layer2","layer3","cname"),'s"safdf"')
#func1("aaa.txt",("chnlMap",),'a[2,2,3,4]')
#func1("aaa.txt",('da_boards{2}','name'),'s"testn"')
