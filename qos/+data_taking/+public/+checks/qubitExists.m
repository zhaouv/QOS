function qubitExists(args,fields)
    % check the existance of qubit by name
    
    % Yulin Wu, 2017/1/4
    
    qubits = sqc.util.loadQubits();
    num_fields = numel(fields);
    for ii = 1:num_fields
        if ~isfield(args,fields{ii}) || ~util.ismember(args.bias_qubit,qubits)
            ME = MException('inValidInput',sprintf('%s is not specified or not one of the selected qubits.',fields{ii}));
            ME.throwAsCaller();
        end
    end
end