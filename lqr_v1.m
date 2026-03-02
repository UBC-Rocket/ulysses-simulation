% MATLAB Script for Implementing LQR Controller 
% Scope: Linearizing Plant Only 


warning('off','all');


% Simulink File
modelFile = 'Copy_of_root';

% Check if model is open
if ~bdIsLoaded(modelFile)
    load_system(modelFile);
end


%spec = operspec(modelFile); % create operation point specs 

%op = findop(modelFile, spec); % determine operation point

% Define I/Os of plant

io(1) = linio('Copy_of_root/In1', 1, 'input');
io(2) = linio('Copy_of_root/In2', 1, 'input');
io(3) = linio('Copy_of_root/In3', 1, 'input');
io(4) = linio('Copy_of_root/In4', 1, 'input');
%io(5) = linio('Copy_of_root/Multibody Sim', 1, 'output'); %q
%io(6) = linio('Copy_of_root/Multibody Sim', 2, 'output'); %omega
%io(7) = linio('Copy_of_root/Multibody Sim', 3, 'output'); %pos
%io(8) = linio('Copy_of_root/Multibody Sim', 4, 'output'); %mass
%io(7) = linio('Copy_of_root/Multibody Sim', 5, 'output'); %inertia matrix
io(5) = linio('Copy_of_root/Multibody Sim', 6, 'output'); %l_gim


%sys = linearize(modelFile, io, op); % state space system

sys = linearize(modelFile, io); % Not using an op

G = tf(sys); % Transfer Function




n = size(sys.A, 1);   % number of states
m = size(sys.B, 2);   % number of inputs

Q = diag(ones(n,1)); 
R = 0.1*eye(m); 
H = [sys.A -sys.B*(R\sys.B')
    -Q -sys.A']; % Hamiltonian matrix assuming that N = 0
[K, S, E] = lqr(sys, Q, R);

disp(K);


