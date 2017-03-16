import data_taking.public.xmon.*

ramsey('qubit','q2','time',0:16*3:2*15000,'detuning',50e6,'notes','ramsey');
ramsey('qubit','q2','time',0:16*3:2*15000,'detuning',30e6,'notes','ramsey');
spin_echo('qubit','q2','time',0:16*3:2*15000,'detuning',50e6,'notes','spin_echo');
spin_echo('qubit','q2','time',0:16*3:2*15000,'detuning',30e6,'notes','spin_echo');

ramsey('qubit','q2','time',0:16*3:2*15000,'detuning',50e6,'notes','ramsey_take1/3');
ramsey('qubit','q2','time',0:16*3:2*15000,'detuning',50e6,'notes','ramsey_take2/3');
ramsey('qubit','q2','time',0:16*3:2*15000,'detuning',50e6,'notes','ramsey_take3/3');

ramsey('qubit','q2','time',0:16*3:2*15000,'detuning',30e6,'notes','ramsey_take1/3');
ramsey('qubit','q2','time',0:16*3:2*15000,'detuning',30e6,'notes','ramsey_take2/3');
ramsey('qubit','q2','time',0:16*3:2*15000,'detuning',30e6,'notes','ramsey_take3/3');

spin_echo('qubit','q2','time',0:16*3:2*15000,'detuning',50e6,'notes','spin_echo_take1/3');
spin_echo('qubit','q2','time',0:16*3:2*15000,'detuning',50e6,'notes','spin_echo_take2/3');
spin_echo('qubit','q2','time',0:16*3:2*15000,'detuning',50e6,'notes','spin_echo_take3/3');

spin_echo('qubit','q2','time',0:16*3:2*15000,'detuning',30e6,'notes','spin_echo_take1/3');
spin_echo('qubit','q2','time',0:16*3:2*15000,'detuning',30e6,'notes','spin_echo_take2/3');
spin_echo('qubit','q2','time',0:16*3:2*15000,'detuning',30e6,'notes','spin_echo_take3/3');


