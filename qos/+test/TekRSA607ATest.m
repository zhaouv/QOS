rsa_address='GPIB8::1::INSTR';
rsa=visa('ni',rsa_address);

rsa.InputBufferSize = 50e6;
rsa.Tag = 'TekRSA6K_AcquireIQData';
rsa.Timeout = 3;                    % set timeout to 3 seconds
rsa.ByteOrder = 'littleEndian';     % Instrument returns data in littleEndian format
warning('off','instrument:query:unsuccessfulRead')
fopen(rsa);

% Reset the instrument and query it
fprintf(rsa,'*RST;*CLS');
instrumentID = query(rsa,'*IDN?');
if isempty(instrumentID)
    throw(MException('RSAIQCapture:ConnectionError','Unable to connect to instrument'));
end
disp(['Connected to: ' instrumentID]);

% Abort any current measurement and set up for measurement
fprintf(rsa,'ABORt');
fprintf(rsa,'TRIGger:SEQuence:STATus 0');
fprintf(rsa,'INIT:CONT OFF');


fclose(rsa);