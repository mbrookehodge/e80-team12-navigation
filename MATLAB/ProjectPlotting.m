% logreader.m
% Use this script to read data from your micro SD card

clear;
%clf;

filenum = '028'; % file number for the data you want to read
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

%% assigned channels based on logger mapping -> Edit based on column names 
%A00 -> Pressure 
%A01 -> UV
%A02 -> Temperature 
pressure_raw = cast(A00,"single");
uv_raw = cast(A01, "single");
temp_raw = cast(A02, "single");
depth1 = depth;
depthdes = depth_des;


%% converting to ACD counts to volts 
pressure_V = pressure_raw.*3.3/1024;
uv_V = uv_raw.*3.3/1024;
temp_V = temp_raw.*3.3/1024;

%% Calibrations 
% pressure calibration: voltage -> depth 
%depth = -2.9*pressure_V+8.88;

%temperature calibration: voltage -> temp 
temp_C = (-4.58*temp_V) + 23.2;

%UV calibration: voltage -> UV index 
G = 3.64 %Edit as needed 
uv_index = 10*(uv_V/G);

%% plots: depth vs voltages 
figure;
plot(depth1,pressure_V,'.','Color','b');
ylabel('Pressure Voltage (V)');
xlabel('Depth (m)');
title('Pressure Voltage vs Depth');
grid on;

figure;
plot(depth1,temp_V,'.','Color','r');
ylabel('Temperature Voltage (V)');
xlabel('Depth (m)');
title('Temperature Voltage vs Depth')
grid on;

figure;
plot(depth1,uv_V,'.','Color','g');
ylabel('UV Voltage (V)');
xlabel('Depth (m)');
title('UV Voltage vs Depth')
grid on;

%% plot - depth vs all sensors 
figure;
hold on;
plot(depth1, pressure_V,'.','Color','b','DisplayName','Pressure Voltage');
plot(depth1, temp_V,'.','Color','r','DisplayName','Temperature Voltage');
plot(depth1, uv_V,'.','Color','g','DisplayName','UV Voltage');

ylabel('Voltage (V)');
xlabel('Depth (m)');
title('Sensor Voltages vs Depth')
legend;
grid on;


%% Plots: depth vs calibrated values -> If wanted 
figure;
plot(depth1,temp_C,'.');
ylabel('Temperature (C)');
xlabel('Depth (m)');
title('Temperature vs Depth');
grid on;

figure;
plot(depth1,uv_index, '.');
ylabel('UV Index');
xlabel('Depth (m)');
title('UV Index vs Depth');
grid on;

figure;
plot(depth1)
hold on;
plot(depthdes)
hold off;

figure;
plot(uv_V);
hold on;
plot(depth1);
title("UV TIME AND DEPTH")
xlim([5000,5951])

figure;
plot(temp_V);

figure;
plot(uv_V);

figure;
plot(temp_C);