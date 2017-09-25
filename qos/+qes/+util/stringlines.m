function output=stringlines(idstr,mpath)
%{
>>>example
a=qes.util.stringlines('example',mfilename('fullpath'));
disp(a);
%}
fid=fopen([mpath,'.m'],'r');
str=fread(fid);
fclose(fid);
str=char(str');
expression=sprintf(['%%{(\r\n|\n)>>>',idstr,'(\r\n|\n)','.*?(\r\n|\n)%%}']);
[startIndex,endIndex] = regexp(str,expression);
if numel(startIndex) ~=1
    error(['find ',char(string(numel(startIndex))),' ',idstr])
end
output=str(startIndex:endIndex);
strcell=split(output,sprintf('\n'));
output=char(join({strcell{3:end}},sprintf('\n')));
if output(end-3)==sprintf('\r')
    output=output(1:end-4);
else
    output=output(1:end-3);
end
end