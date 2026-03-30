function cost = pidCost_v1(gains, modelName, stopTime)
    simIn = Simulink.SimulationInput(modelName);
    simIn = simIn.setModelParameter('StopTime', num2str(stopTime));
    
    
    % PID X
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID X', 'P', num2str(gains(1)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID X', 'I', num2str(gains(2)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID X', 'D', num2str(gains(3)));
    
    % PID Y
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Y', 'P', num2str(gains(4)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Y', 'I', num2str(gains(5)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Y', 'D', num2str(gains(6)));
    
    % PID Z
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Z', 'P', num2str(gains(7)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Z', 'I', num2str(gains(8)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID Z', 'D', num2str(gains(9)));
    
    % PID T
    simIn = setBlockParameter(simIn, 'thrust_control/PID Thrust', 'P', num2str(gains(10)));
    simIn = setBlockParameter(simIn, 'thrust_control/PID Thrust', 'I', num2str(gains(11)));
    simIn = setBlockParameter(simIn, 'thrust_control/PID Thrust', 'D', num2str(gains(12)));
    
    % Enable Fast Restart outside loop for repeated runs
    simOut = sim(simIn);
    
    % Error signals
    err_X   = simOut.get('torque_control/Torque PD/Demux1').Values.Data;    
    err_Y  = simOut.get('torque_control/Torque PD/Demux1/Y_err').Values.Data;
    err_Z    = simOut.get('torque_control/Torque PD/Demux1/Z_err').Values.Data;
    err_Z_pos = simOut.get('thrust_control/Sum/Z_pos_err').Values.Data;
    
    u_total = simOut.get('control_effort_vector').Values.Data;  % Or sum individual efforts
    
    ise = trapz(err_X.^2) + trapz(err_Y.^2) + trapz(err_Z.^2) + 5*trapz(err_Z_pos.^2);  % Higher weight on height if critical
    effort_penalty = 0.01 * trapz(sum(abs(u_total).^2, 2));      % Total control effort
    saturation_penalty = 500 * sum(any(abs(u_total) > your_sat_limits, 1));  % Heavy penalty for vectoring/prop saturation
    
    cost = ise + effort_penalty + saturation_penalty;
end