function [A, B, C, D, DX] = computePlantMats(v, q, w, T, u)
    %q_0 = [q_w, q_x, q_y, q_z], T_0 = [T_x, T_y, T_z], w same dims
    % DX is just the numerical vector value of the non-linear derivative 

            J = eye(3); % inertia matrix for the rocket (!!!)
            
            m = 1; % mass of the rocket (!!!)
            
            tau_t = 1; % time constant for delay of control inputs (!!!)
            
            r_G = [0; 0; 1]; % distance between gimbal and center of mass (!!!)
            
            n = 16; % dimension of matrices A and B
            
            % matrix R(q), rotation by quaternion q
            Rq = [1 - 2*(q(3)^2 + q(4)^2), 2*(q(2)*q(3) - q(4)*q(1)), ...
                    2*(q(2)*q(4) + q(3)*q(1));
                  2*(q(2)*q(3) + q(4)*q(1)), 1 - 2*(q(2)^2 + q(4)^2), ...
                    2*(q(3)*q(4) - q(2)*q(1));
                  2*(q(2)*q(4) - q(3)*q(1)), 2*(q(3)*q(4) + q(2)*q(1)), ...
                    1 - 2*(q(2)^2 + q(3)^2)]; 
            
            % Q(omega), matrix for rotation of any quaternion q by quaternion omega
            Qw = 0.5.*[0,    -w(1), -w(2), -w(3);
                       w(1),     0,  w(3), -w(2);
                       w(2), -w(3),     0,  w(1);
                       w(3),  w(2), -w(1),     0];
            
            
            % del\delomega (Q(omega)q)
            Q_by_w = 0.5.* [-q(2), -q(3), -q(4);
                            q(1), -q(4),  q(3);
                            q(4),  q(1), -q(2);
                           -q(3),  q(2),  q(1)] ;
            
            % partials of R(q)T/m wrt q_w, q_x, q_y, q_z
            RqT_w = 2.* [-T(2)*q(4)+T(3)*q(3); ...
                         T(1)*q(4)-T(3)*q(1); ...
                         -T(1)*q(3)+T(2)*q(1)];
            
            
            RqT_x = 2.* [T(2)*q(3)+T(3)*q(4); ...
                         T(1)*q(3)-2*T(2)*q(2)-T(3)*q(1); ...
                         T(1)*q(4)+T(2)*q(2)-2*T(3)*q(2)];
            
            RqT_y = 2.* [-2*T(1)*q(3)+T(2)*q(2)+T(3)*q(1); ...
                          T(1)*q(2)+T(3)*q(4); ...
                         -T(1)*q(1)+T(2)*q(4)-2*T(3)*q(3)];
            
            RqT_z = 2.* [-2*T(1)*q(4)-T(2)*q(1)+T(3)*q(2); ...
                          T(1)*q(1)-2*T(2)*q(4)+T(3)*q(3); ...
                          T(1)*q(1)+T(2)*q(3)];
            
            % Full derivative of R(q)T wrt q
            RqT_q = (1/m).*[RqT_w, RqT_x, RqT_y, RqT_z];
            
            function mat = cross_mat(v)
                mat = [0, -v(3), v(2);
                       v(3), 0, -v(1);
                      -v(2), v(1), 0];
            end
            
            % -J([w]_xJ + [Jw]_x)
            big_J = -1.*(J * (cross_mat(w) * J + cross_mat(J*w)));
            
            % -J[r_G]_x
            lil_J = -1.*(J * cross_mat(r_G));
            
            I_3 = eye(3);
            
            I_tau = (1 / tau_t) .* I_3;
            
            Z_3 = zeros(3,3);
            
            Z_34 = zeros(3,4);  % 3 rows, 4 cols
            Z_43 = zeros(4,3);  % 4 rows, 3 cols
            
            A = [Z_3,  I_3,    Z_34,   Z_3,   Z_3;     % 3 rows: dp/dt
                 Z_3,  Z_3,    RqT_q,  Z_3,   Rq;      % 3 rows: dv/dt
                 Z_43, Z_43,   Qw,     Q_by_w, Z_43;    % 4 rows: dq/dt
                 Z_3, Z_3,     Z_34,    big_J,  lil_J;   % 4 rows: dw/dt
                 Z_3,  Z_3,    Z_34,   Z_3,   -I_tau]; % 3 rows: dT/dt
            
            B = [Z_3;
                 Z_3;
                 Z_43;
                 Z_3;
                 I_tau];
            
            C = eye(n);
            
            D = zeros(n,3);

            % calculates derivatives for p, v, q, w, and T
            p_dot = v;
            v_dot = (1/m).*(Rq*T) + 9.81;
            q_dot = (0.5).*(Qw*q);
            w_dot = inv(J) * (cross(T, r_G) - cross(w, (J*w)));
            T_dot = (1/tau_t).*(u - T);

            DX = [p_dot; v_dot; q_dot; w_dot; T_dot];
end
