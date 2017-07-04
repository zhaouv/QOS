function [center0, center1, F00,F11,hf] =...
			iq2prob_centers(iq_raw_0,iq_raw_1,auto)
% iq2prob_centers: finds raw iq centers(where probability of distribution is maximum)
% F00: the probability of |0> correctly measured as |0>
% F11:  the probability of |1> correctly measured as |0>
% F01: the probability of |0> erroneously measured as |1>
% F10: the probability of |1> erroneously measured as |0>
% define:
% F = [F00,F10; F01,F11],
% Pm = [Pm0; Pm1]; % the measured probability
% for a state
% S = a|0> + b|1>;
% P = [P0; P1] = [abs(a); abs(b)]; % real real |0>, |1> state probability
% by definition:
% Pm = F*[P0; P1];
% thus we have:
% P = inv(F)*Pm;

% Yulin Wu, 2017

    [~, ang, ~, ~,hf] =... 
		data_taking.public.dataproc.iq2prob_maxVisibilityProjectionLine(iq_raw_0,iq_raw_1,auto);
    iq_raw_0_ = iq_raw_0*exp(-1j*ang);
    iq_raw_1_ = iq_raw_1*exp(-1j*ang);
    
    num_samples = numel(iq_raw_0);
    if num_samples < 2e4
        nBins = 50;
    else
        nBins = 100;
    end
 
    e0 = real(iq_raw_0_);
	e0_ = abs(e0 - mean(e0));
	e0(e0_ > 2*std(e0_)) = []; % remove outerliers
	e1 = real(iq_raw_1_);
	e1_ = abs(e1 - mean(e1));
	e1(e1_ > 2*std(e1_)) = []; % remove outerliers

	x_0 = min(e0);
    x_1 = max(e0);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
% 	[~, idx] = max(smooth(histcounts(e0,binEdges)/num_samples,3));
% 	c0r = binEdges(idx)+binSize/2;
    
    dis = smooth(histcounts(e0,binEdges)/num_samples,5);  % smooth with 5 is better than with 3
    xi = binEdges(1)+binSize/2:binSize/5:binEdges(end-1)+binSize/2;
    disi = interp1(binEdges(1)+binSize/2:binSize:binEdges(end-1)+binSize/2,dis,xi);
	[~, idx] = max(disi);
	c0r = xi(idx);
	
	x_0 = min(e1);
    x_1 = max(e1);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
    
    
    dis = smooth(histcounts(e1,binEdges)/num_samples,5);
    xi = binEdges(1)+binSize/2:binSize/5:binEdges(end-1)+binSize/2;
    disi = interp1(binEdges(1)+binSize/2:binSize:binEdges(end-1)+binSize/2,dis,xi);
	[~, idx] = max(disi);
	c1r = xi(idx);
    %%
	e0 = imag(iq_raw_0_);
	e0_ = abs(e0 - mean(e0));
	e0(e0_ > 2*std(e0_)) = []; % remove outerliers
	e1 = imag(iq_raw_1_);
	e1_ = abs(e1 - mean(e1));
	e1(e1_ > 2*std(e1_)) = []; % remove outerliers

	x_0 = min(e0);
    x_1 = max(e0);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
% 	[~, idx] = max(smooth(histcounts(e0,binEdges)/num_samples,3));
% 	c0i = binEdges(idx)+binSize/2;
    
    dis = smooth(histcounts(e0,binEdges)/num_samples,5);
    xi = binEdges(1)+binSize/2:binSize/5:binEdges(end-1)+binSize/2;
    disi = interp1(binEdges(1)+binSize/2:binSize:binEdges(end-1)+binSize/2,dis,xi);
	[~, idx] = max(disi);
	c0i = xi(idx);
	
	x_0 = min(e1);
    x_1 = max(e1);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
% 	[~, idx] = max(smooth(histcounts(e1,binEdges)/num_samples,3));
% 	c1i = binEdges(idx)+binSize/2;
    
    dis = smooth(histcounts(e1,binEdges)/num_samples,5);
    xi = binEdges(1)+binSize/2:binSize/5:binEdges(end-1)+binSize/2;
    disi = interp1(binEdges(1)+binSize/2:binSize:binEdges(end-1)+binSize/2,dis,xi);
	[~, idx] = max(disi);
	c1i = xi(idx);
    
    %
    center0 = (c0r+1j*c0i)*exp(1j*ang);
    center1 = (c1r+1j*c1i)*exp(1j*ang);
    %
	e0 = real(iq_raw_0_);
	e1 = real(iq_raw_1_);
	cc = (c0r+c1r)/2;
	if c1r > c0r
		F00 = sum(e0<=cc)/num_samples; % the probability of |0> correctly measured as |0>
		F11 = sum(e1>=cc)/num_samples; % the probability of |1> correctly measured as |0>
	else
		F00 = sum(e0>=cc)/num_samples;
		F11 = sum(e1<=cc)/num_samples;
	end
%	F01 = 1-F00; % the probability of |0> erroneously measured as |1>
%	F10 = 1-F11; % the probability of |1> erroneously measured as |0>
end