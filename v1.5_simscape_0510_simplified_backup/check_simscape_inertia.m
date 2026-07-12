function check_simscape_inertia(datafile)
% check_simscape_inertia  Compute total mass, CoM, and MoI from any
%                         Simscape Multibody exported data file.
% Usage: check_simscape_inertia('V1_5GimbalAssembly_DataFile_v3.m')

    % Load smiData from the specified file
    run(datafile);

    % Get number of Solid entries
    n = length(smiData.Solid);
    fprintf('Found %d Solid entries in %s\n\n', n, datafile);

    masses = zeros(1, n);
    coms   = zeros(n, 3);
    mois   = zeros(n, 3);

    for i = 1:n
        m   = smiData.Solid(i).mass;
        com = smiData.Solid(i).CoM;
        moi = smiData.Solid(i).MoI;

        % Auto-detect SI vs mm units based on CoM magnitude
        % If all CoM values are < 1, likely in metres — convert to mm
        if all(abs(com) < 1) && any(abs(com) > 1e-6)
            com = com * 1000;       % m  -> mm
            moi = moi * 1e6;        % kg*m^2 -> kg*mm^2
        end

        masses(i)  = m;
        coms(i,:)  = com;
        mois(i,:)  = moi;
    end

    % Total mass
    m_total = sum(masses);
    fprintf('Total Mass : %.6f kg\n', m_total);

    % Weighted CoM
    if m_total > 0
        com_total = sum(masses' .* coms, 1) / m_total;
    else
        com_total = [0 0 0];
    end
    fprintf('Approx CoM : [%.3f, %.3f, %.3f] mm\n', com_total);

    % MoI via parallel axis theorem
    Ixx = 0; Iyy = 0; Izz = 0;
    for i = 1:n
        dx = coms(i,1) - com_total(1);
        dy = coms(i,2) - com_total(2);
        dz = coms(i,3) - com_total(3);
        Ixx = Ixx + mois(i,1) + masses(i)*(dy^2 + dz^2);
        Iyy = Iyy + mois(i,2) + masses(i)*(dx^2 + dz^2);
        Izz = Izz + mois(i,3) + masses(i)*(dx^2 + dy^2);
    end
    fprintf('Approx MoI : Ixx=%.4f  Iyy=%.4f  Izz=%.4f  kg*mm^2\n', Ixx, Iyy, Izz);
    fprintf('Approx MoI : Ixx=%.8f  Iyy=%.8f  Izz=%.8f  kg*m^2\n',  Ixx/1e6, Iyy/1e6, Izz/1e6);

    % Per-part summary
    fprintf('\n--- Per-part Mass Summary ---\n');
    for i = 1:n
        fprintf('Solid(%2d) %-50s mass = %.2e kg\n', i, smiData.Solid(i).ID, masses(i));
    end
end