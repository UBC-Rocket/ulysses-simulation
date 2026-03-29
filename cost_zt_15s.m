function J = cost_zt_15s(x, model)
% cost_zt — GA cost function for 12-parameter joint PID optimization
%
% x = [KpT KiT KdT  KpX KiX KdX  KpY KiY KdY  KpZ KiZ KdZ]
%
% Variable mapping (counterintuitive naming in Simulink model):
%   T.C.* -> controls altitude (Thrust Control subsystem)
%   X.C.* -> controls attitude X-axis torque (Torque PD subsystem)
%   Y.C.* -> controls attitude Y-axis torque (Torque PD subsystem)
%   Z.C.* -> controls attitude Z-axis torque (Torque PD subsystem)

    BIG = 1e10;
    J = BIG;

    try
        T.C.Kp = x(1);  T.C.Ki = x(2);  T.C.Kd = x(3);
        X.C.Kp = x(4);  X.C.Ki = x(5);  X.C.Kd = x(6);
        Y.C.Kp = x(7);  Y.C.Ki = x(8);  Y.C.Kd = x(9);
        Z.C.Kp = x(10); Z.C.Ki = x(11); Z.C.Kd = x(12);

        simIn = Simulink.SimulationInput(model);
        simIn = simIn.setVariable('Z', Z);
        simIn = simIn.setVariable('Y', Y);
        simIn = simIn.setVariable('X', X);
        simIn = simIn.setVariable('T', T);
        simIn = simIn.setModelParameter('StopTime', '15');

        simOut = sim(simIn);
        logs   = simOut.logsout;

        z_pos = logs{1}.Values;
        z_des = logs{4}.Values;
        w     = logs{5}.Values;
        q     = logs{6}.Values;
        q_des = logs{7}.Values;

        tz = z_pos.Time(:);
        zp = double(z_pos.Data(:));
        zd_raw = double(z_des.Data);
        if isscalar(zd_raw)
            zd = repmat(zd_raw, length(zp), 1);
        else
            zd = zd_raw(:);
            N1 = min([length(tz), length(zp), length(zd)]);
            tz = tz(1:N1); zp = zp(1:N1); zd = zd(1:N1);
        end

        tw = w.Time(:);
        wa = double(w.Data);
        if ~isvector(wa)
            if size(wa,1) ~= length(tw), wa = wa.'; end
            wmag = sqrt(sum(wa.^2, 2));
            wz   = abs(wa(:,3));
        else
            wmag = abs(wa(:));
            wz   = wmag;
        end
        Nw = min(length(tw), length(wmag));
        tw = tw(1:Nw); wmag = wmag(1:Nw); wz = wz(1:Nw);

        tq = q.Time(:);
        qa = double(q.Data);
        if size(qa,2) ~= 4 && size(qa,1) == 4, qa = qa.'; end
        qd_raw = double(q_des.Data);
        if isvector(qd_raw) && numel(qd_raw) == 4
            qd = repmat(reshape(qd_raw, 1, 4), size(qa,1), 1);
        else
            qd = qd_raw;
            if size(qd,2) ~= 4 && size(qd,1) == 4, qd = qd.'; end
        end
        N2 = min([length(tq), size(qa,1), size(qd,1)]);
        tq = tq(1:N2); qa = qa(1:N2,:); qd = qd(1:N2,:);
        qa_norm = vecnorm(qa,2,2); qd_norm = vecnorm(qd,2,2);
        if any(qa_norm==0) || any(qd_norm==0), J = BIG; return; end
        qa = qa ./ qa_norm; qd = qd ./ qd_norm;
        dotq   = max(min(sum(qd .* qa, 2), 1), -1);
        eq_att = 1 - abs(dotq);

        Z_REF = 10;   % target altitude (m)
        W_REF = 15;   % angular velocity reference (rad/s)

        ez  = (zd - zp) / Z_REF;
        ew  = wmag / W_REF;
        ewz = wz / W_REF;

        if any(isnan(ez)|isinf(ez)) || any(isnan(ew)|isinf(ew)) || ...
           any(isnan(eq_att)|isinf(eq_att))
            J = BIG; return;
        end

        Jz  = trapz(tz, tz .* abs(ez));
        Jw  = trapz(tw, tw .* ew.^2);
        Jwz = trapz(tw, tw .* ewz.^2);
        Jq  = trapz(tq, tq .* eq_att);

        J_final = 20 * abs(zd(end) - zp(end)) / Z_REF;

        penalty = 0;
        if max(abs(zp)) > 100, penalty = penalty + 1e6; end
        if min(zp)      < -40, penalty = penalty + 1e6; end
        if max(wmag)    > 150, penalty = penalty + 1e6; end
        if mean(eq_att) > 0.6, penalty = penalty + 1e6; end

        J = 1.0*Jz + 5.0*Jq + 3.0*Jw + 2.0*Jwz + J_final + penalty;

        if isnan(J) || isinf(J), J = BIG; end

    catch ME
        fprintf('\nERROR: %s\n', ME.message);
        J = BIG;
    end
end
