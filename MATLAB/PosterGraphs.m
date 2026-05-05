% logreader.m
% Use this script to read data from your micro SD card

clear;
%clf;

%% dana point motor data import

filenum = '012'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');

% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16') = 2;
dataSizes.('char') = 1;
dataSizes.('bool') = 1;

% read from info file to get log file structure
fileID = fopen(infofile);
items = textscan(fileID,'%s','Delimiter',',','EndOfLine','\r\n');
fclose(fileID);
[ncols,~] = size(items{1});
ncols = ncols/2;
varNames = items{1}(1:ncols)';
varTypes = items{1}(ncols+1:end)';
varLengths = zeros(size(varTypes));
colLength = 256;
for i = 1:numel(varTypes)
    varLengths(i) = dataSizes.(varTypes{i});
end
R = cell(1,numel(varNames));

% read column-by-column from datafile
fid = fopen(datafile,'rb');
for i=1:numel(varTypes)
    %# seek to the first field of the first record
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    
    %# % read column with specified format, skipping required number of bytes
    R{i} = fread(fid, Inf, ['*' varTypes{i}], colLength-varLengths(i));
    eval(strcat(varNames{i},'=','R{',num2str(i),'};'));
end
fclose(fid);

%% Process your data here

% assigned channels based on logger mapping -> Edit based on column names 
%A00 -> Pressure 
%A01 -> UV
%A02 -> Temperature 
pressure_raw_Dm = cast(A00,"single");
uv_raw_Dm = cast(A01, "single");
temp_raw_Dm = cast(A02, "single");
depth1_Dm = depth;
depthdes_Dm = depth_des;


% converting to ACD counts to volts 
pressure_V_Dm = pressure_raw_Dm.*3.3/1024;
uv_V_Dm = uv_raw_Dm.*3.3/1024;
temp_V_Dm = temp_raw_Dm.*3.3/1024;

%change:
tdown_Dm = 434:769; % _final = 2638:3060, 012 = 434:769, 002 = 3460:3980, 004 = 1290:1602

% Separating data going down past our waypoints
pressure_Vd_Dm = pressure_V_Dm(tdown_Dm);
uv_Vd_Dm = uv_V_Dm(tdown_Dm);
temp_Vd_Dm = temp_V_Dm(tdown_Dm);
depthd_Dm = depth1_Dm(tdown_Dm);

%% Calibrations 
% pressure calibration: voltage -> depth 
%depth = -2.9*pressure_V+8.88;

%temperature calibration: voltage -> temp 
temp_C = (-5.92*temp_V_Dm) + 25.5;
temp_Cd_Dm = temp_C(tdown_Dm);

%UV calibration: voltage -> UV index 
G = 8.085; %Edit as needed 
uv_index = 10*(uv_V_Dm/G);
uv_ind_Dm = uv_index(tdown_Dm);

%% dana point no motor data import

filenum = '_final'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');

% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16') = 2;
dataSizes.('char') = 1;
dataSizes.('bool') = 1;

% read from info file to get log file structure
fileID = fopen(infofile);
items = textscan(fileID,'%s','Delimiter',',','EndOfLine','\r\n');
fclose(fileID);
[ncols,~] = size(items{1});
ncols = ncols/2;
varNames = items{1}(1:ncols)';
varTypes = items{1}(ncols+1:end)';
varLengths = zeros(size(varTypes));
colLength = 256;
for i = 1:numel(varTypes)
    varLengths(i) = dataSizes.(varTypes{i});
end
R = cell(1,numel(varNames));

% read column-by-column from datafile
fid = fopen(datafile,'rb');
for i=1:numel(varTypes)
    %# seek to the first field of the first record
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    
    %# % read column with specified format, skipping required number of bytes
    R{i} = fread(fid, Inf, ['*' varTypes{i}], colLength-varLengths(i));
    eval(strcat(varNames{i},'=','R{',num2str(i),'};'));
end
fclose(fid);

%% Process your data here

% assigned channels based on logger mapping -> Edit based on column names 
%A00 -> Pressure 
%A01 -> UV
%A02 -> Temperature 
pressure_raw_DNm = cast(A00,"single");
uv_raw_DNm = cast(A01, "single");
temp_raw_DNm = cast(A02, "single");
depth1_DNm = depth;
depthdes_DNm = depth_des;

% converting to ACD counts to volts 
pressure_V_DNm = pressure_raw_DNm.*3.3/1024;
uv_V_DNm = uv_raw_DNm.*3.3/1024;
temp_V_DNm = temp_raw_DNm.*3.3/1024;

%change:
tdown_DNm = 2638:3060; % _final = 2638:3060, 012 = , 002 = 3460:3980, 004 = 1290:1602

% Separating data going down past our waypoints
pressure_Vd_DNm = pressure_V_DNm(tdown_DNm);
uv_Vd_DNm = uv_V_DNm(tdown_DNm);
temp_Vd_DNm = temp_V_DNm(tdown_DNm);
depthd_DNm = depth1_DNm(tdown_DNm);

%% Calibrations 
% pressure calibration: voltage -> depth 
%depth = -2.9*pressure_V+8.88;

%temperature calibration: voltage -> temp 
temp_C = (-5.92*temp_V_DNm) + 25.5;
temp_Cd_DNm = temp_C(tdown_DNm);

%UV calibration: voltage -> UV index 
G = 8.085; %Edit as needed 
uv_index = 10*(uv_V_DNm/G);
uv_ind_DNm = uv_index(tdown_DNm);

%% Phake lake motor data import

filenum = '002'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');

% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16') = 2;
dataSizes.('char') = 1;
dataSizes.('bool') = 1;

% read from info file to get log file structure
fileID = fopen(infofile);
items = textscan(fileID,'%s','Delimiter',',','EndOfLine','\r\n');
fclose(fileID);
[ncols,~] = size(items{1});
ncols = ncols/2;
varNames = items{1}(1:ncols)';
varTypes = items{1}(ncols+1:end)';
varLengths = zeros(size(varTypes));
colLength = 256;
for i = 1:numel(varTypes)
    varLengths(i) = dataSizes.(varTypes{i});
end
R = cell(1,numel(varNames));

% read column-by-column from datafile
fid = fopen(datafile,'rb');
for i=1:numel(varTypes)
    %# seek to the first field of the first record
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    
    %# % read column with specified format, skipping required number of bytes
    R{i} = fread(fid, Inf, ['*' varTypes{i}], colLength-varLengths(i));
    eval(strcat(varNames{i},'=','R{',num2str(i),'};'));
end
fclose(fid);

%% Process your data here

% assigned channels based on logger mapping -> Edit based on column names 
%A00 -> Pressure 
%A01 -> UV
%A02 -> Temperature 
pressure_raw_Pm = cast(A00,"single");
uv_raw_Pm = cast(A01, "single");
temp_raw_Pm = cast(A02, "single");
depth1_Pm = depth;
depthdes_Pm = depth_des;


% converting to ACD counts to volts 
pressure_V_Pm = pressure_raw_Pm.*3.3/1024;
uv_V_Pm = uv_raw_Pm.*3.3/1024;
temp_V_Pm = temp_raw_Pm.*3.3/1024;

%change:
tdown_Pm = 3460:3980; % _final = 2638:3060, 012 = , 002 = 3460:3980, 004 = 1290:1602

% Separating data going down past our waypoints
pressure_Vd_Pm = pressure_V_Pm(tdown_Pm);
uv_Vd_Pm = uv_V_Pm(tdown_Pm);
temp_Vd_Pm = temp_V_Pm(tdown_Pm);
depthd_Pm = depth1_Pm(tdown_Pm);

%% Calibrations 
% pressure calibration: voltage -> depth 
%depth = -2.9*pressure_V+8.88;

%temperature calibration: voltage -> temp 
temp_C = (-5.92*temp_V_Pm) + 25.5;
temp_Cd_Pm = temp_C(tdown_Pm);

%UV calibration: voltage -> UV index 
GP = 3.64; %Edit as needed 
uv_index = 10*(uv_V_Pm/GP);
uv_ind_Pm = uv_index(tdown_Pm);

%% Phake lake no motor data import

filenum = '004'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');

% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16') = 2;
dataSizes.('char') = 1;
dataSizes.('bool') = 1;

% read from info file to get log file structure
fileID = fopen(infofile);
items = textscan(fileID,'%s','Delimiter',',','EndOfLine','\r\n');
fclose(fileID);
[ncols,~] = size(items{1});
ncols = ncols/2;
varNames = items{1}(1:ncols)';
varTypes = items{1}(ncols+1:end)';
varLengths = zeros(size(varTypes));
colLength = 256;
for i = 1:numel(varTypes)
    varLengths(i) = dataSizes.(varTypes{i});
end
R = cell(1,numel(varNames));

% read column-by-column from datafile
fid = fopen(datafile,'rb');
for i=1:numel(varTypes)
    %# seek to the first field of the first record
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    
    %# % read column with specified format, skipping required number of bytes
    R{i} = fread(fid, Inf, ['*' varTypes{i}], colLength-varLengths(i));
    eval(strcat(varNames{i},'=','R{',num2str(i),'};'));
end
fclose(fid);

%% Process your data here

% assigned channels based on logger mapping -> Edit based on column names 
%A00 -> Pressure 
%A01 -> UV
%A02 -> Temperature 
pressure_raw_PNm = cast(A00,"single");
uv_raw_PNm = cast(A01, "single");
temp_raw_PNm = cast(A02, "single");
depth1_PNm = depth;
depthdes_PNm = depth_des;


% converting to ACD counts to volts 
pressure_V_PNm = pressure_raw_PNm.*3.3/1024;
uv_V_PNm = uv_raw_PNm.*3.3/1024;
temp_V_PNm = temp_raw_PNm.*3.3/1024;

%change:
tdown_PNm = 1290:1602; % _final = 2638:3060, 012 = , 002 = 3460:3980, 004 = 1290:1602

% Separating data going down past our waypoints
pressure_Vd_PNm = pressure_V_PNm(tdown_PNm);
uv_Vd_PNm = uv_V_PNm(tdown_PNm);
temp_Vd_PNm = temp_V_PNm(tdown_PNm);
depthd_PNm = depth1_PNm(tdown_PNm);

%% Calibrations 
% pressure calibration: voltage -> depth 
%depth = -2.9*pressure_V+8.88;

%temperature calibration: voltage -> temp 
temp_C = (-5.92*temp_V_PNm) + 25.5;
temp_Cd_PNm = temp_C(tdown_PNm);

%UV calibration: voltage -> UV index 
GP = 3.64; %Edit as needed 
uv_index = 10*(uv_V_PNm/GP);
uv_ind_PNm = uv_index(tdown_PNm);

%% poster graphs

% error calculations
%% first for UV:
err_uVoltPm = 0.792089.*((uv_Vd_Pm/GP).^2);
upper_uVoltPm = uv_Vd_Pm + err_uVoltPm;
upper_uvPm = 10*(upper_uVoltPm/GP);
lower_uVoltPm = uv_Vd_Pm - err_uVoltPm;
lower_uvPm = 10*(lower_uVoltPm/GP);
err_uvPm = 10*(err_uVoltPm/GP);

err_uVoltPNm = 0.792089.*((uv_Vd_PNm/GP).^2);
upper_uVoltPNm = uv_Vd_PNm + err_uVoltPNm;
upper_uvPNm = 10*(upper_uVoltPNm/GP);
lower_uVoltPNm = uv_Vd_PNm - err_uVoltPNm;
lower_uvPNm = 10*(lower_uVoltPNm/GP);
err_uvPNm = 10*(err_uVoltPNm/GP);

err_uVoltDm = 0.792089.*((uv_Vd_Dm/G).^2);
upper_uVoltDm = uv_Vd_Dm + err_uVoltDm;
upper_uvDm = 10*(upper_uVoltDm/G);
lower_uVoltDm = uv_Vd_Dm - err_uVoltDm;
lower_uvDm = 10*(lower_uVoltDm/G);

err_uVoltDNm = 0.792089.*((uv_Vd_DNm/G).^2);
upper_uVoltDNm = uv_Vd_DNm + err_uVoltDNm;
upper_uvDNm = 10*(upper_uVoltDNm/G);
lower_uVoltDNm = uv_Vd_DNm - err_uVoltDNm;
lower_uvDNm = 10*(lower_uVoltDNm/G);

% Phake Lake

figure;
plot(depthd_PNm, uv_ind_PNm)
hold on
% errorbar(depthd_PNm, uv_ind_PNm, err_uvPNm, 'o', 'LineWidth',1.5,'MarkerSize',8) %this looks terrible
% plot(depthd_PNm, lower_uvPNm, 'm')
% plot(depthd_PNm, upper_uvPNm, 'm')
% shade(depthd_PNm, upper_uvPNm, depthd_PNm, lower_uvPNm, 'FillType', [1 2])
plot(depthd_Pm, uv_ind_Pm)
% plot(depthd_Pm, lower_uvPm, 'm')
% plot(depthd_Pm, upper_uvPm, 'm')
% shade(depthd_Pm, upper_uvPm, depthd_Pm, lower_uvPm)
title('UV vs Depth at Phake Lake')
ylabel('UV index')
xlabel('Depth [m]')
legend('Without motors', 'With motors running')
grid on
hold off

figure;
plot(depthd_PNm, temp_Cd_PNm)
hold on
plot(depthd_Pm, temp_Cd_Pm)
title('Temperature vs Depth at Phake Lake')
ylabel('Temperature [degrees C]')
xlabel('Depth [m]')
legend('Without motors', 'With motors running')
grid on
hold off

% Dana Point

figure;
plot(depthd_DNm, uv_ind_DNm)
hold on
% plot(depthd_DNm, lower_uvDNm, 'm')
% plot(depthd_DNm, upper_uvDNm, 'm')
% shade(depthd_DNm, upper_uvDNm, depthd_DNm, lower_uvDNm)
plot(depthd_Dm, uv_ind_Dm)
title('UV vs Depth at Dana Point')
ylabel('UV index')
xlabel('Depth [m]')
legend('Without motors', 'With motors running')
grid on
hold off

figure;
plot(depthd_DNm, temp_Cd_DNm)
hold on
plot(depthd_Dm, temp_Cd_Dm)
title('Temperature vs Depth at Dana Point')
ylabel('Temperature [degrees C]')
xlabel('Depth [m]')
legend('Without motors', 'With motors running')
grid on
hold off

% Combined plots

figure;
blue = [0 0.7 1];
green = [0 0.5 0.1];
plot(depthd_DNm, uv_ind_DNm, 'Color', blue, 'LineWidth', 1.5);
hold on
plot(depthd_Dm, uv_ind_Dm, '-.', 'Color', blue, 'LineWidth', 0.5);
title('UV vs Depth at Dana Point')
plot(depthd_PNm, uv_ind_PNm, 'Color', green, 'LineWidth', 1.5);
plot(depthd_Pm, uv_ind_Pm, '-.', 'Color', green, 'LineWidth', 0.5);
ylabel('UV index')
xlabel('Depth [m]')
legend('Dana point without motors', 'Dana point with motors running', 'Phake lake without motors', 'Phake lake with motors running')
grid on
xlim([-0.5 5]);
hold off

figure;
plot(depthd_Dm, temp_Cd_Dm, '--', 'Color', blue, 'LineWidth', 0.5);
hold on
plot(depthd_DNm, temp_Cd_DNm, 'Color', blue, 'LineWidth', 1.5);
plot(depthd_Pm, temp_Cd_Pm, '--', 'Color', green, 'LineWidth', 0.5);
plot(depthd_PNm, temp_Cd_PNm, 'Color', green, 'LineWidth', 1.5);
title('Temperature vs Depth at Dana Point')
ylabel('Temperature [degrees C]')
xlim([-0.5 5]);
xlabel('Depth [m]')
legend('Dana point with motors running', 'Dana point without motors', 'Phake lake with motors running', 'Phake lake without motors')
grid on
hold off

% getting rid of non unique rows

% combining into a 2d array of [depth lower upper]

% uv dana point

uvlow_DNm = ones(length(depthd_DNm), 2);
uvup_DNm = ones(length(depthd_DNm), 2);

for n = 1:length(depthd_DNm)
    uvlow_DNm(n, 1) = depthd_DNm(n);
    uvlow_DNm(n, 2) = lower_uvDNm(n);
    uvup_DNm(n, 1) = depthd_DNm(n);
    uvup_DNm(n, 2) = upper_uvDNm(n);
end

% [~,ia,ic] = unique(uvlow_DNm, 'rows');          % Unique Elements
% v = accumarray(ic, 1);                  % Tally Occurrences Of Rows
% uniqueUVlowDNm = uvlow_DNm(ia(v==1),:);                      % Keep Rows That Only Appear Once
% 
% [~,ia,ic] = unique(uvup_DNm, 'rows');          % Unique Elements
% v = accumarray(ic, 1);                  % Tally Occurrences Of Rows
% uniqueUVupDNm = uvup_DNm(ia(v==1),:);                      % Keep Rows That Only Appear Once

[C, ia] = unique(uvlow_DNm(:, 1));          % Unique Elements
uniqueUVlowDNm = uvlow_DNm(ia,:);   

[C, ia] = unique(uvup_DNm(:, 1));          % Unique Elements
uniqueUVupDNm = uvup_DNm(ia,:); 

uvlow_Dm = ones(length(depthd_Dm), 2);
uvup_Dm = ones(length(depthd_Dm), 2);

for n = 1:length(depthd_Dm)
    uvlow_Dm(n, 1) = depthd_Dm(n);
    uvlow_Dm(n, 2) = lower_uvDm(n);
    uvup_Dm(n, 1) = depthd_Dm(n);
    uvup_Dm(n, 2) = upper_uvDm(n);
end

[C, ia] = unique(uvlow_Dm(:, 1));          % Unique Elements
uniqueUVlowDm = uvlow_Dm(ia,:);   

[C, ia] = unique(uvup_Dm(:, 1));          % Unique Elements
uniqueUVupDm = uvup_Dm(ia,:); 

figure;
plot(depthd_DNm, uv_ind_DNm)
hold on
shade(uniqueUVlowDNm(:, 1), uniqueUVlowDNm(:, 2), uniqueUVupDNm(:, 1), uniqueUVupDNm(:, 2),'FillType',[1 2;2 1])
plot(depthd_Dm, uv_ind_Dm)
shade(uniqueUVlowDm(:, 1), uniqueUVlowDm(:, 2), uniqueUVupDm(:, 1), uniqueUVupDm(:, 2),'FillType',[1 2;2 1])
title('UV vs Depth at Dana Point')
ylabel('UV index')
xlabel('Depth [m]')
legend('Without motors', 'With motors running')
grid on
hold off

% uv phake lake

uvlow_PNm = ones(length(depthd_PNm), 2);
uvup_PNm = ones(length(depthd_PNm), 2);

for n = 1:length(depthd_PNm)
    uvlow_PNm(n, 1) = depthd_PNm(n);
    uvlow_PNm(n, 2) = lower_uvPNm(n);
    uvup_PNm(n, 1) = depthd_PNm(n);
    uvup_PNm(n, 2) = upper_uvPNm(n);
end

[C, ia] = unique(uvlow_PNm(:, 1));          % Unique Elements
uniqueUVlowPNm = uvlow_PNm(ia,:);   

[C, ia] = unique(uvup_PNm(:, 1));          % Unique Elements
uniqueUVupPNm = uvup_PNm(ia,:); 

uvlow_Pm = ones(length(depthd_Pm), 2);
uvup_Pm = ones(length(depthd_Pm), 2);

for n = 1:length(depthd_Pm)
    uvlow_Pm(n, 1) = depthd_Pm(n);
    uvlow_Pm(n, 2) = lower_uvPm(n);
    uvup_Pm(n, 1) = depthd_Pm(n);
    uvup_Pm(n, 2) = upper_uvPm(n);
end

[C, ia] = unique(uvlow_Pm(:, 1));          % Unique Elements
uniqueUVlowPm = uvlow_Pm(ia,:);   

[C, ia] = unique(uvup_Pm(:, 1));          % Unique Elements
uniqueUVupPm = uvup_Pm(ia,:); 

figure;
plot(depthd_PNm, uv_ind_PNm)
hold on
shade(uniqueUVlowPNm(:, 1), uniqueUVlowPNm(:, 2), uniqueUVupPNm(:, 1), uniqueUVupPNm(:, 2),'FillType',[1 2;2 1])
plot(depthd_Pm, uv_ind_Pm)
shade(uniqueUVlowPm(:, 1), uniqueUVlowPm(:, 2), uniqueUVupPm(:, 1), uniqueUVupPm(:, 2),'FillType',[1 2;2 1])
title('UV vs Depth at Phake Lake')
ylabel('UV index')
xlabel('Depth [m]')
legend('Without motors', 'With motors running')
grid on
hold off

%% temp calculations:

Rf = 33000;
Rn = 10000;
Rg = 34000;
Rp = 22000;

errT = @(V) V.*sqrt((0.01.*V.*Rf/Rn).^2 + (0.05.*(Rf/Rn).*(-V+(5*Rp/(Rp+Rg)))).^2 + (0.05.*(Rf/Rn).*(V - 5*Rp/(Rp+Rg))).^2 + (0.05*Rg*5*Rp*(-1-(Rf/Rn))/((Rp+Rg)^2))^2);

err_TDNm = ;
