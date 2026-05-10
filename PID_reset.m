% Use when tuning starts going nowhere
% Z.C.Kp = 0.25; Z.C.Ki = 0.001; Z.C.Kd = 0.0001; 
% Y.C.Kp = 0.25; Y.C.Ki = 0.001; Y.C.Kd = 0.0001; 
% X.C.Kp = 0.25; X.C.Ki = 0.001; X.C.Kd = 0.0001; 
% T.C.Kp = 0.75; T.C.Ki = 0.001; T.C.Kd = 0.0001; 

% % Z.C.Kp = 0.01000000; Z.C.Ki = 0.00250000; Z.C.Kd = 0.00050000;
% Y.C.Kp = 0.18500000; Y.C.Ki = 0.00250000; Y.C.Kd = 0.00150000;
% X.C.Kp = 0.14488281; X.C.Ki = 0.00250000; X.C.Kd = 0.00050000;
% T.C.Kp = 0.44841450; T.C.Ki = 0.00250000; T.C.Kd = 0.00494022;

% Z.C.Kp = 0.32277594; Z.C.Ki = 0.00958926; Z.C.Kd = 0.00639317;
% Y.C.Kp = 0.27235806; Y.C.Ki = 0.01294623; Y.C.Kd = 0.00150000;
% X.C.Kp = 0.36052331; X.C.Ki = 0.01044991; X.C.Kd = 0.00050000;
% T.C.Kp = 0.10933832; T.C.Ki = 0.00250000; T.C.Kd = 0.00005000;

% % Z.C.Kp = 0.01000000; Z.C.Ki = 0.00250000; Z.C.Kd = 0.00050000;
% Y.C.Kp = 1.36915341; Y.C.Ki = 0.03697509; Y.C.Kd = 0.00150000;
% X.C.Kp = 0.20250000; X.C.Ki = 0.00635371; X.C.Kd = 0.01242208;
% T.C.Kp = 0.24073468; T.C.Ki = 0.07346020; T.C.Kd = 0.00362309;

% Z.C.Kp = 0.01000000; Z.C.Ki = 0.00250000; Z.C.Kd = 0.00050000;
% Y.C.Kp = 1.25847969; Y.C.Ki = 0.08799026; Y.C.Kd = 0.01196749;
% X.C.Kp = 1.01500000; X.C.Ki = 0.00250000; X.C.Kd = 0.00050000;
% T.C.Kp = 0.26250000; T.C.Ki = 0.08912664; T.C.Kd = 0.00156673;
% Stage2 seed — best manual (Test L): overdamped T, conservative X/Y
% Structural fixes: UD1 IC=7.5596N, thrust sat floor=5N
% TAU_COMP left at [0;0;0] — Option A causes wmag explosion
% Z.C.Kp = 0.01000000; Z.C.Ki = 0.00200000; Z.C.Kd = 0.00050000;
% Y.C.Kp = 0.65000000; Y.C.Ki = 0.02500000; Y.C.Kd = 0.00600000;
% X.C.Kp = 0.55000000; X.C.Ki = 0.01200000; X.C.Kd = 0.00400000;
% T.C.Kp = 0.12000000; T.C.Ki = 0.04000000; T.C.Kd = 0.06000000;

% Stage2 GA best — pop=10 gen=5, J=99.49 (56% improvement over baseline)
% Divergence at t=7.59s (up from t=4s baseline). z_final=3.8m (up from -30m).
% Structural fixes: UD1 IC=7.5596N, thrust sat floor=5N
Z.C.Kp = 0.00598684; Z.C.Ki = 0.00712737; Z.C.Kd = 0.00104667;
Y.C.Kp = 0.68727081; Y.C.Ki = 0.03753003; Y.C.Kd = 0.00296373;
X.C.Kp = 0.55790917; X.C.Ki = 0.03850806; X.C.Kd = 0.00918268;
T.C.Kp = 0.15213283; T.C.Ki = 0.05540811; T.C.Kd = 0.03490690;

% Stage3 GA final — 15 gens pop=20, J=16.6722 (vs Stage2=96.24, original=225.9)
% Divergence: NONE in 10s. att_mean=0.0056. z_final=9.64m. wmag_max=2.41 rad/s.
Z.C.Kp = 0.00264052; Z.C.Ki = 0.00690042; Z.C.Kd = 0.00271555;
Y.C.Kp = 0.47095420; Y.C.Ki = 0.02832272; Y.C.Kd = 0.00059523;
X.C.Kp = 0.63869669; X.C.Ki = 0.03187948; X.C.Kd = 0.00277981;
T.C.Kp = 0.24245203; T.C.Ki = 0.02191524; T.C.Kd = 0.03592343;
