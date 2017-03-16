function WaveformData = PrepareWvData_Tek5k7k(obj,WaveformObj,DAVpp,NB,software_delay)
    % WaveformData: uint16
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    t = WaveformObj.t0:ceil(WaveformObj.t0+WaveformObj.length);
    y = WaveformObj(t);
    if WaveformObj.iq
%         if WaveformObj.q_delay < 0
%             software_delay = [software_delay-WaveformObj.q_delay, software_delay];
%         else
%             software_delay = [software_delay, software_delay+WaveformObj.q_delay];
%         end
        mzeros = obj.MixerZeros(WaveformObj.fc);
        WaveformData = {[zeros(1,software_delay(1)),real(y),0];...
            [zeros(1,software_delay(2)),imag(y),0]}; 
        WaveformData{1} = WaveformData{1} + mzeros(1);
        WaveformData{2} = WaveformData{1} + mzeros(2);
        N = 2;
    else
        WaveformData = {[zeros(1,software_delay),real(y),0]};
        N = 1;
    end
    
    for ii = 1:N
        VHi = max(WaveformData{ii});
        VLo = min(WaveformData{ii});
        Vpp =  VHi - VLo;
        WaveformData{ii}  = WaveformData{ii} - (VHi + VLo)/2;
        if Vpp > 0 
            WaveformData{ii} = WaveformData{ii}/Vpp;
        end

        if Vpp > 0
            WaveformData{ii} = WaveformData{ii} + 0.5;
        end

        RequiredMinDAVpp = 2*max(abs(VHi),abs(VLo));
%         if DAVpp < RequiredMinDAVpp - 1e-4
%             error('AWG:PrepareWvDataError',['Waveform Vpp out of DA Vpp range, maximum: ', num2str(DAVpp,'%0.4f'),...
%                 ', ', num2str(RequiredMinDAVpp,'%0.4f'),' required at: ', WaveformObj.awg.name, num2str(WaveformObj.awgchnl,' channel %0.0f.')]);
%         end
        
        if DAVpp < RequiredMinDAVpp
            warning('QOS_AWG:VppOutOfRange', 'Waveform Vpp out of DA Vpp range, clipping.');
            WaveformData{ii}(WaveformData{ii}>DAVpp/2) = DAVpp/2;
            WaveformData{ii}(WaveformData{ii}<-DAVpp/2) = -DAVpp/2;
            RequiredMinDAVpp = DAVpp;
        end

        K = 2^NB-1;
        if Vpp > 0
            r1 = (1-RequiredMinDAVpp/DAVpp)/2;
            r2 = Vpp/DAVpp;
            if abs(VHi)>= abs(VLo)
                WaveformData{ii} = round(K*(r2*WaveformData{ii}+1-r2-r1));
            else
                WaveformData{ii} = round(K*(r2*WaveformData{ii}+r1));
            end
        else % DC
            WaveformData{ii} = (2^(NB-1)-1)*(1 + VHi/(DAVpp/2))*ones(1,numel(WaveformData{ii}));
        end
% 		irfs = obj.irf{WaveformObj.awgchnl(ii)};
% 		numirfs = numel(irfs);
% 		for jj = 1:numirfs
% 			error('to be implemented');
% 			WaveformData{ii} = deconv(WaveformData{ii},irfs(jj));
%         end
        if NB <= 8
            WaveformData{ii} = uint8(WaveformData{ii});
        elseif NB <= 16
            WaveformData{ii} = uint16(WaveformData{ii});
        else
            WaveformData{ii} = uint32(WaveformData{ii});
        end
    end

    
end