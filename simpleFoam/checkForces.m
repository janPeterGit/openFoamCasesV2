B = 0.79;
gravity = 9.81;
densitiy = 1000;

matlabFolder = pwd;

% read openfoam data
% path = uigetdir('D:\GitHub\openFoamCasesV2\simpleFoam\');
path = 'campagneUniformG0Rotation';
cd(path)
mainFolder = pwd;

folderInfo = dir(pwd);
folders = folderInfo([folderInfo.isdir]);
cases = {folders.name};
% Exclude '.' and '..'
cases = cases(~ismember(cases, {'.', '..'}));

forcesOF = table();

for i = 1:length(cases)
    dirInfo = dir(cases{i});
    if length(dirInfo) <= 2
    else
        cd([cases{i},'\postProcessing\forcesCylinder'])
        %     i
        forcesOF.D(i) = str2double(extractBetween(cases{i},'D','L'))/1000;
        forcesOF.L(i) = str2double(extractBetween(cases{i},'L','W'))/1000;
        forcesOF.gamma(i) = str2double(extractBetween(cases{i},'W','G'));
        forcesOF.G(i) = str2double(extractBetween(cases{i},'G','H'))/1000;
        forcesOF.h(i) = str2double(extractBetween(cases{i},'H','V'))/1000;
        forcesOF.v(i) = str2double(extractBetween(cases{i},'V','_'))/100;
        forcesOF.Q(i) = forcesOF.v(i) * forcesOF.h(i) * B /1000;
        %     forcesOF.Position(i) = str2double(extractBetween(cases{i},'_','_'));

        timeStepInfo = dir(pwd);
        timeSteps = timeStepInfo([timeStepInfo.isdir]);
        timeStepsNames = {timeSteps.name};
        % Exclude '.' and '..' folders
        timeStepsNames = timeStepsNames(~ismember(timeStepsNames, {'.', '..'}));

        cd(timeStepsNames{1})

        forces = importForcesDat('force.dat');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        font = 'Arial';
        fontSize = 16;
        f = figure('DefaultTextFontName', font, ...
            'DefaultAxesFontName', font,...
            'DefaultAxesFontSize',fontSize, ...
            'DefaultTextFontSize',fontSize);
        f.Name = 'Forces Specific Momentum';
        f.Color = [1 1 1];
        f.Units = 'centimeters';
        f.InnerPosition = [5 5 30 30];
        f.WindowState = 'normal'; %fullscreen, minimize, normal, maximize

        abweichungGanglinie = 1.005; % 0.5%
        timeStepWindow = 100;
        hold on
        %     plot(forces(end-timeStepWindow:end,1),forces(end-timeStepWindow:end,2))
        %     plot([forces(end-timeStepWindow,1) forces(end,1)], ...
        %         [forces(end,2)*abweichungGanglinie forces(end,2)*abweichungGanglinie],'r-')
        %     plot([forces(end-timeStepWindow,1) forces(end,1)], ...
        %         [forces(end,2)/abweichungGanglinie forces(end,2)/abweichungGanglinie],'r-')

        plot(forces(1:end,1),forces(1:end,2))
        plot([forces(1,1) forces(end,1)], ...
            [forces(end,2)*abweichungGanglinie forces(end,2)*abweichungGanglinie],'r-')
        plot([forces(1,1) forces(end,1)], ...
            [forces(end,2)/abweichungGanglinie forces(end,2)/abweichungGanglinie],'r-')

%         ylim([forces(end,2)/1.1 forces(end,2)*1.1])

        grid on
        box off

        ylabel('F_{x,total}')
        xlabel('iteration')
        title(cases{i})

        figureName = ['..\..\..\..\checkForces_',cases{i},'.png'];
        exportgraphics(f,figureName,'Resolution',200)


        pause(1)
%         close all
cd(mainFolder)
    end
end

%% functions

function forceArray = importForcesDat(filenameOF)
% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 11);

% Specify range and delimiter
opts.DataLines = [5, Inf];
opts.Delimiter = ["\t", " ", "(", ")"];

% Specify column names and types
opts.VariableNames = ["Time", "total_x", "total_y", "total_z", "pressure_x", "pressure_y", "pressure_z", "viscous_x", "viscous_y", "viscous_z"];
opts.SelectedVariableNames = ["Time", "total_x", "total_y", "total_z", "pressure_x", "pressure_y", "pressure_z", "viscous_x", "viscous_y", "viscous_z"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";

% Import the data
forceTab = readtable(filenameOF, opts);

% Convert to output type
forceArray = table2array(forceTab);

% Clear temporary variables
clear opts

end