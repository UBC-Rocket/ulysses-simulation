% stage1_verify.m - auto-written
cd('C:\Users\18203\Desktop\UBC\Rocket\ulysses-simulation-GA-Claude');
SimulationFULLAssembly_DataFile;
PID_reset;
model = 'root';
results = struct();
idx = 0;
kp_vals = [0.01, 0.1, 0.3, 0.6, 1.0];
for k = 1:length(kp_vals)
  Z.C.Kp = kp_vals(k);
  simIn = Simulink.SimulationInput(model);
  simIn = simIn.setVariable('Z', Z);
  simIn = simIn.setVariable('Y', Y);
  simIn = simIn.setVariable('X', X);
  simIn = simIn.setVariable('T', T);
  simIn = simIn.setModelParameter('StopTime', '7');
  fprintf('Testing Z.C.Kp=%0.3f ... ', kp_vals(k));
  try
    tic; simOut = sim(simIn); elapsed = toc;
    logs = simOut.logsout;
    z_pos = double(logs{1}.Values.Data(:));
    t = logs{1}.Values.Time(:);
    w = double(logs{5}.Values.Data);
    q = double(logs{6}.Values.Data);
    q_des = double(logs{7}.Values.Data);
    if size(w,1)~=length(t), w=w'; end
    wmag = sqrt(sum(w.^2,2));
    if isvector(q_des)&&numel(q_des)==4, qd=repmat(reshape(q_des,1,4),size(q,1),1); else, qd=q_des; end
    dotq = max(min(sum(qd.*q,2),1),-1);
    att = 1-abs(dotq);
    n = length(t);
    idx=idx+1;
    results(idx).kpZ=kp_vals(k);
    results(idx).z_final=z_pos(end);
    results(idx).z_t3=z_pos(round(n/7*3));
    results(idx).z_t5=z_pos(round(n/7*5));
    results(idx).wmag_end=wmag(end);
    results(idx).wmag_max=max(wmag);
    results(idx).att_end=att(end);
    results(idx).att_t5=att(round(n/7*5));
    results(idx).elapsed=elapsed;
    fprintf('z_final=%0.2f  wmag_end=%0.2f  att_end=%0.4f\n',z_pos(end),wmag(end),att(end));
  catch ME
    idx=idx+1; results(idx).kpZ=kp_vals(k); results(idx).z_final=NaN; results(idx).error=ME.message;
    fprintf('FAILED: %s\n',ME.message);
  end
end
save('stage1_results.mat','results');
fprintf('\n=== DONE ===\n');
fprintf('for i=1:length(results)
  if isfield(results(i),'error'), fprintf('%0.3f  ERROR\n',results(i).kpZ);
  else, fprintf('%0.3f    %0.3f    %0.3f    %0.4f   %0.4f   %0.3f\n',results(i).kpZ,results(i).z_final,results(i).wmag_end,results(i).att_end,results(i).att_t5,results(i).z_t5); end
end
