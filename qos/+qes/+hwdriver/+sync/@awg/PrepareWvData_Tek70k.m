function [WaveformData] = PrepareWvData_Tek70k(WaveformObj)
    % this function is a static private method
    % Tek awg 70k only support float wave data

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    t = WaveformObj.t0:WaveformObj.t0+WaveformObj.length-1;
    y = WaveformObj(t);
    if WaveformObj.iq
        WaveformData = [real(y);imag(y)];
    else
        WaveformData = real(y);
    end
    WaveformData = WaveformData*4; % this is due to a singular feature of awg 70k: output is 1/4 in amplitude of the waveform data.
    
%     WvfrmVpp = WaveformObj.vpp;
%     Offset = WaveformObj.offset;
%     VHi = Offset + WvfrmVpp/2;
%     VLo = Offset - WvfrmVpp/2;
%     AWGVpp = 2*max(abs(VHi),abs(VLo));
%     if WaveformObj.fixawgvpp
%         % todo
%     end
    
% marker are removed in newer version for efficiency consideration
%     Vpp = 0.5;
%     Offset = 0;   
%     MarkerData = [];
%     MarkerVpp = [];
%     MarkerOffset = [];
%     if isempty(WaveformObj.markers) % no markers
%         return;
%     end
%     if isempty(WaveformObj.markers{1}.wvdata)
%         WaveformObj.markers{1}.GenWave();
%     end
%     MarkerVpp = NaN*zeros(1,2);
%     MarkerOffset = NaN*zeros(1,2);
%     Marker1Data = WaveformObj.markers{1}.wvdata;
%     if range(Marker1Data) > 0
%         Marker1Data = Marker1Data + 0.5;
%     end
%     Marker1Data(Marker1Data<0.5) = 0; % marker data can only be 0 or 1.
%     Marker1Data(Marker1Data>=0.5) = 1;
%     MarkerVpp(1) = WaveformObj.markers{1}.vpp;
%     MarkerOffset(1) = WaveformObj.markers{1}.offset;
%     Marker2Data = zeros(1,WaveformObj.length);
%     if numel(WaveformObj.markers) == 2
%         if isempty(WaveformObj.markers{2}.wvdata)
%             WaveformObj.markers{2}.GenWave();
%         end
%         Marker2Data = WaveformObj.markers{2}.wvdata;
%         if range(Marker2Data) > 0
%             Marker2Data = Marker2Data + 0.5;
%         end
%         Marker2Data(Marker2Data<0.5) = 0; % marker data can only be 0 or 1.
%         Marker2Data(Marker2Data>=0.5) = 1;
%         MarkerVpp(2) = WaveformObj.markers{2}.vpp;
%         MarkerOffset(2) = WaveformObj.markers{2}.offset;
%     end
%     MarkerData = uint8(Marker1Data*2^6 + Marker2Data*2^7);
end