# -*- coding: utf-8 -*-

# https://www.python.org/ftp/python/3.4.4/python-3.4.4.amd64.msi

# addpath('C:\Python34\Doc')
# addpath('C:\Python34\DLLs')
# addpath('C:\Python34')
# pyversion C:\Python34\python.exe

import re
#notes=re.compile(r'^(.*?)([^\n^/]*)(//[^\n]*)(.*)$',re.DOTALL)
notes=re.compile(r'^([^/]*)(//[^\n]*\n)(.*)$',re.DOTALL)
linenotes=re.compile(r'^([^/]*)(//[^\n]*\n)$')
fieldnum=re.compile(r'^([^\{^\}]*?)\{(\d*)\}$')
keyvalue=re.compile(r'^([^:]*:\s*)([^:]*)$')
valuetype=re.compile('^(.*?)(\s*,|\s*)([^\\]\\}\\\'",]*)$')


def func1(fullfilename,fields,value):
    errornum,filelist=func2(fullfilename,fields,value)
    if errornum==0:
        writefile(filelist,fullfilename)
    return errornum,
 

def func2(fullfilename,fields,value):
    filelist=readfile(fullfilename)
    for index in range(len(filelist)):
        if linenotes.match(filelist[index]):
            before,note=linenotes.match(filelist[index]).groups()
            filelist[index]=[before,note]
        else:
            filelist[index]=[filelist[index],'']
            
    field=fields[0];fields=fields[1:]
    if fieldnum.match(field):
        field,num=fieldnum.match(field).groups()
        num=int(num)
    else:
        num=-1
    if len(fields)==0: #last layer   
        for index in range(len(filelist)):
            if field in filelist[index][0]:
                keystr,valuestr=keyvalue.match(filelist[index][0]).groups()
                if value[0] =='s' and not valuestr[0] in '\'\"':
                    return 1,[]
                if value[0] == 'a' and not valuestr[0] == '[':
                    return 1,[]
                if value[0] == 'c' and not valuestr[0] == '{':
                    return 1,[]
                if value[0] == 'n' and valuestr[0] in '\'\"[{':
                    return 1,[]
                va,vb,vc=valuetype.match(valuestr).groups()
                filelist[index][0]=keystr+value[1:]+vb+vc
                return 0,filelist
    return 2.0,[]
    

def split_note(strlist,string):
    if notes.match(string):
        before,note,after=notes.match(string).groups()
        strlist.extend([before,note])
        split_note(strlist,after)
    else:
        strlist.append(string)

def readfile(filename):
    fin = open(filename, "r")
    return fin.readlines()

def writefile(strlist,filename):
    fout = open(filename, 'w')
    for i in strlist:
        for j in i:
            fout.write("%s"%(j))
    fout.close()#会覆盖原�?�的内容


'''
mod = py.importlib.import_module('python.saveJson');    
py.importlib.reload(mod);    
result=cell(mod.func1('aaa.txt',{'ad_boards{1}','numChnls'},3))

%result =
%
%  1×3 cell Array
%
%    [2]    [3]    [4]
'''