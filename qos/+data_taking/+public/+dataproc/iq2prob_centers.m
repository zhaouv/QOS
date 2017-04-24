function [center0, center1, hf] =...
			iq2prob_centers(iq_raw_0,iq_raw_1,auto)
% iq2prob_centers: finds raw iq centers(where probability of distribution is maximum)

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
    %%
    e0 = real(iq_raw_0_);
	e0_ = abs(e0 - mean(e0));
	e0(e0_ > 3*median(e0_)) = []; % remove possible outerliers
	e1 = real(iq_raw_1_);
	e1_ = abs(e1 - mean(e1));
	e1(e1_ > 3*median(e1_)) = []; % remove possible outerliers

	x_0 = min(e0);
    x_1 = max(e0);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
	[~, idx] = max(smooth(histcounts(e0,binEdges)/num_samples,3));
	c0r = binEdges(idx)+binSize/2;
	
	x_0 = min(e1);
    x_1 = max(e1);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
	[~, idx] = max(smooth(histcounts(e1,binEdges)/num_samples,3));
	c1r = binEdges(idx)+binSize/2;
    %%
	e0 = imag(iq_raw_0_);
	e0_ = abs(e0 - mean(e0));
	e0(e0_ > 3*median(e0_)) = []; % remove possible outerliers
	e1 = imag(iq_raw_1_);
	e1_ = abs(e1 - mean(e1));
	e1(e1_ > 3*median(e1_)) = []; % remove possible outerliers

	x_0 = min(e0);
    x_1 = max(e0);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
	[~, idx] = max(smooth(histcounts(e0,binEdges)/num_samples,3));
	c0i = binEdges(idx)+binSize/2;
	
	x_0 = min(e1);
    x_1 = max(e1);
    binSize = abs(x_0 - x_1)/nBins;
    binEdges = x_0-binSize/2:binSize:x_1+binSize/2;
	[~, idx] = max(smooth(histcounts(e1,binEdges)/num_samples,3));
	c1i = binEdges(idx)+binSize/2;
    
    %%
    center0 = (c0r+1j*c0i)*exp(1j*ang);
    center1 = (c1r+1j*c1i)*exp(1j*ang);
    
end