classdef Plant < matlab.System
    % Linearizes dynamics, outputs as bus object for Adaptive MPC
    properties

    end

    methods(Access = protected)
        function dt = getOutputDataTypeImpl(~)
                dt = 'Bus: StateSpaceBus';
            end
        
        function sz = getOutputSizeImpl(~)
            sz = [1 1];   % buses are scalar signals
        end
    
        function cplx = isOutputComplexImpl(~)
            cplx = false;
        end
    
        function fixed = isOutputFixedSizeImpl(~)
            fixed = true;
        end
        function sys = stepImpl(obj, p, v, q, w, T, u_k)

            [A, B, C, D, DX] = computePlantMats(v, q, w, T, u_k);
       
            % Discretize at the end
            sys.A = A;
            sys.B = B;
            sys.C = C;
            sys.D = D;
            sys.U = u_k;
            sys.Y = [p; v; q; w; T]; % (!!!) y_k, output of detectors vector
            sys.X = [p; v; q; w; T]; % x_k, state vector
            sys.DX = DX; % (!!!) derivative of non linear dynamics f'(x_k, u_k)
        end
    end
end

