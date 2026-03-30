% logreader.m
% Use this script to read data from your micro SD card
% Modified by: Cooper Davis (codavis@hmc.edu) 03/23/2026

clear;
%clf;

filenum = '050'; % file number for the data you want to read
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

% Must convert Teensy sampling to seconds
loop_period = 99;
t = (0:length(depth)-1)' * loop_period / 1000;

figure;
subplot(2, 1, 1);
plot(t, depth, 'r-');
hold on;
plot(t, depth_des, 'b--');
hold off;
xlabel('Time [s]');
ylabel('Depth [m]');
title('Actual Depth and Desired Depth over Time');
legend('Actual Depth', 'Desired Depth');
grid on;
xlim([0 25]);

subplot(2,1,2);
plot(t, uV, 'g-');
xlabel('Time [s]');
ylabel('Motor Control Effort uV');
title('Vertical Motor Control Effort over Time')
grid on;
xlim([0 25]);