% logreader.m
% Use this script to read data from your micro SD card

clear;
%clf;

filenum = '012'; % file number for the data you want to read
infofile = strcat('INF', filenum, '.TXT');
datafile = strcat('LOG', filenum, '.BIN');

%% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16') = 2;
dataSizes.('char') = 1;
dataSizes.('bool') = 1;

%% read from info file to get log file structure
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

%% read column-by-column from datafile
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
pressure_raw = cast(A00,"single");
uv_raw = cast(A01, "single");
temp_raw = cast(A02, "single");
depth1 = depth;
depthdes = depth_des;


% converting to ACD counts to volts 
pressure_V = pressure_raw.*3.3/1024;
uv_V = uv_raw.*3.3/1024;
temp_V = temp_raw.*3.3/1024;

%change:
tdown = 1:1800; % _final = 2638:3060, 012 = , 002 = 3460:3980, 004 = 1290:1602

% Separating data going down past our waypoints
pressure_Vd = pressure_V(tdown);
uv_Vd = uv_V(tdown);
temp_Vd = temp_V(tdown);
depthd = depth1(tdown);

%% Calibrations 
% pressure calibration: voltage -> depth 
%depth = -2.9*pressure_V+8.88;

%temperature calibration: voltage -> temp 
temp_C = (-5.92*temp_V) + 25.5;
temp_Cd = temp_C(tdown);

%UV calibration: voltage -> UV index 
G = 8.085; %Edit as needed 
uv_index = 10*(uv_V/G);
uv_ind = uv_index(tdown);

%% plots: depth vs voltages 
figure;
plot(depth1,pressure_V,'.','Color','b');
ylabel('Pressure Voltage (V)');
xlabel('Depth (m)');
title('Pressure Voltage vs Depth');
legend('Dana Point, without motors');
grid on;

figure;
plot(depthd,temp_Vd,'.','Color','r');
ylabel('Temperature Voltage (V)');
xlabel('Depth (m)');
title('Temperature Voltage vs Depth')
legend('Dana Point, without motors');
grid on;

figure;
plot(depthd,uv_Vd,'.','Color','g');
ylabel('UV Voltage (V)');
xlabel('Depth (m)');
title('UV Voltage vs Depth')
legend('Dana Point, without motors');
grid on;

%% plot - depth vs all sensors 
figure;
hold on;
plot(depthd, pressure_Vd,'.','Color','b','DisplayName','Pressure Voltage');
plot(depthd, temp_Vd,'.','Color','r','DisplayName','Temperature Voltage');
plot(depthd, uv_Vd,'.','Color','g','DisplayName','UV Voltage');

ylabel('Voltage (V)');
xlabel('Depth (m)');
title('Sensor Voltages vs Depth at Dana Point, without motors')
legend;
grid on;


%% Plots: depth vs calibrated values -> If wanted 
figure;
plot(depthd,temp_Cd,'.');
ylabel('Temperature (C)');
xlabel('Depth (m)');
title('Temperature vs Depth');
legend('Dana Point, without motors');
grid on;

figure;
plot(depthd,uv_ind, '.');
ylabel('UV Index');
xlabel('Depth (m)');
title('UV Index vs Depth');
legend('Dana Point, without motors');
grid on;

figure;
plot(depth1)
title('Robot dive path at Dana Point, without motors');
hold on;
plot(depthdes)
legend('Actual depth', 'Desired depth');
hold off;

figure;
plot(uv_V);
hold on;
plot(depth1);
title("UV TIME AND DEPTH")
xlim([5000,5951])

figure;
plot(temp_V);
title('Temperature (V) vs time');

figure;
plot(uv_V);
title('UV voltage vs time')

figure;
plot(temp_C);
title('Temperature (C) vs time');

figure;
yyaxis left
plot(depthd,uv_ind, '.');
ylabel('UV Index');
xlabel('Depth (m)');

yyaxis right
plot(depthd,temp_Cd,'.');
ylabel('Temperature (C)');
xlabel('Depth (m)');

title('UV & Temperature vs Depth from Dana Point, run without motors');
legend('UV', 'Temperature');
grid on;

%% poster graphs

