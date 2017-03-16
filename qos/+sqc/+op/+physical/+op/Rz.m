function g = Rz(qubit, angle, typ)
	% Z rotaion of angle
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	import sqc.op.physical.gate.*
	import sqc.op.physical.op.*
	switch typ
		case 'z' 
			error('todo...');
		case 'xy' % implement by using X Y gates
			g = XY(qubit,pi+angle/2)*X(qubit);
		otherwise
			throw(MException('QOS_op:unrecognizedZgateType'...
				sprintf('unrecognized Z gate type: %s, available z gate options are: xy and z',typ)));
	
	end
end
