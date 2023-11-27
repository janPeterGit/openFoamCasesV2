clc
clear all
close all

B = 0.79;
gravity = 9.81;
density = 1000;

matlabFolder = pwd;

color1 = [0 0.4470 0.7410];
color2 = [0.8500 0.3250 0.0980];
color3 = [0.4660 0.6740 0.1880];
color4 = [0.4940 0.1840 0.5560];

% read openfoam data
paths = ['campagneUniformG0Rotation\H100C'
        'campagneUniformG0Rotation\H045C'];
% paths = ['campagneUniformG0Rotation\H100C'];
% path = 'campagneUniformG0Rotation\H045C';
% path = 'campagneUniformG0Rotation\H100S';
% path = 'campagneUniformG0Rotation\H045S';

for pathSelect = 1:size(paths,1)

    path = paths(pathSelect,:);
    cd(matlabFolder)
    cd(path)
    mainFolder = pwd;

    folderInfo = dir(pwd);
    folders = folderInfo([folderInfo.isdir]);
    cases = {folders.name};
    % Exclude '.' and '..'
    cases = cases(~ismember(cases, {'.', '..'}));

    forcesOF = table();

    except15 = [1 2 3 5 6 7 8 9 10 11 12 13];

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
    f.WindowState = 'maximized'; %fullscreen, minimize, normal, maximize

    tiledlayout(ceil(size(except15,2)/4),5)
    %         tiledlayout(ceil(size(cases,2)/4),4)

    % for i = except15% 1:length(cases)
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

            intForMean = 500; %%%% auf 500 %%%%
            forcesOF.xTotal(i) = abs(mean(forces(end-intForMean:end,2)));
            forcesOF.yTotal(i) = abs(mean(forces(end-intForMean:end,3)));
            forcesOF.zTotal(i) = abs(mean(forces(end-intForMean:end,4)));

            forcesOF.xPressure(i) = abs(mean(forces(end-intForMean:end,5)));
            forcesOF.yPressure(i) = abs(mean(forces(end-intForMean:end,6)));
            forcesOF.zPressure(i) = abs(mean(forces(end-intForMean:end,7)));

            forcesOF.xViscous(i) = abs(mean(forces(end-intForMean:end,8)));
            forcesOF.yViscous(i) = abs(mean(forces(end-intForMean:end,9)));
            forcesOF.zViscous(i) = abs(mean(forces(end-intForMean:end,10)));

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            abweichungGanglinie = 1.005; % 0,5%
            timeStepWindow = 100;

            nexttile
            hold on
            %     plot(forces(end-timeStepWindow:end,1),forces(end-timeStepWindow:end,2))
            %     plot([forces(end-timeStepWindow,1) forces(end,1)], ...
            %         [forces(end,2)*abweichungGanglinie forces(end,2)*abweichungGanglinie],'r-')
            %     plot([forces(end-timeStepWindow,1) forces(end,1)], ...
            %         [forces(end,2)/abweichungGanglinie forces(end,2)/abweichungGanglinie],'r-')

            plot(forces(1:end,1),forces(1:end,2))
            plot([forces(1,1) forces(end,1)], ...
                [forcesOF.xTotal(i)*abweichungGanglinie forcesOF.xTotal(i)*abweichungGanglinie],'r-')
            plot([forces(1,1) forces(end,1)], ...
                [forcesOF.xTotal(i)/abweichungGanglinie forcesOF.xTotal(i)/abweichungGanglinie],'r-')

            %         dim = [0.6 0.6 0.3 0.3];
            %         str = {['pressure=',num2str(forces(end,5)/forces(end,2)*100),...
            %             '%, friction=',num2str(forces(end,8)/forces(end,2)*100),'%']};
            %         annotation('textbox',dim,'String',str,'FitBoxToText','on');

            ylim([forces(end,2)/1.05 forces(end,2)*1.05])

            grid on
            box off

            ylabel('$F_{x}$',Interpreter="latex")
            xlabel('iteration $i$',Interpreter="latex")
            title(['$L=',num2str(forcesOF.L(i)),'\textrm{ m}, ', ...
                '\gamma=',num2str(forcesOF.gamma(i)),'^\circ, ', ...
                'h=',num2str(forcesOF.h(i)),'\textrm{ m}, ', ...
                'u=',num2str(forcesOF.v(i)),'\textrm{ m/s}$'],Interpreter="latex")

            set(gca,'TickLabelInterpreter','latex')

            if i == 1
                legend(Interpreter="latex")
            end


            %         figureName = ['..\..\..\..\checkForces_',cases{i},'.png'];
            %         exportgraphics(f,figureName,'Resolution',200)


            %         pause(1)
            %         close all
            cd(mainFolder)




        end
    end

    close(gcf)
    %%

    forcesOF.xPressurePortion = round(forcesOF.xPressure ./ forcesOF.xTotal .*100,1);
    forcesOF.xViscousPortion = round(forcesOF.xViscous ./ forcesOF.xTotal .*100,1);
    forcesOF.yPressurePortion = round(forcesOF.yPressure ./ forcesOF.yTotal .*100,1);
    forcesOF.yViscousPortion = round(forcesOF.yViscous ./ forcesOF.yTotal .*100,1);

    forcesOF.Aref = sind(forcesOF.gamma).* forcesOF.L .* forcesOF.D + cosd(forcesOF.gamma) .* pi() ./ 4 .* forcesOF.D.^2;
    forcesOF.BR = forcesOF.Aref ./ (forcesOF.h .*B);

    forcesOF.CDBR = 2 * forcesOF.xTotal ./(density * forcesOF.v.^2 .* forcesOF.Aref .* (1-forcesOF.BR).^-2);

      %%
    font = 'Arial';
    fontSize = 8;
    f = figure('DefaultTextFontName', font, ...
        'DefaultAxesFontName', font,...
        'DefaultAxesFontSize',fontSize, ...
        'DefaultTextFontSize',fontSize);
    f.Name = 'anteilDruckReibung';
    f.Color = [1 1 1];
    f.Units = 'centimeters';
    f.InnerPosition = [5+pathSelect*2 5 7.2 7];
    f.WindowState = 'normal'; %fullscreen, minimize, normal, maximize

%     figure()
    hold on
%     barPlot = bar(forcesOF.gamma,[forcesOF.xPressurePortion forcesOF.xViscousPortion],'stacked');
% 
%     barPlot(1).EdgeColor = color1;
%     barPlot(1).FaceColor = color1;
%     barPlot(1).FaceAlpha = .2;
% 
%     barPlot(2).EdgeColor = color2;
%     barPlot(2).FaceColor = color2;
%     barPlot(2).FaceAlpha = .2;
% 
%     
%     ylabel('Widerstandsanteil in \%',Interpreter='latex');
%     xlabel('$\gamma$ in $^\circ$',Interpreter='latex');
%     grid on
%     box off
% 
%     set(gca,'TickLabelInterpreter','latex')
%     legend('Druckkraft $F_{D,x}$','Reibungskraft $F_{f,x}$',...
%         Interpreter="latex",Location="northoutside",orientation='horizontal')
% 
%     figure()

%     yyaxis left; % Use the left y-axis for the first set of data points
    plotPressure = plot(forcesOF.gamma,forcesOF.xPressurePortion, 'b-o'); % Plot the first set of data points with blue circles
    plotPressure.Color = color1;
    plotPressure.DisplayName = "Druckkraft $F_{D,x}$";
    ylim([0 100])
    % plotPressure = plot(forcesOF.gamma,forcesOF.yPressurePortion, 'b-v'); % Plot the first set of data points with blue circles
    % plotPressure.Color = color1;
    % plotPressure.DisplayName = "F_{D,y}";

    % Customize the left y-axis
    ylabel('Widerstsandsanteil in \%',Interpreter='latex');
%     set(gca, 'YColor', color1); % Set the y-axis color to match the plot

%     yyaxis right; % Use the right y-axis for the second set of data points
    plotViscous = plot(forcesOF.gamma,forcesOF.xViscousPortion, 'r-s'); % Plot the second set of data points with red stars
    plotViscous.Color = color2;
    plotViscous.DisplayName = "Reibungskraft $F_{f,x}$";
    ylim([0 100])
    % plotViscous = plot(forcesOF.gamma,forcesOF.yViscousPortion, 'r-^'); % Plot the second set of data points with red stars
    % plotViscous.Color = color2;
    % plotViscous.DisplayName = "F_{Viscous,y}";

    % Customize the right y-axis
%     ylabel('Reibungskraftanteil in \%',Interpreter='latex');
%     set(gca, 'YColor', color2); % Set the y-axis color to match the plot

    xlabel('$\gamma$ in $^\circ$',Interpreter='latex');
    xlim([0 90])
    xticks(0:10:90)
    grid on
    box off

%     xticks([])
    
%     currentFolder = pwd; cd(matlabFolder)
%     breakyaxis([max(forcesOF.xViscousPortion)+7.5 min(forcesOF.xPressurePortion)-7.5]); cd(currentFolder)

    set(gca,'TickLabelInterpreter','latex')
    legend(Interpreter="latex",Location="east")
    figureName = ['anteilDruckReibung_',path(end-4:end),'.pdf'];
    % figureName = ['D:\OneDrive - Universitaet Duisburg-Essen\03_Promotion\01_Dokument\00_Main\figures\07ergebnisse\forcesRotationFpressureVsFviscous.pdf'];
    exportgraphics(f,figureName)
    %%
%     font = 'Arial';
%     fontSize = 8;
%     f = figure('DefaultTextFontName', font, ...
%         'DefaultAxesFontName', font,...
%         'DefaultAxesFontSize',fontSize, ...
%         'DefaultTextFontSize',fontSize);
%     f.Name = 'Forces Specific Momentum';
%     f.Color = [1 1 1];
%     f.Units = 'centimeters';
%     f.InnerPosition = [5 5 7.2 7];
%     f.WindowState = 'normal'; %fullscreen, minimize, normal, maximize
% 
% 
%     hold on
%     yyaxis left; % Use the left y-axis for the first set of data points
%     plotPressure = plot(forcesOF.gamma,forcesOF.xPressurePortion, 'b-o'); % Plot the first set of data points with blue circles
%     plotPressure.Color = color1;
%     plotPressure.DisplayName = "$F_{D,x}$";
%     % plotPressure = plot(forcesOF.gamma,forcesOF.yPressurePortion, 'b-v'); % Plot the first set of data points with blue circles
%     % plotPressure.Color = color1;
%     % plotPressure.DisplayName = "F_{D,y}";
% 
%     % Customize the left y-axis
%     ylabel('Druckkraftanteil in \%',Interpreter='latex');
%     set(gca, 'YColor', color1); % Set the y-axis color to match the plot
% 
%     yyaxis right; % Use the right y-axis for the second set of data points
%     plotViscous = plot(forcesOF.gamma,forcesOF.xViscousPortion, 'r-s'); % Plot the second set of data points with red stars
%     plotViscous.Color = color2;
%     plotViscous.DisplayName = "$F_{f,x}$";
%     % plotViscous = plot(forcesOF.gamma,forcesOF.yViscousPortion, 'r-^'); % Plot the second set of data points with red stars
%     % plotViscous.Color = color2;
%     % plotViscous.DisplayName = "F_{Viscous,y}";
% 
%     % Customize the right y-axis
%     ylabel('Reibungskraftanteil in \%',Interpreter='latex');
%     set(gca, 'YColor', color2); % Set the y-axis color to match the plot
% 
%     xlabel('$\gamma$ in $^\circ$',Interpreter='latex');
%     xlim([0 90])
%     xticks(0:10:90)
%     grid on
%     box off
% 
%     set(gca,'TickLabelInterpreter','latex')
%     legend(Interpreter="latex",Location="east")
%     figureName = 'test.pdf';
%     % figureName = ['D:\OneDrive - Universitaet Duisburg-Essen\03_Promotion\01_Dokument\00_Main\figures\07ergebnisse\forcesRotationFpressureVsFviscous.pdf'];
%     exportgraphics(f,figureName)

    %%
    % Berechnung des Betrags der resultierenden Kraft
    forcesOF.Fres = sqrt(forcesOF.xTotal.^2 + forcesOF.yTotal.^2);

    % Berechnung des Winkels der Kraft in Grad
    forcesOF.theta = atan2(forcesOF.yTotal, forcesOF.xTotal) * (180 / pi);
    forcesOF.thetaOrthogonal = 90-forcesOF.gamma-forcesOF.theta;

    forcesOF.Fgamma = forcesOF.xTotal.*cos(deg2rad(90-forcesOF.gamma)) + forcesOF.yTotal.*sin(deg2rad(90-forcesOF.gamma));

    % Ausgabe der Ergebnisse
    fprintf('Betrag der resultierenden Kraft: %f\n', forcesOF.Fres);
    fprintf('Winkel der Kraft (in Grad): %f\n', forcesOF.theta);

    font = 'Arial';
    fontSize = 8;
    f = figure('DefaultTextFontName', font, ...
        'DefaultAxesFontName', font,...
        'DefaultAxesFontSize',fontSize, ...
        'DefaultTextFontSize',fontSize);
    f.Name = 'anteilQuerTangentialResultierende';
    f.Color = [1 1 1];
    f.Units = 'centimeters';
    f.InnerPosition = [5 5+pathSelect*2 7.2 7];
    f.WindowState = 'normal'; %fullscreen, minimize, normal, maximize

    color1 = [0 0.4470 0.7410];
    color2 = [0.8500 0.3250 0.0980];

    hold on
    yyaxis left; % Use the left y-axis for the first set of data points
    plotPressure = plot(forcesOF.gamma,forcesOF.xTotal, 'b--d'); % Plot the first set of data points with blue circles
    plotPressure.Color = color3;
    plotPressure.DisplayName = "$F_x$";

    % Customize the left y-axis
    ylabel('$F$ in N',Interpreter='latex');
    % set(gca, 'YColor', color1); % Set the y-axis color to match the plot


    plotViscous = plot(forcesOF.gamma,forcesOF.yTotal, 'r-.^'); % Plot the second set of data points with red stars
    plotViscous.Color = color3;
    plotViscous.DisplayName = "$F_y$";

    % Customize the right y-axis
    % ylabel('Reibungskraftanteil in \%',Interpreter='latex');
    yticks(0:ceil(max(forcesOF.Fres))/10:ceil(max(forcesOF.Fres)))
    set(gca, 'YColor', color3); % Set the y-axis color to match the plot

    plotViscous = plot(forcesOF.gamma,forcesOF.Fres, 'r-s'); % Plot the second set of data points with red stars
    plotViscous.Color = color3;
    plotViscous.DisplayName = "$F_\textrm{res}$";

    yyaxis right; % Use the right y-axis for the second set of data points
    plotViscous = plot(forcesOF.gamma,forcesOF.thetaOrthogonal, 'r-o'); % Plot the second set of data points with red stars
    plotViscous.Color = color4;
    plotViscous.DisplayName = "$\theta_\perp$";

    % Customize the right y-axis
    ylabel('Winkel von $F_\textrm{res}$ in $^\circ$',Interpreter='latex');
%     yticks(min(ylim):(max(ylim)-min(ylim))/10:ceil(max(ylim)+1))
    set(gca, 'YColor', color4); % Set the y-axis color to match the plot

    xlabel('$\gamma$ in $^\circ$',Interpreter='latex');
    xlim([0 90])
    xticks(0:10:90)

    % ylim([min(forcesOF.xTotal) max(forcesOF.xTotal)])
    grid on
    box off

    set(gca,'TickLabelInterpreter','latex')
    legend(Interpreter="latex",Location="northoutside",Orientation="vertical",NumColumns=2)
    figureName = ['anteilQuerTangentialResultierende_',path(end-4:end),'.pdf'];
    % figureName = ['D:\OneDrive - Universitaet Duisburg-Essen\03_Promotion\01_Dokument\00_Main\figures\07ergebnisse\forcesRotationFpressureVsFviscous.pdf'];
    exportgraphics(f,figureName)



    %%
    % font = 'Arial';
    %         fontSize = 8;
    %         f = figure('DefaultTextFontName', font, ...
    %             'DefaultAxesFontName', font,...
    %             'DefaultAxesFontSize',fontSize, ...
    %             'DefaultTextFontSize',fontSize);
    %         f.Name = 'Forces Specific Momentum';
    %         f.Color = [1 1 1];
    %         f.Units = 'centimeters';
    %         f.InnerPosition = [5 5 7.2 7];
    %         f.WindowState = 'normal'; %fullscreen, minimize, normal, maximize
    %
    % color1 = [0 0.4470 0.7410];
    % color2 = [0.8500 0.3250 0.0980];
    % color3 = [0.4660 0.6740 0.1880];
    % color4 = [0.4940 0.1840 0.5560];
    %
    % hold on
    % yyaxis left; % Use the left y-axis for the first set of data points
    % plotPressure = plot(forcesOF.gamma,forcesOF.xTotal, 'b-s'); % Plot the first set of data points with blue circles
    % plotPressure.Color = color3;
    % plotPressure.DisplayName = "Druckkraft";
    %
    % % Customize the left y-axis
    % ylabel('$F_x$',Interpreter='latex');
    % set(gca, 'YColor', color3); % Set the y-axis color to match the plot
    %
    % if forcesOF.h(1) == 0.045
    % else
    %     yyaxis right; % Use the right y-axis for the second set of data points
    %     plotViscous = plot(forcesOF.gamma,forcesOF.CDBR, 'r-v'); % Plot the second set of data points with red stars
    %     plotViscous.Color = color4;
    %     plotViscous.DisplayName = "Reibungskraft";
    %
    %     % Customize the right y-axis
    %     ylabel('$C_{D,BR}$',Interpreter='latex');
    %     set(gca, 'YColor', color4); % Set the y-axis color to match the plot
    % end
    %
    % xlim([0 90])
    % xticks(0:10:90)
    % xlabel('$\gamma$ in $^\circ$',Interpreter='latex');
    % grid on
    % box off
    %
    % set(gca,'TickLabelInterpreter','latex')
    % % legend(Interpreter="latex",Location="east")
    % figureName = 'test2.pdf';
    % % figureName = ['D:\OneDrive - Universitaet Duisburg-Essen\03_Promotion\01_Dokument\00_Main\figures\07ergebnisse\forcesRotationCDvsF.pdf'];
    %     exportgraphics(f,figureName)

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