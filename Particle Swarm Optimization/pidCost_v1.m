function cost = pidCost_v1(gains, stopTime)
    simIn = Simulink.SimulationInput('root.slx');
    simIn = simIn.setModelParameter('StopTime', num2str(stopTime));

    % Set gains for X axis PID controller
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID X', 'P', num2str(gains(1)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID X', 'I', num2str(gains(2)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID X', 'D', num2str(gains(3)));

    % Set gains for Y axis PID controller
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Y', 'P', num2str(gains(4)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Y', 'I', num2str(gains(5)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Y', 'D', num2str(gains(6)));

    % Set gains for Z axis PID controller
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Z', 'P', num2str(gains(7)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Z', 'I', num2str(gains(8)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Z', 'D', num2str(gains(9)));

    % Set gains for Z Position axis PID controller
    simIn = setBlockParameter(simIn, 'thrust_control/PID Thrust', 'P', num2str(gains(10)));
    simIn = setBlockParameter(simIn, 'thrust_control/PID Thrust', 'I', num2str(gains(11)));
    simIn = setBlockParameter(simIn, 'thrust_control/PID Thrust', 'D', num2str(gains(12)));

    % Run simulation
    try
        simOut = sim(simIn);
    catch
        cost = 1e6;
        return;
    end

    % Extract signals (via named outports)
    err_X = simOut.yout.signals(1).values;
    err_Y = simOut.yout.signals(2).values;
    err_Z = simOut.yout.signals(3).values;
    err_Z_pos = simOut.yout.signals(4).values;


    t   = simOut.yout.time;

    % Compute the ISE for each of the error values 
    ise_X = trapz(t, err_X.^2);
    ise_Y = trapz(t, err_Y.^2);
    ise_Z = trapz(t, err_Z.^2);
    ise_Z_pos = trapz(t, err_Z_pos.^2);
    
    ise_cost = ise_X + ise_Y + ise_Z + ise_Z_pos;
    cost = ise_cost;

end
