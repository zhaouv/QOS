function g = Z(qubit)
	% Z
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	import sqc.op.physical.gate.*
	switch qubit.g_Z_typ
		case 'z' % implement by using z line
			g = Z_z(qubit);
		case 'xy' % implement by using X Y gates
			g = Y(qubit)*X(qubit);
		otherwise
			error('unrecognized Z gate type: %s, available z gate options are: xy and z',...
				qubit.g_Z_typ);
	
	end
end
