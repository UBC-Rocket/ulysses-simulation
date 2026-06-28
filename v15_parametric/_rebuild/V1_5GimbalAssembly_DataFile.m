% Simscape(TM) Multibody(TM) version: 25.2

% This is a model data file derived from a Simscape Multibody Import XML file using the smimport function.
% The data in this file sets the block parameter values in an imported Simscape Multibody model.
% For more information on this file, see the smimport function help page in the Simscape Multibody documentation.
% You can modify numerical values, but avoid any other changes to this file.
% Do not add code to this file. Do not edit the physical units shown in comments.

%%%VariableName:smiData


use_custom_inertia = true;

% Masses of gimbal downstream parts (from SolidWorks)
m_LowerGear      = 0.011;   % Solid(2)  — joint 1 downstream
m_Servo2Con      = 0.032;   % Solid(4)  — joint 1 downstream
m_DigitalServo   = 0.061;   % Solid(5)  — joint 1 downstream
m_MotorStand     = 0.022;   % Solid(7)  — joint 2 downstream
m_Motor          = 0.144;   % Solid(8)  — joint 2 downstream

% FRAME BASE absorbs remaining mass
% = total_assembly - all gimbal downstream parts
m_total          = 0.643;   % kg — full assembly mass from SW
m_FrameBase      = m_total - m_LowerGear - m_Servo2Con - m_DigitalServo ...
                           - m_MotorStand - m_Motor;
% m_FrameBase = 0.643 - 0.011 - 0.032 - 0.061 - 0.022 - 0.144 = 0.373 kg

% FRAME BASE inertia — adjust MoI as design evolves
framebase_CoM = [0, 0, 61.4];              % mm — forced onto central axis
framebase_MoI = [198.71, 263.74, 194.62]; % kg*mm^2 — from SW, adjust freely
framebase_PoI = [0, 0, 0];                % kg*mm^2 — zeroed = symmetric

% Negligible mass for truly non-structural parts
negligible = 1e-9;  % kg

%============= RigidTransform =============%

%Initialize the RigidTransform structure array by filling in null values.
smiData.RigidTransform(55).translation = [0.0 0.0 0.0];
smiData.RigidTransform(55).angle = 0.0;
smiData.RigidTransform(55).axis = [0.0 0.0 0.0];
smiData.RigidTransform(55).ID = "";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(1).translation = [3.18776255200464 0.60561634148826449 0.80868937249078954];  % mm
smiData.RigidTransform(1).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(1).axis = [0.57735026918962584 0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(1).ID = "B[Lower Gear-1:-:Mid Assembly-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(2).translation = [59.38420862470533 -11.418791338639616 29.422892071814097];  % mm
smiData.RigidTransform(2).angle = 2.159968895117947;  % rad
smiData.RigidTransform(2).axis = [0.59765500694510187 0.5344314599150205 0.59765500694510221];
smiData.RigidTransform(2).ID = "F[Lower Gear-1:-:Mid Assembly-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(3).translation = [-10.249999999999995 10.000000000000005 -31.600000000000001];  % mm
smiData.RigidTransform(3).angle = 0;  % rad
smiData.RigidTransform(3).axis = [0 0 0];
smiData.RigidTransform(3).ID = "B[DS3218 Digital Servo-1:-:Lower Gear-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(4).translation = [-5.8122374479953445 0.60561634149385735 0.80868937248124606];  % mm
smiData.RigidTransform(4).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(4).axis = [-0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(4).ID = "F[DS3218 Digital Servo-1:-:Lower Gear-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(5).translation = [19.884208624705337 27.26699509899392 40.166808916372254];  % mm
smiData.RigidTransform(5).angle = 0;  % rad
smiData.RigidTransform(5).axis = [0 0 0];
smiData.RigidTransform(5).ID = "B[Mid Assembly-1:-:Proppulsion Assembly-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(6).translation = [34.756588158095219 38.214055126126723 26.23398233698726];  % mm
smiData.RigidTransform(6).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(6).axis = [0.57735026918962584 0.57735026918962573 0.57735026918962573];
smiData.RigidTransform(6).ID = "F[Mid Assembly-1:-:Proppulsion Assembly-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(7).translation = [36.723997977314767 38.214055126126745 26.233982336987232];  % mm
smiData.RigidTransform(7).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(7).axis = [0.57735026918962584 0.57735026918962584 0.57735026918962562];
smiData.RigidTransform(7).ID = "B[Proppulsion Assembly-1:-:Bearings-11]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(8).translation = [-1.7763568394002505e-14 -19.424978336205573 -1.7763568394002505e-15];  % mm
smiData.RigidTransform(8).angle = 2.0943951023931962;  % rad
smiData.RigidTransform(8).axis = [-0.57735026918962595 -0.57735026918962573 -0.57735026918962562];
smiData.RigidTransform(8).ID = "F[Proppulsion Assembly-1:-:Bearings-11]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(9).translation = [73.57395464972592 37.919633817092041 26.233982336987232];  % mm
smiData.RigidTransform(9).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(9).axis = [-0.57735026918962562 -0.57735026918962562 0.57735026918962595];
smiData.RigidTransform(9).ID = "B[Proppulsion Assembly-1:-:94361A522_Short-Thread Alloy Steel Shoulder Screw-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(10).translation = [-3.5527136788005009e-15 1.7763568394002505e-15 19.674978336205569];  % mm
smiData.RigidTransform(10).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(10).axis = [1 2.9699725020854061e-33 4.7539529667845675e-17];
smiData.RigidTransform(10).ID = "F[Proppulsion Assembly-1:-:94361A522_Short-Thread Alloy Steel Shoulder Screw-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(11).translation = [0 500 0];  % mm
smiData.RigidTransform(11).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(11).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(11).ID = "B[Avionics rods-2:-:Clamp-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(12).translation = [-3.0363719990281835e-14 -490.00000000000011 -9.3694432617234383e-15];  % mm
smiData.RigidTransform(12).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(12).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(12).ID = "F[Avionics rods-2:-:Clamp-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(13).translation = [0 500 0];  % mm
smiData.RigidTransform(13).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(13).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(13).ID = "B[Avionics rods-1:-:Clamp-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(14).translation = [6.5775011651957178e-15 -490.00000000000011 -4.4548120992394189e-15];  % mm
smiData.RigidTransform(14).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(14).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(14).ID = "F[Avionics rods-1:-:Clamp-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(15).translation = [0 56.599999999999994 41.999999999999986];  % mm
smiData.RigidTransform(15).angle = 0;  % rad
smiData.RigidTransform(15).axis = [0 0 0];
smiData.RigidTransform(15).ID = "B[1.5_FRAME BASE-1:-:Mid Assembly-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(16).translation = [-21.815791375294658 27.26699509899391 29.422892071805208];  % mm
smiData.RigidTransform(16).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(16).axis = [-0.57735026918962584 -0.57735026918962573 0.57735026918962573];
smiData.RigidTransform(16).ID = "F[1.5_FRAME BASE-1:-:Mid Assembly-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(17).translation = [23.086097838741125 8.2140551261267731 26.233982336987232];  % mm
smiData.RigidTransform(17).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(17).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(17).ID = "B[Proppulsion Assembly-1:-:1.5_FRAME BASE-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(18).translation = [-0.92657347478708019 86.599999999999952 0.30000000000002558];  % mm
smiData.RigidTransform(18).angle = 2.0943951023931962;  % rad
smiData.RigidTransform(18).axis = [-0.57735026918962562 0.57735026918962562 0.57735026918962595];
smiData.RigidTransform(18).ID = "F[Proppulsion Assembly-1:-:1.5_FRAME BASE-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(19).translation = [55.167674590759077 29.22906785468804 -55.167674590758665];  % mm
smiData.RigidTransform(19).angle = 1.3694701962642906;  % rad
smiData.RigidTransform(19).axis = [0.35448906508838396 -0.69892848470240265 0.6211573681478525];
smiData.RigidTransform(19).ID = "B[1.5_FRAME BASE-1:-:Main CF Rods-6]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(20).translation = [4.2632564145606011e-14 28 -5.5067062021407764e-14];  % mm
smiData.RigidTransform(20).angle = 2.0943951023931962;  % rad
smiData.RigidTransform(20).axis = [0.57735026918962584 -0.57735026918962618 0.57735026918962518];
smiData.RigidTransform(20).ID = "F[1.5_FRAME BASE-1:-:Main CF Rods-6]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(21).translation = [-55.167674590759241 29.22906785468804 -55.167674590758502];  % mm
smiData.RigidTransform(21).angle = 2.3341089939480542;  % rad
smiData.RigidTransform(21).axis = [0.48069925615463333 -0.24380553036909444 0.84231056534619508];
smiData.RigidTransform(21).ID = "B[1.5_FRAME BASE-1:-:Main CF Rods-7]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(22).translation = [1.5454304502782179e-13 28.000000000000028 3.5527136788005009e-14];  % mm
smiData.RigidTransform(22).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(22).axis = [0.57735026918962584 -0.57735026918962573 0.57735026918962573];
smiData.RigidTransform(22).ID = "F[1.5_FRAME BASE-1:-:Main CF Rods-7]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(23).translation = [-55.167674590759077 29.22906785468804 55.167674590758672];  % mm
smiData.RigidTransform(23).angle = 2.6893425084410976;  % rad
smiData.RigidTransform(23).axis = [0.79482078268392176 -0.40312461479719175 0.45359725347309338];
smiData.RigidTransform(23).ID = "B[1.5_FRAME BASE-1:-:Main CF Rods-8]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(24).translation = [7.1054273576010019e-15 28.000000000000007 3.1974423109204508e-14];  % mm
smiData.RigidTransform(24).angle = 2.0943951023931966;  % rad
smiData.RigidTransform(24).axis = [0.57735026918962606 -0.57735026918962562 0.57735026918962562];
smiData.RigidTransform(24).ID = "F[1.5_FRAME BASE-1:-:Main CF Rods-8]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(25).translation = [55.167674590758857 29.22906785468804 55.167674590758892];  % mm
smiData.RigidTransform(25).angle = 2.2258274973208696;  % rad
smiData.RigidTransform(25).axis = [0.4379779447547697 -0.86353936244606266 0.24995017386398369];
smiData.RigidTransform(25).ID = "B[1.5_FRAME BASE-1:-:Main CF Rods-9]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(26).translation = [1.2434497875801753e-14 28.000000000000007 -3.3750779948604759e-14];  % mm
smiData.RigidTransform(26).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(26).axis = [0.57735026918962584 -0.57735026918962606 0.57735026918962529];
smiData.RigidTransform(26).ID = "F[1.5_FRAME BASE-1:-:Main CF Rods-9]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(27).translation = [0 56.599999999999994 -41.999999999999993];  % mm
smiData.RigidTransform(27).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(27).axis = [1 0 0];
smiData.RigidTransform(27).ID = "B[1.5_FRAME BASE-1:-:92981A750_Alloy Steel Shoulder Screws-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(28).translation = [-4.9715358958671083e-15 5.0765075367076509e-15 0.36399999999999377];  % mm
smiData.RigidTransform(28).angle = 0;  % rad
smiData.RigidTransform(28).axis = [0 0 0];
smiData.RigidTransform(28).ID = "F[1.5_FRAME BASE-1:-:92981A750_Alloy Steel Shoulder Screws-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(29).translation = [44.657582786048799 30.000000000000007 5.9852541133013988];  % mm
smiData.RigidTransform(29).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(29).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(29).ID = "B[1.5_FRAME BASE-1:-:Clamp-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(30).translation = [-0.7400665510331772 7.1054273576010019e-15 -5.9442690388690185];  % mm
smiData.RigidTransform(30).angle = 2.1917394543787876;  % rad
smiData.RigidTransform(30).axis = [-0.51417930365366038 0.60647326556668468 0.60647326556668468];
smiData.RigidTransform(30).ID = "F[1.5_FRAME BASE-1:-:Clamp-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(31).translation = [-44.657582786048799 30.000000000000007 5.9852541133013988];  % mm
smiData.RigidTransform(31).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(31).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(31).ID = "B[1.5_FRAME BASE-1:-:Clamp-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(32).translation = [2.7200899342411193 0 -5.3369601512516258];  % mm
smiData.RigidTransform(32).angle = 1.8287592566991586;  % rad
smiData.RigidTransform(32).axis = [-0.77037914854926748 0.45084141750758983 0.45084141750758983];
smiData.RigidTransform(32).ID = "F[1.5_FRAME BASE-1:-:Clamp-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(33).translation = [0 8 0];  % mm
smiData.RigidTransform(33).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(33).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(33).ID = "B[1.5_FRAME BASE-1:-:DS3218 Digital Servo-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(34).translation = [-10.250000000000014 0.085786437626911294 -1.3999999999999915];  % mm
smiData.RigidTransform(34).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(34).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(34).ID = "F[1.5_FRAME BASE-1:-:DS3218 Digital Servo-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(35).translation = [-44.899999999999999 50 3.1225022567582528e-13];  % mm
smiData.RigidTransform(35).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(35).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(35).ID = "B[1.5_FRAME BASE-1:-:Avionics rods-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(36).translation = [-1.5419128437875368e-14 -10.000000000000011 -3.8322275359152348e-15];  % mm
smiData.RigidTransform(36).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(36).axis = [-0.57735026918962584 -0.57735026918962573 -0.57735026918962573];
smiData.RigidTransform(36).ID = "F[1.5_FRAME BASE-1:-:Avionics rods-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(37).translation = [44.899999999999999 50 -3.1225022567582528e-13];  % mm
smiData.RigidTransform(37).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(37).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(37).ID = "B[1.5_FRAME BASE-1:-:Avionics rods-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(38).translation = [-2.6636819466686498e-15 -10.000000000000007 -6.5872525700124989e-15];  % mm
smiData.RigidTransform(38).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(38).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(38).ID = "F[1.5_FRAME BASE-1:-:Avionics rods-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(39).translation = [-3.1225022567582528e-13 50 -44.899999999999999];  % mm
smiData.RigidTransform(39).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(39).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(39).ID = "B[1.5_FRAME BASE-1:-:Avionics rods-3]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(40).translation = [-3.0224831055132639e-13 -10.000000000000007 -4.5244778118991277e-14];  % mm
smiData.RigidTransform(40).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(40).axis = [-0.57735026918962584 -0.57735026918962573 -0.57735026918962573];
smiData.RigidTransform(40).ID = "F[1.5_FRAME BASE-1:-:Avionics rods-3]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(41).translation = [3.1225022567582528e-13 50 44.900000000000006];  % mm
smiData.RigidTransform(41).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(41).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(41).ID = "B[1.5_FRAME BASE-1:-:Avionics rods-4]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(42).translation = [3.1552807381926588e-13 -10.000000000000011 -2.0472183957606051e-14];  % mm
smiData.RigidTransform(42).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(42).axis = [-0.57735026918962584 -0.57735026918962573 -0.57735026918962573];
smiData.RigidTransform(42).ID = "F[1.5_FRAME BASE-1:-:Avionics rods-4]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(43).translation = [0 17.910000000000004 -41.800000000000011];  % mm
smiData.RigidTransform(43).angle = 0;  % rad
smiData.RigidTransform(43).axis = [0 0 0];
smiData.RigidTransform(43).ID = "B[1.5_FRAME BASE-1:-:Bearings-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(44).translation = [4.6426046275282772e-15 -3.5527136788005001e-15 1.920877726333822e-15];  % mm
smiData.RigidTransform(44).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(44).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(44).ID = "F[1.5_FRAME BASE-1:-:Bearings-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(45).translation = [0 56.599999999999994 -41.999999999999993];  % mm
smiData.RigidTransform(45).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(45).axis = [1 0 0];
smiData.RigidTransform(45).ID = "B[1.5_FRAME BASE-1:-:Bearings-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(46).translation = [0 0 0];  % mm
smiData.RigidTransform(46).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(46).axis = [-0.57735026918962584 -0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(46).ID = "F[1.5_FRAME BASE-1:-:Bearings-2]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(47).translation = [0 56.599999999999994 41.999999999999986];  % mm
smiData.RigidTransform(47).angle = 0;  % rad
smiData.RigidTransform(47).axis = [0 0 0];
smiData.RigidTransform(47).ID = "B[1.5_FRAME BASE-1:-:Bearings-3]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(48).translation = [-1.3994959900461028e-14 1.4210854715202004e-14 -2.4676890243843381e-15];  % mm
smiData.RigidTransform(48).angle = 2.0943951023931957;  % rad
smiData.RigidTransform(48).axis = [-0.57735026918962584 -0.57735026918962573 -0.57735026918962573];
smiData.RigidTransform(48).ID = "F[1.5_FRAME BASE-1:-:Bearings-3]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(49).translation = [0 3.0000000000000027 0];  % mm
smiData.RigidTransform(49).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(49).axis = [0.57735026918962584 -0.57735026918962584 0.57735026918962584];
smiData.RigidTransform(49).ID = "B[Bearings-3:-:92981A750_Alloy Steel Shoulder Screws-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(50).translation = [-1.0350992618183788e-14 -1.0364705400464594e-14 4.3639999999999475];  % mm
smiData.RigidTransform(50).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(50).axis = [1 -1.4653625560312698e-33 -4.4908505966702555e-17];
smiData.RigidTransform(50).ID = "F[Bearings-3:-:92981A750_Alloy Steel Shoulder Screws-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(51).translation = [9.6342086247053338 7.2669950989939158 29.359197071797368];  % mm
smiData.RigidTransform(51).angle = 0;  % rad
smiData.RigidTransform(51).axis = [0 0 0];
smiData.RigidTransform(51).ID = "AssemblyGround[Mid Assembly-1:Servo 2 Connector-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(52).translation = [9.634208624705348 37.266995098993931 35.459197071797362];  % mm
smiData.RigidTransform(52).angle = 3.1415926535897931;  % rad
smiData.RigidTransform(52).axis = [0 0 1];
smiData.RigidTransform(52).ID = "AssemblyGround[Mid Assembly-1:DS3218 Digital Servo-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(53).translation = [23.086097838741125 8.2140551261267731 26.233982336987232];  % mm
smiData.RigidTransform(53).angle = 0;  % rad
smiData.RigidTransform(53).axis = [0 0 0];
smiData.RigidTransform(53).ID = "AssemblyGround[Proppulsion Assembly-1:Motor Stand-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(54).translation = [24.016098290692248 -48.785944873873248 26.533982788938363];  % mm
smiData.RigidTransform(54).angle = 2.0943951023931953;  % rad
smiData.RigidTransform(54).axis = [0.57735026918962584 0.57735026918962584 -0.57735026918962584];
smiData.RigidTransform(54).ID = "AssemblyGround[Proppulsion Assembly-1:CRM2413-1]";

%Translation Method - Cartesian
%Rotation Method - Arbitrary Axis
smiData.RigidTransform(55).translation = [23.948419006487434 14.041890987984571 61.84564257918403];  % mm
smiData.RigidTransform(55).angle = 0;  % rad
smiData.RigidTransform(55).axis = [0 0 0];
smiData.RigidTransform(55).ID = "RootGround[1.5_FRAME BASE-1]";


%============= Solid =============%
%Center of Mass (CoM) %Moments of Inertia (MoI) %Product of Inertia (PoI)

% =========================================================================
% USER-CONFIGURABLE INERTIA PARAMETERS
% =========================================================================
% Strategy (Approach A):
%   - Gimbal joint downstream parts keep their ORIGINAL SW mass/CoM/MoI
%     so real asymmetric disturbance torques are preserved in simulation.
%   - All non-gimbal parts (rods, clamps, screws, bearings) → negligible
%   - FRAME BASE (Solid 6) absorbs the remaining mass, with CoM forced
%     onto the central axis to represent the rocket body above.
%
% Joint 1 downstream (kept real): Lower Gear, Servo 2 Connector, DS3218
% Joint 2 downstream (kept real): Motor Stand, CRM2413
%
% Units: mass [kg], CoM [mm], MoI [kg*mm^2], PoI [kg*mm^2]
%        Exception: Solid(8) CRM2413 uses SI [m, kg*m^2]
% =========================================================================


% =========================================================================

%Initialize the Solid structure array by filling in null values.
smiData.Solid(12).mass = 0.0;
smiData.Solid(12).CoM = [0.0 0.0 0.0];
smiData.Solid(12).MoI = [0.0 0.0 0.0];
smiData.Solid(12).PoI = [0.0 0.0 0.0];
smiData.Solid(12).color = [0.0 0.0 0.0];
smiData.Solid(12).opacity = 0.0;
smiData.Solid(12).ID = "";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(1): Avionics rods — structural only, negligible in custom mode
if use_custom_inertia
    smiData.Solid(1).mass = negligible;
    smiData.Solid(1).CoM = [0 250 0];
    smiData.Solid(1).MoI = [negligible negligible negligible];
    smiData.Solid(1).PoI = [0 0 0];
else
    smiData.Solid(1).mass = 0.014;  % kg
    smiData.Solid(1).CoM = [0 250 0];  % mm
    smiData.Solid(1).MoI = [291.68854166666665 0.043749999999999997 291.68854166666665];  % kg*mm^2
    smiData.Solid(1).PoI = [0 0 0];  % kg*mm^2
end
smiData.Solid(1).color = [0.25098039215686274 0.25098039215686274 0.25098039215686274];
smiData.Solid(1).opacity = 1;
smiData.Solid(1).ID = "Avionics rods*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(2): Lower Gear — JOINT 1 DOWNSTREAM, keep real mass/CoM/MoI
if use_custom_inertia
    smiData.Solid(2).mass = m_LowerGear;
    smiData.Solid(2).CoM = [-1.8087341651566633 6.2447800674855651 0.80868937249080053];  % mm
    smiData.Solid(2).MoI = [1.0000000000000001e-05 1.0000000000000001e-05 1.0000000000000001e-05];  % kg*mm^2
    smiData.Solid(2).PoI = [0 0 0];  % kg*mm^2
else
    smiData.Solid(2).mass = 0.010999999999999999;  % kg
    smiData.Solid(2).CoM = [-1.8087341651566633 6.2447800674855651 0.80868937249080053];  % mm
    smiData.Solid(2).MoI = [1.0000000000000001e-05 1.0000000000000001e-05 1.0000000000000001e-05];  % kg*mm^2
    smiData.Solid(2).PoI = [0 0 0];  % kg*mm^2
end
smiData.Solid(2).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(2).opacity = 1;
smiData.Solid(2).ID = "Lower Gear*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(3): Main CF Rods — structural only, negligible in custom mode
if use_custom_inertia
    smiData.Solid(3).mass = negligible;
    smiData.Solid(3).CoM = [0 174.99999999999997 0];
    smiData.Solid(3).MoI = [negligible negligible negligible];
    smiData.Solid(3).PoI = [0 0 0];
else
    smiData.Solid(3).mass = 0.017000000000000001;  % kg
    smiData.Solid(3).CoM = [0 174.99999999999997 0];  % mm
    smiData.Solid(3).MoI = [173.56822916666664 0.053124999999999999 173.56822916666664];  % kg*mm^2
    smiData.Solid(3).PoI = [0 0 0];  % kg*mm^2
end
smiData.Solid(3).color = [0.25098039215686274 0.25098039215686274 0.25098039215686274];
smiData.Solid(3).opacity = 1;
smiData.Solid(3).ID = "Main CF Rods*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(4): Servo 2 Connector — JOINT 1 DOWNSTREAM, keep real mass/CoM/MoI
if use_custom_inertia
    smiData.Solid(4).mass = m_Servo2Con;
    smiData.Solid(4).CoM = [16.998510147550729 12.826620926527566 3.2115730653993069];  % mm
    smiData.Solid(4).MoI = [5.6769489940894866 21.88580772429675 19.358980765607051];  % kg*mm^2
    smiData.Solid(4).PoI = [-0.13987961899162604 1.0115861282109821 -0.42518028575100258];  % kg*mm^2
else
    smiData.Solid(4).mass = 0.032000000000000001;  % kg
    smiData.Solid(4).CoM = [16.998510147550729 12.826620926527566 3.2115730653993069];  % mm
    smiData.Solid(4).MoI = [5.6769489940894866 21.88580772429675 19.358980765607051];  % kg*mm^2
    smiData.Solid(4).PoI = [-0.13987961899162604 1.0115861282109821 -0.42518028575100258];  % kg*mm^2
end
smiData.Solid(4).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(4).opacity = 1;
smiData.Solid(4).ID = "Servo 2 Connector*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(5): DS3218 Digital Servo — JOINT 1 DOWNSTREAM, keep real mass/CoM/MoI
if use_custom_inertia
    smiData.Solid(5).mass = m_DigitalServo;
    smiData.Solid(5).CoM = [-0.23681282514662572 10.038889294326538 -6.4227149523783513];  % mm
    smiData.Solid(5).MoI = [10.31728381562049 17.069946862793337 10.705205175065982];  % kg*mm^2
    smiData.Solid(5).PoI = [-0.0014253814006970008 -0.016821455567408463 -0.0009158034640359752];  % kg*mm^2
else
    smiData.Solid(5).mass = 0.060999999999999999;  % kg
    smiData.Solid(5).CoM = [-0.23681282514662572 10.038889294326538 -6.4227149523783513];  % mm
    smiData.Solid(5).MoI = [10.31728381562049 17.069946862793337 10.705205175065982];  % kg*mm^2
    smiData.Solid(5).PoI = [-0.0014253814006970008 -0.016821455567408463 -0.0009158034640359752];  % kg*mm^2
end
smiData.Solid(5).color = [0.5607843137254902 0.2627450980392157 0];
smiData.Solid(5).opacity = 1;
smiData.Solid(5).ID = "DS3218 Digital Servo*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(6): 1.5_FRAME BASE — ROOT BODY, absorbs remaining mass (rocket body above gimbal)
if use_custom_inertia
    smiData.Solid(6).mass = m_FrameBase;
    smiData.Solid(6).CoM  = framebase_CoM;
    smiData.Solid(6).MoI  = framebase_MoI;
    smiData.Solid(6).PoI  = framebase_PoI;
else
    smiData.Solid(6).mass = 0.10400000000000001;  % kg
    smiData.Solid(6).CoM = [0.60255966439140407 28.710494104055009 0.25367448135464399];  % mm
    smiData.Solid(6).MoI = [198.70953596523665 263.74486222721225 194.61682279099122];  % kg*mm^2
    smiData.Solid(6).PoI = [0.87116636222950017 0.73884502446493661 1.2582251748560798];  % kg*mm^2
end
smiData.Solid(6).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(6).opacity = 1;
smiData.Solid(6).ID = "1.5_FRAME BASE*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(7): Motor Stand — JOINT 2 DOWNSTREAM, keep real mass/CoM/MoI
if use_custom_inertia
    smiData.Solid(7).mass = m_MotorStand;
    smiData.Solid(7).CoM = [-1.2047003328432371 11.047446598546003 0.16373766863764527];  % mm
    smiData.Solid(7).MoI = [5.8261564047726573 12.930484663622515 12.678660581047694];  % kg*mm^2
    smiData.Solid(7).PoI = [0.025494871444738988 -0.010529234057520593 0.92602821136009383];  % kg*mm^2
else
    smiData.Solid(7).mass = 0.021999999999999999;  % kg
    smiData.Solid(7).CoM = [-1.2047003328432371 11.047446598546003 0.16373766863764527];  % mm
    smiData.Solid(7).MoI = [5.8261564047726573 12.930484663622515 12.678660581047694];  % kg*mm^2
    smiData.Solid(7).PoI = [0.025494871444738988 -0.010529234057520593 0.92602821136009383];  % kg*mm^2
end
smiData.Solid(7).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(7).opacity = 1;
smiData.Solid(7).ID = "Motor Stand*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(8): CRM2413 motor — JOINT 2 DOWNSTREAM, keep real mass/CoM/MoI
% NOTE: this part uses SI units (m, kg*m^2) unlike the others (mm, kg*mm^2)
if use_custom_inertia
    smiData.Solid(8).mass = m_Motor;
    smiData.Solid(8).CoM = [3.6586449077832985e-09 5.1512782891765819e-09 -0.015039747716466982];  % m
    smiData.Solid(8).MoI = [0.00019994142401576575 8.0247163847582914e-05 0.00013640476373242067];  % kg*m^2
    smiData.Solid(8).PoI = [-2.5999928676096989e-11 -1.2341884410670003e-11 -1.4846314274848877e-07];  % kg*m^2
else
    smiData.Solid(8).mass = 0.14400000000000002;  % kg
    smiData.Solid(8).CoM = [3.6586449077832985e-09 5.1512782891765819e-09 -0.015039747716466982];  % m
    smiData.Solid(8).MoI = [0.00019994142401576575 8.0247163847582914e-05 0.00013640476373242067];  % kg*m^2
    smiData.Solid(8).PoI = [-2.5999928676096989e-11 -1.2341884410670003e-11 -1.4846314274848877e-07];  % kg*m^2
end
smiData.Solid(8).color = [0.25098039215686274 0.25098039215686274 0.25098039215686274];
smiData.Solid(8).opacity = 1;
smiData.Solid(8).ID = "CRM2413*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(9): Clamp — structural only, negligible in custom mode
if use_custom_inertia
    smiData.Solid(9).mass = negligible;
    smiData.Solid(9).CoM = [-5.2342734503029609e-06 4.9811636756252424 -1.7568891097819852];
    smiData.Solid(9).MoI = [negligible negligible negligible];
    smiData.Solid(9).PoI = [0 0 0];
else
    smiData.Solid(9).mass = 0.00125;  % kg
    smiData.Solid(9).CoM = [-5.2342734503029609e-06 4.9811636756252424 -1.7568891097819852];  % mm
    smiData.Solid(9).MoI = [0.032033136305009598 0.034530921960067067 0.025855791484430873];  % kg*mm^2
    smiData.Solid(9).PoI = [3.5691202974681795e-05 -1.1778958587005334e-09 1.7402528045902124e-08];  % kg*mm^2
end
smiData.Solid(9).color = [0.792156862745098 0.81960784313725488 0.93333333333333335];
smiData.Solid(9).opacity = 1;
smiData.Solid(9).ID = "Clamp*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(10): Bearings — structural only, negligible in custom mode
if use_custom_inertia
    smiData.Solid(10).mass = negligible;
    smiData.Solid(10).CoM = [0 1.5 0];
    smiData.Solid(10).MoI = [negligible negligible negligible];
    smiData.Solid(10).PoI = [0 0 0];
else
    smiData.Solid(10).mass = 0.0014138035963256134;  % kg
    smiData.Solid(10).CoM = [0 1.5 0];  % mm
    smiData.Solid(10).MoI = [0.014169846544173465 0.026218987693858505 0.014169846544173461];  % kg*mm^2
    smiData.Solid(10).PoI = [0 0 0];  % kg*mm^2
end
smiData.Solid(10).color = [0.75294117647058822 0.75294117647058822 1];
smiData.Solid(10).opacity = 1;
smiData.Solid(10).ID = "Bearings*:*Default";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(11): 92981A750 Shoulder Screws — structural only, negligible in custom mode
if use_custom_inertia
    smiData.Solid(11).mass = negligible;
    smiData.Solid(11).CoM = [5.6455653797721542e-05 -0.000518500638975714 3.4161992714617413];
    smiData.Solid(11).MoI = [negligible negligible negligible];
    smiData.Solid(11).PoI = [0 0 0];
else
    smiData.Solid(11).mass = 0.0060000000000000001;  % kg
    smiData.Solid(11).CoM = [5.6455653797721542e-05 -0.000518500638975714 3.4161992714617413];  % mm
    smiData.Solid(11).MoI = [0.17355733724890687 0.17355631103287156 0.054583742387186822];  % kg*mm^2
    smiData.Solid(11).PoI = [-2.5684020865881519e-05 -1.5917404934822531e-05 -7.5167803141983905e-07];  % kg*mm^2
end
smiData.Solid(11).color = [0.75294117647058822 0.75294117647058822 0.75294117647058822];
smiData.Solid(11).opacity = 1;
smiData.Solid(11).ID = "92981A750_Alloy Steel Shoulder Screws*:*92981A750";

%Inertia Type - Custom
%Visual Properties - Simple
% Solid(12): 94361A522 Short-Thread Screw — structural only, negligible in custom mode
if use_custom_inertia
    smiData.Solid(12).mass = negligible;
    smiData.Solid(12).CoM = [-5.6720195356705963e-05 -0.00010915882165813884 2.8505552443944855];
    smiData.Solid(12).MoI = [negligible negligible negligible];
    smiData.Solid(12).PoI = [0 0 0];
else
    smiData.Solid(12).mass = 0.0060000000000000001;  % kg
    smiData.Solid(12).CoM = [-5.6720195356705963e-05 -0.00010915882165813884 2.8505552443944855];  % mm
    smiData.Solid(12).MoI = [0.19535307891525 0.19535383216934865 0.049786054333846426];  % kg*mm^2
    smiData.Solid(12).PoI = [-1.1174322710137435e-05 2.8403695729933288e-06 9.3942469411732673e-07];  % kg*mm^2
end
smiData.Solid(12).color = [0.75294117647058822 0.75294117647058822 0.75294117647058822];
smiData.Solid(12).opacity = 1;
smiData.Solid(12).ID = "94361A522_Short-Thread Alloy Steel Shoulder Screw*:*94361A522";


%============= Joint =============%
%X Revolute Primitive (Rx) %Y Revolute Primitive (Ry) %Z Revolute Primitive (Rz)
%X Prismatic Primitive (Px) %Y Prismatic Primitive (Py) %Z Prismatic Primitive (Pz) %Spherical Primitive (S)
%Constant Velocity Primitive (CV) %Lead Screw Primitive (LS)
%Position Target (Pos)

%Initialize the CylindricalJoint structure array by filling in null values.
smiData.CylindricalJoint(3).Rz.Pos = 0.0;
smiData.CylindricalJoint(3).Pz.Pos = 0.0;
smiData.CylindricalJoint(3).ID = "";

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.CylindricalJoint(1).Rz.Pos = 90.000000000000043;  % deg
smiData.CylindricalJoint(1).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(1).ID = "[1.5_FRAME BASE-1:-:Mid Assembly-1]";

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.CylindricalJoint(2).Rz.Pos = 130.5223872484687;  % deg
smiData.CylindricalJoint(2).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(2).ID = "[1.5_FRAME BASE-1:-:Avionics rods-1]";

%This joint has been chosen as a cut joint. Simscape Multibody treats cut joints as algebraic constraints to solve closed kinematic loops. The imported model does not use the state target data for this joint.
smiData.CylindricalJoint(3).Rz.Pos = -22.016890549656516;  % deg
smiData.CylindricalJoint(3).Pz.Pos = 0;  % mm
smiData.CylindricalJoint(3).ID = "[1.5_FRAME BASE-1:-:Avionics rods-2]";


%Initialize the RevoluteJoint structure array by filling in null values.
smiData.RevoluteJoint(17).Rz.Pos = 0.0;
smiData.RevoluteJoint(17).ID = "";

smiData.RevoluteJoint(1).Rz.Pos = 83.60705465193773;  % deg
smiData.RevoluteJoint(1).ID = "[DS3218 Digital Servo-1:-:Lower Gear-1]";

smiData.RevoluteJoint(2).Rz.Pos = -89.999999999999986;  % deg
smiData.RevoluteJoint(2).ID = "[Mid Assembly-1:-:Proppulsion Assembly-1]";

smiData.RevoluteJoint(3).Rz.Pos = 51.935385809178669;  % deg
smiData.RevoluteJoint(3).ID = "[Proppulsion Assembly-1:-:Bearings-11]";

smiData.RevoluteJoint(4).Rz.Pos = -15.461204731538606;  % deg
smiData.RevoluteJoint(4).ID = "[Proppulsion Assembly-1:-:94361A522_Short-Thread Alloy Steel Shoulder Screw-1]";

smiData.RevoluteJoint(5).Rz.Pos = 148.56690456881847;  % deg
smiData.RevoluteJoint(5).ID = "[Avionics rods-2:-:Clamp-1]";

smiData.RevoluteJoint(6).Rz.Pos = -20.151676188313012;  % deg
smiData.RevoluteJoint(6).ID = "[Avionics rods-1:-:Clamp-2]";

smiData.RevoluteJoint(7).Rz.Pos = -101.30217720711437;  % deg
smiData.RevoluteJoint(7).ID = "[1.5_FRAME BASE-1:-:Main CF Rods-6]";

smiData.RevoluteJoint(8).Rz.Pos = -44.600860894941057;  % deg
smiData.RevoluteJoint(8).ID = "[1.5_FRAME BASE-1:-:Main CF Rods-7]";

smiData.RevoluteJoint(9).Rz.Pos = -17.330901738985489;  % deg
smiData.RevoluteJoint(9).ID = "[1.5_FRAME BASE-1:-:Main CF Rods-8]";

smiData.RevoluteJoint(10).Rz.Pos = -38.777860543555327;  % deg
smiData.RevoluteJoint(10).ID = "[1.5_FRAME BASE-1:-:Main CF Rods-9]";

smiData.RevoluteJoint(11).Rz.Pos = 45.598545700949465;  % deg
smiData.RevoluteJoint(11).ID = "[1.5_FRAME BASE-1:-:92981A750_Alloy Steel Shoulder Screws-2]";

smiData.RevoluteJoint(12).Rz.Pos = -170.15415839394231;  % deg
smiData.RevoluteJoint(12).ID = "[1.5_FRAME BASE-1:-:Avionics rods-3]";

smiData.RevoluteJoint(13).Rz.Pos = 176.28772199507983;  % deg
smiData.RevoluteJoint(13).ID = "[1.5_FRAME BASE-1:-:Avionics rods-4]";

smiData.RevoluteJoint(14).Rz.Pos = 67.477326414065203;  % deg
smiData.RevoluteJoint(14).ID = "[1.5_FRAME BASE-1:-:Bearings-1]";

smiData.RevoluteJoint(15).Rz.Pos = -89.999999999999986;  % deg
smiData.RevoluteJoint(15).ID = "[1.5_FRAME BASE-1:-:Bearings-2]";

smiData.RevoluteJoint(16).Rz.Pos = 10.000000000000014;  % deg
smiData.RevoluteJoint(16).ID = "[1.5_FRAME BASE-1:-:Bearings-3]";

smiData.RevoluteJoint(17).Rz.Pos = -48.998316460368834;  % deg
smiData.RevoluteJoint(17).ID = "[Bearings-3:-:92981A750_Alloy Steel Shoulder Screws-1]";