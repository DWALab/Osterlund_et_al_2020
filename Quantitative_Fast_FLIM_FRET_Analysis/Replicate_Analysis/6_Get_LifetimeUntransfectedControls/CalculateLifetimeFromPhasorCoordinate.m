function lifetime = CalculateLifetimeFromPhasorCoordinate(G,S)
%Given phasor coordinate extracted for a given decay, determine average fluorescence lifetime
%%% INFO FLIM Hyperspectral conditions
freq0 = 30.51757e6;
    harmonic = 1;
    freq = harmonic * freq0;        % virtual frequency for higher harmonics
    w = 2 * pi * freq ;
    
    
   lifetime = 1/w * (S/G); 
   
   lifetime =  lifetime * 1e9; 
end
