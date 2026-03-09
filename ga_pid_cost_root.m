function J = ga_pid_cost_root(x, model)

    BIG = 1e10;
    J = BIG;

    try
        % x = [KpZ KiZ KdZ  KpY KiY KdY  KpX KiX KdX  KpT KiT KdT]

        Z.C.Kp = x(1);   Z.C.Ki = x(2);   Z.C.Kd = x(3);
        Y.C.Kp = x(4);   Y.C.Ki = x(5);   Y.C.Kd = x(6);
        X.C.Kp = x(7);   X.C.Ki = x(8);   X.C.Kd = x(9);
        T.C.Kp = x(10);  T.C.Ki = x(11);  T.C.Kd = x(12);

        simIn = Simulink.SimulationInput(model);
        simIn = simIn.setVariable('Z', Z);
        simIn = simIn.setVariable('Y', Y);
        simIn = simIn.setVariable('X', X);
        simIn = simIn.setVariable('T', T);
        simIn = simIn.setModelParameter('StopTime', '10');

                simOut = sim(simIn);
        logs = simOut.logsout;

        % New model logging order
        z_pos_sig = logs{1};   % Z_pos
        z_des_sig = logs{2};   % root/From15
        q_sig     = logs{3};   % root/Multibody Sim
        q_des_sig = logs{4};   % root/Rotation Angles to Quaternions

        z_pos = z_pos_sig.Values;
        q     = q_sig.Values;
        q_des = q_des_sig.Values;
        z_des = z_des_sig.Values;

        %% -------- z cost --------
        tz = z_pos.Time(:);
        zp = z_pos.Data(:);

        % z_des may be a scalar constant
        zd_raw = z_des.Data;
        if isscalar(zd_raw)
            zd = repmat(double(zd_raw), length(zp), 1);
        else
            zd = zd_raw(:);
            N1 = min([length(tz), length(zp), length(zd)]);
            tz = tz(1:N1);
            zp = zp(1:N1);
            zd = zd(1:N1);
        end

        ez = zd - zp;
        zScale = max(1, max(abs(zd)));
        ez_n = ez / zScale;

        Jz = trapz(tz, tz .* abs(ez_n));

        %% -------- quaternion cost --------
        tq = q.Time(:);
        qa = double(q.Data);   % expected Nx4

        if size(qa,2) ~= 4 && size(qa,1) == 4
            qa = qa.';
        end

        qd_raw = double(q_des.Data);

        % q_des may be a single constant quaternion 1x4
        if isvector(qd_raw) && numel(qd_raw) == 4
            qd = repmat(reshape(qd_raw,1,4), size(qa,1), 1);
        else
            qd = qd_raw;
            if size(qd,2) ~= 4 && size(qd,1) == 4
                qd = qd.';
            end
        end

        N2 = min([length(tq), size(qa,1), size(qd,1)]);
        tq = tq(1:N2);
        qa = qa(1:N2,:);
        qd = qd(1:N2,:);

        qa_norm = vecnorm(qa, 2, 2);
        qd_norm = vecnorm(qd, 2, 2);

        if any(qa_norm == 0) || any(qd_norm == 0)
            J = BIG;
            return;
        end

        qa = qa ./ qa_norm;
        qd = qd ./ qd_norm;

        dotq = sum(qd .* qa, 2);
        dotq = max(min(dotq,1),-1);

        eq_att = 1 - abs(dotq);

        Jq = trapz(tq, tq .* abs(eq_att));

        %% -------- penalty --------
        penalty = 0;

        if max(abs(zp)) > 100
            penalty = penalty + 1e6;
        end

        if any(isnan(ez_n)) || any(isinf(ez_n)) || any(isnan(eq_att)) || any(isinf(eq_att))
            J = BIG;
            return;
        end

        %% Final cost
        J = 1.0 * Jz + 5.0 * Jq + penalty;

        if isnan(J) || isinf(J)
            J = BIG;
        end

    catch
        J = BIG;
    end
end