for ii = 1:40
    ustcaddaObj.SendWave(ii,[zeros(1,4000),65535*ones(1,4000)]);
end
ustcaddaObj.Run(true);
%%
for ii = 1:40
    ustcaddaObj.SendWave(ii,32768+32768*sin((1:8000)/1000*2*pi));
end
ustcaddaObj.Run(true);