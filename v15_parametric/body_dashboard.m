function body_dashboard()
% body_dashboard  Simple slider dashboard for the rigid-body DYNAMICS of the
% parametric test-bed. Drag the sliders to set total mass, CoM offset, the three
% inertias and the gimbal arm, then press "Run & Plot" to simulate root_param
% with those dynamics. (Simscape inertia is compile-time, so each run recompiles.)
here=fileparts(mfilename('fullpath')); cd(here);
addpath(genpath(here));   % put this project + its _tools subfolder on the path
addpath(genpath('C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\ulysses-simulation-GA-Claude-Backup4'));
addpath('C:\Users\18203\Desktop\UBC\Rocket\0603_simplified_model\v1.5_simscape_0510_simplified');

B = configure_body();   % defaults
specs = { ...
  'M  total mass [kg]',        0.05, 5,    B.M;
  'cx CoM offset X [m]',      -0.05, 0.05, B.cx;
  'cy CoM offset Y [m]',      -0.05, 0.05, B.cy;
  'cz CoM offset Z [m]',      -0.05, 0.05, B.cz;
  'Ixx [kg*m^2]',             1e-4,  1e-2, B.Ixx;
  'Iyy [kg*m^2]',             1e-4,  1e-2, B.Iyy;
  'Izz [kg*m^2]',             1e-4,  1e-2, B.Izz;
  'Larm gimbal arm [m]',      0.02,  0.30, B.L };
keys = {'M','cx','cy','cz','Ixx','Iyy','Izz','Larm'};

f = uifigure('Name','V1.5 parametric body dashboard','Position',[100 100 460 430]);
sld = gobjects(numel(keys),1); val = gobjects(numel(keys),1);
for i=1:numel(keys)
    y = 400 - i*42;
    uilabel(f,'Position',[15 y 150 22],'Text',specs{i,1});
    sld(i)=uislider(f,'Position',[175 y+10 200 3],'Limits',[specs{i,2} specs{i,3}],'Value',specs{i,4});
    val(i)=uieditfield(f,'numeric','Position',[385 y 60 22],'Value',specs{i,4});
    sld(i).ValueChangedFcn = @(s,e) set(val(i),'Value',s.Value);
    val(i).ValueChangedFcn = @(s,e) set(sld(i),'Value',s.Value);
end
uibutton(f,'Position',[120 20 120 28],'Text','Run & Plot', ...
    'ButtonPushedFcn',@(btn,ev) runit());
uibutton(f,'Position',[250 20 150 28],'Text','Save as default', ...
    'ButtonPushedFcn',@(btn,ev) saveit());

    function runit()
        % Nested function (shares the slider handles) -> static workspace, so it
        % CANNOT run the smiData script itself. Push the slider values to the base
        % workspace and delegate the run to the local (non-nested) do_run below.
        for k=1:numel(keys), assignin('base',keys{k}, val(k).Value); end
        do_run();
    end

    function saveit()
        % Write the current slider values into configure_body.m so run_param and
        % the dashboard pick them up as the new defaults (the single source of truth).
        vals = zeros(numel(keys),1);
        for k=1:numel(keys), vals(k)=val(k).Value; end
        msg = save_defaults(keys, vals);
        uialert(f, msg, 'Saved as default', 'Icon','success');
    end
end

function do_run()
% Local (non-nested) function -> normal workspace, so the
% SimulationFULLAssembly_DataFile script can create smiData here (this is why the
% nested runit cannot call it directly). Body params come from the base
% workspace, which runit set from the sliders.
s3=load(fullfile(fileparts(mfilename('fullpath')),'GA_stage3_result.mat')); x=s3.xs3_15; bdclose('all');   % local copy in this folder
SimulationFULLAssembly_DataFile; PID_reset;
mk=@(a,b,c) struct('C',struct('Kp',a,'Ki',b,'Kd',c));
sc=0.3; kdm=150;
T=mk(x(1),x(2),x(3)); X=mk(x(4)*sc,x(5)*sc,x(6)*sc*kdm);
Y=mk(x(7)*sc,x(8)*sc,x(9)*sc*kdm); Z=mk(x(10)*sc,x(11)*sc,x(12)*sc);
in=Simulink.SimulationInput('root_param_gimbal');
in=in.setVariable('Z',Z).setVariable('Y',Y).setVariable('X',X).setVariable('T',T).setModelParameter('StopTime','15');
so=sim(in); lg=so.logsout;
tz=lg{1}.Values.Time; zp=squeeze(double(lg{1}.Values.Data)); zp=zp(:);
qa=squeeze(double(lg{5}.Values.Data)); if size(qa,1)~=4,qa=qa.';end; tq=lg{5}.Values.Time;
tilt=acosd(max(-1,min(1,1-2*(qa(2,:).^2+qa(3,:).^2))));
figure('Color','w','Name','Result');
subplot(2,1,1); plot(tz,zp,'b','LineWidth',1.4); yline(10,'k--'); grid on; ylabel('z (m)'); title('Altitude');
subplot(2,1,2); plot(tq,tilt,'r','LineWidth',1.4); grid on; ylabel('tilt (deg)'); xlabel('s'); title('Attitude tilt');
end

function msg = save_defaults(keys, vals)
% Rewrite the BODY.* numeric values in configure_body.m with the given values.
% Slider key 'Larm' maps to the field BODY.L; all others map 1:1.
here = fileparts(mfilename('fullpath'));
fn   = fullfile(here,'configure_body.m');
txt  = fileread(fn);
field = containers.Map({'M','cx','cy','cz','Ixx','Iyy','Izz','Larm'}, ...
                       {'M','cx','cy','cz','Ixx','Iyy','Izz','L'});
for i=1:numel(keys)
    pat = ['(BODY\.' field(keys{i}) '\s*=\s*)[^;]*(;)'];
    txt = regexprep(txt, pat, ['$1' num2str(vals(i),'%.6g') '$2'], 'once');
end
fid = fopen(fn,'w'); fwrite(fid, txt); fclose(fid);
msg = sprintf('Saved %d body params to configure_body.m.\nrun_param and the dashboard will now use these as defaults.', numel(keys));
end
