function delta = QRDetunning(anharmonicity,g,disperisveShift)
    % qubit readout resonator detunning in dispersive readout
    delta = roots([1,anharmonicity,anharmonicity*g^2/disperisveShift]);
end