function cost = pidCost_v1(gains, stopTime)
    mdl = "root";                     % model name without .slx
    % Load model into memory (does not open editor)
    load_system(mdl);

    % Temporarily clear callbacks that might open Model Explorer
    cbNames = ["OpenFcn","InitFcn","StartFcn"];
    origCb = cell(size(cbNames));
    for k = 1:numel(cbNames)
        origCb{k} = get_param(mdl, cbNames(k));
        if ~isempty(origCb{k})
            set_param(mdl, cbNames(k), ""); 
        end
    end

    % Build SimulationInput
    simIn = Simulink.SimulationInput(mdl);
    simIn = simIn.setModelParameter('StopTime', num2str(stopTime));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID X', 'P', num2str(gains(1)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID X', 'I', num2str(gains(2)));
    simIn = setBlockParameter(simIn, 'torque_control/Torque PD/PID X', 'D', num2str(gains(3)));
    % ... (other setBlockParameter calls unchanged) ...
    simIn = setBlockParameter(simIn, 'thrust_control/PID Thrust', 'D', num2str(gains(12)));

    % Run simulation (model stays closed)
    try
        simOut = sim(simIn);
    catch
        cost = 1e6;
        % restore callbacks and close model if desired
        for k = 1:numel(cbNames)
            set_param(mdl, cbNames(k), origCb{k});
        end
        close_system(mdl, 0); % 0 = do not save
        return;
    end

    % Restore callbacks and close model
    for k = 1:numel(cbNames)
        set_param(mdl, cbNames(k), origCb{k});
    end
    close_system(mdl, 0);

    % Extract signals and compute cost (unchanged)
    err_X = simOut.yout.signals(1).values;
    err_Y = simOut.yout.signals(2).values;
    err_Z = simOut.yout.signals(3).values;
    err_Z_pos = simOut.yout.signals(4).values;
    t = simOut.yout.time;
    ise_cost = trapz(t, err_X.^2) + trapz(t, err_Y.^2) + trapz(t, err_Z.^2) + trapz(t, err_Z_pos.^2);
    cost = ise_cost;
end
