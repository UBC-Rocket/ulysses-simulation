function best = run_ga_param(nGen, nPop)
% run_ga_param  Tune the 12 PID gains on the parametric test-bed root_param
% with the Global Optimization Toolbox GA. Cost = altitude tracking error +
% attitude tilt + lateral drift over a 15 s flight (lower is better).
%
%   run_ga_param           % quick demo (pop 12, 3 gens)
%   run_ga_param(20, 30)   % longer run
%
% The starting point is the hand-tuned stable gain set found on this bed.
if nargin<1, nGen=3; end
if nargin<2, nPop=12; end
here=fileparts(mfilename('fullpath')); cd(here);
addpath(genpath('C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\ulysses-simulation-GA-Claude-Backup4'));
addpath('C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\v1.5_simscape_0510_simplified');
bdclose('all'); configure_body(); load_system('root_param_gimbal');

s3=load(fullfile(here,'GA_stage3_result.mat')); x=s3.xs3_15;   % local copy in this folder
sc=0.3; kdm=150;
% seed = [T(3) X(3) Y(3) Z(3)] stable gains
g0=[x(1)*3 x(2)*6 x(3)*25, ...
    x(4)*sc x(5)*sc x(6)*sc*kdm, ...
    x(7)*sc x(8)*sc x(9)*sc*kdm, ...
    x(10)*sc x(11)*sc x(12)*sc];
lb=g0*0.2; ub=g0*5;

opts=optimoptions('ga','PopulationSize',nPop,'MaxGenerations',nGen, ...
    'InitialPopulationMatrix',g0,'Display','iter','UseParallel',false);
best=ga(@cost,12,[],[],[],[],lb,ub,[],opts);
fprintf('best gains = %s\n', mat2str(best,4));
save('ga_param_result.mat','best');

    function J=cost(g)
        mk=@(a,b,c) struct('C',struct('Kp',a,'Ki',b,'Kd',c));
        T=mk(g(1),g(2),g(3)); X=mk(g(4),g(5),g(6)); Y=mk(g(7),g(8),g(9)); Z=mk(g(10),g(11),g(12));
        in=Simulink.SimulationInput('root_param_gimbal');
        in=in.setVariable('Z',Z).setVariable('Y',Y).setVariable('X',X).setVariable('T',T).setModelParameter('StopTime','15');
        try
            so=sim(in); lg=so.logsout;
            zp=squeeze(double(lg{1}.Values.Data)); zp=zp(:);
            xp=squeeze(double(lg{2}.Values.Data)); xp=xp(:); yp=squeeze(double(lg{3}.Values.Data)); yp=yp(:);
            qa=squeeze(double(lg{5}.Values.Data)); if size(qa,1)~=4,qa=qa.';end
            tilt=acosd(max(-1,min(1,1-2*(qa(2,:).^2+qa(3,:).^2))));
            drift=sqrt((xp-xp(1)).^2+(yp-yp(1)).^2);
            J = mean(abs(zp-10)) + 0.2*mean(tilt) + 0.05*drift(end);
            if any(~isfinite(zp)), J=1e6; end
        catch
            J=1e6;
        end
    end
end
