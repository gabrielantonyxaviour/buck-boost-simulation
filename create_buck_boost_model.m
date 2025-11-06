% CREATE BUCK-BOOST CONVERTER SIMULINK MODEL
% This script programmatically creates a complete buck-boost converter
% Simulink model with all necessary components
% Author: Auto-generated
% Date: November 2025

clear all;
close all;
clc;

fprintf('============================================\n');
fprintf('CREATING BUCK-BOOST CONVERTER SIMULINK MODEL\n');
fprintf('============================================\n\n');

%% LOAD DESIGN PARAMETERS
if exist('buck_boost_parameters.mat', 'file')
    load('buck_boost_parameters.mat');
    fprintf('Loaded parameters from buck_boost_parameters.mat\n');
else
    fprintf('Running design_calculations.m first...\n');
    run('design_calculations.m');
    load('buck_boost_parameters.mat');
end

%% CREATE NEW MODEL
modelName = 'BuckBoost_Converter';

% Close model if already open
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

% Create new model
new_system(modelName);
open_system(modelName);

fprintf('\nCreating Simulink model: %s\n', modelName);

%% CONFIGURE SOLVER SETTINGS
fprintf('Configuring solver settings...\n');

set_param(modelName, 'Solver', 'ode23tb');
set_param(modelName, 'SolverType', 'Variable-step');
set_param(modelName, 'StopTime', '0.01'); % 10 ms simulation
set_param(modelName, 'RelTol', '1e-3');
set_param(modelName, 'MaxStep', 'auto');
set_param(modelName, 'MinStep', 'auto');

%% ADD POWER SYSTEM BLOCKS

fprintf('Adding power system components...\n');

% Check if Simscape Electrical is available
try
    % Add powergui block (required for electrical simulation)
    add_block('powerlib/powergui', [modelName '/powergui'], ...
        'Position', [600, 20, 700, 60]);
    set_param([modelName '/powergui'], 'SimulationMode', 'Continuous');

    % DC Voltage Source
    add_block('powerlib/Electrical Sources/DC Voltage Source', ...
        [modelName '/DC_Source'], ...
        'Position', [50, 100, 80, 130]);
    set_param([modelName '/DC_Source'], 'Amplitude', num2str(Vin));

    % MOSFET
    add_block('powerlib/Power Electronics/MOSFET', ...
        [modelName '/MOSFET'], ...
        'Position', [250, 200, 290, 240]);
    set_param([modelName '/MOSFET'], 'Ron', num2str(Ron));
    set_param([modelName '/MOSFET'], 'Vf', '0.5');

    % Inductor (using Series RLC Branch)
    add_block('powerlib/Elements/Series RLC Branch', ...
        [modelName '/Inductor'], ...
        'Position', [150, 100, 180, 130]);
    set_param([modelName '/Inductor'], 'BranchType', 'RLC');
    set_param([modelName '/Inductor'], 'Resistance', num2str(RL));
    set_param([modelName '/Inductor'], 'Inductance', num2str(L_standard));
    set_param([modelName '/Inductor'], 'Capacitance', 'inf');

    % Diode
    add_block('powerlib/Power Electronics/Diode', ...
        [modelName '/Diode'], ...
        'Position', [350, 100, 380, 130]);
    set_param([modelName '/Diode'], 'Ron', num2str(Rf));
    set_param([modelName '/Diode'], 'Vf', num2str(Vf));

    % Output Capacitor
    add_block('powerlib/Elements/Series RLC Branch', ...
        [modelName '/Output_Cap'], ...
        'Position', [450, 100, 480, 130]);
    set_param([modelName '/Output_Cap'], 'BranchType', 'RLC');
    set_param([modelName '/Output_Cap'], 'Resistance', num2str(ESR));
    set_param([modelName '/Output_Cap'], 'Inductance', '0');
    set_param([modelName '/Output_Cap'], 'Capacitance', num2str(C_standard));

    % Load Resistor
    add_block('powerlib/Elements/Series RLC Branch', ...
        [modelName '/Load'], ...
        'Position', [550, 100, 580, 130]);
    set_param([modelName '/Load'], 'BranchType', 'RLC');
    set_param([modelName '/Load'], 'Resistance', num2str(Rload));
    set_param([modelName '/Load'], 'Inductance', '0');
    set_param([modelName '/Load'], 'Capacitance', 'inf');

    % Ground blocks
    add_block('powerlib/Connectors/Ground', ...
        [modelName '/Ground1'], ...
        'Position', [50, 250, 80, 280]);

    add_block('powerlib/Connectors/Ground', ...
        [modelName '/Ground2'], ...
        'Position', [250, 250, 280, 280]);

    add_block('powerlib/Connectors/Ground', ...
        [modelName '/Ground3'], ...
        'Position', [550, 250, 580, 280]);

    fprintf('Power components added successfully!\n');

catch ME
    fprintf('Error adding power components: %s\n', ME.message);
    fprintf('Please ensure Simscape Electrical toolbox is installed.\n');
    fprintf('Alternatively, use the manual instructions in the documentation.\n');
    save_system(modelName);
    return;
end

%% ADD CONTROL BLOCKS

fprintf('Adding control components...\n');

% Pulse Generator for PWM
add_block('simulink/Sources/Pulse Generator', ...
    [modelName '/PWM_Generator'], ...
    'Position', [50, 300, 100, 340]);
set_param([modelName '/PWM_Generator'], 'Amplitude', '1');
set_param([modelName '/PWM_Generator'], 'Period', num2str(1/fs));
set_param([modelName '/PWM_Generator'], 'PulseWidth', num2str(D*100));
set_param([modelName '/PWM_Generator'], 'PhaseDelay', '0');

%% ADD MEASUREMENT BLOCKS

fprintf('Adding measurement instruments...\n');

% Voltage Measurement for Output
add_block('powerlib/Measurements/Voltage Measurement', ...
    [modelName '/Vout_Measure'], ...
    'Position', [480, 180, 510, 210]);

% Current Measurement for Inductor
add_block('powerlib/Measurements/Current Measurement', ...
    [modelName '/IL_Measure'], ...
    'Position', [200, 100, 230, 130]);

% Voltage Measurement for Input
add_block('powerlib/Measurements/Voltage Measurement', ...
    [modelName '/Vin_Measure'], ...
    'Position', [100, 180, 130, 210]);

%% ADD DISPLAY AND SCOPE BLOCKS

fprintf('Adding display and scope blocks...\n');

% Scope for Output Voltage
add_block('simulink/Sinks/Scope', ...
    [modelName '/Vout_Scope'], ...
    'Position', [600, 180, 650, 220]);

% Scope for Inductor Current
add_block('simulink/Sinks/Scope', ...
    [modelName '/IL_Scope'], ...
    'Position', [600, 250, 650, 290]);

% Scope for Gate Signal
add_block('simulink/Sinks/Scope', ...
    [modelName '/Gate_Scope'], ...
    'Position', [600, 320, 650, 360]);

% Display blocks
add_block('simulink/Sinks/Display', ...
    [modelName '/Vout_Display'], ...
    'Position', [700, 180, 760, 210]);

add_block('simulink/Sinks/Display', ...
    [modelName '/IL_Display'], ...
    'Position', [700, 250, 760, 280]);

% To Workspace blocks for data export
add_block('simulink/Sinks/To Workspace', ...
    [modelName '/Vout_ToWS'], ...
    'Position', [700, 130, 760, 160]);
set_param([modelName '/Vout_ToWS'], 'VariableName', 'Vout_data');
set_param([modelName '/Vout_ToWS'], 'SaveFormat', 'Timeseries');

add_block('simulink/Sinks/To Workspace', ...
    [modelName '/IL_ToWS'], ...
    'Position', [700, 90, 760, 120]);
set_param([modelName '/IL_ToWS'], 'VariableName', 'IL_data');
set_param([modelName '/IL_ToWS'], 'SaveFormat', 'Timeseries');

%% MAKE CONNECTIONS

fprintf('Connecting blocks...\n');

try
    % Power circuit connections would go here
    % Note: Automatic connection of power blocks is complex and may require
    % manual adjustment in Simulink GUI

    % Connect PWM to Gate
    add_line(modelName, 'PWM_Generator/1', 'MOSFET/1', 'autorouting', 'on');

    % Connect measurements to scopes
    add_line(modelName, 'Vout_Measure/1', 'Vout_Scope/1', 'autorouting', 'on');
    add_line(modelName, 'IL_Measure/1', 'IL_Scope/1', 'autorouting', 'on');
    add_line(modelName, 'PWM_Generator/1', 'Gate_Scope/1', 'autorouting', 'on');

    % Connect to displays
    add_line(modelName, 'Vout_Measure/1', 'Vout_Display/1', 'autorouting', 'on');
    add_line(modelName, 'IL_Measure/1', 'IL_Display/1', 'autorouting', 'on');

    % Connect to workspace
    add_line(modelName, 'Vout_Measure/1', 'Vout_ToWS/1', 'autorouting', 'on');
    add_line(modelName, 'IL_Measure/1', 'IL_ToWS/1', 'autorouting', 'on');

    fprintf('Signal connections completed!\n');

catch ME
    fprintf('Note: Some connections may need manual adjustment\n');
    fprintf('Error: %s\n', ME.message);
end

%% SAVE MODEL

save_system(modelName);
fprintf('\nModel saved successfully: %s.slx\n', modelName);

%% GENERATE MANUAL INSTRUCTIONS

fprintf('\n============================================\n');
fprintf('MANUAL CONNECTION INSTRUCTIONS\n');
fprintf('============================================\n');
fprintf('The power circuit requires manual connections:\n\n');
fprintf('1. DC Source (+) -> Inductor port 1\n');
fprintf('2. Inductor port 2 -> Switching Node (create junction)\n');
fprintf('3. Switching Node -> MOSFET Drain (D)\n');
fprintf('4. Switching Node -> Diode Cathode (K)\n');
fprintf('5. MOSFET Source (S) -> Ground2\n');
fprintf('6. MOSFET Gate (G) <- PWM_Generator\n');
fprintf('7. Diode Anode (A) -> DC Source (-)\n');
fprintf('8. Diode Cathode (K) -> Output_Cap port 1\n');
fprintf('9. Output_Cap port 2 -> Ground3\n');
fprintf('10. Output_Cap port 1 -> Load port 1\n');
fprintf('11. Load port 2 -> Ground3\n');
fprintf('12. DC Source (-) -> Ground1\n\n');

fprintf('Current Measurement:\n');
fprintf('- Insert IL_Measure between Inductor and Switching Node\n\n');

fprintf('Voltage Measurements:\n');
fprintf('- Connect Vout_Measure across Load\n');
fprintf('- Connect Vin_Measure across DC Source\n\n');

fprintf('============================================\n\n');

%% PRINT COMPLETION MESSAGE

fprintf('Buck-Boost Converter model created successfully!\n\n');
fprintf('Next steps:\n');
fprintf('1. Open the model: open_system(''%s'')\n', modelName);
fprintf('2. Complete manual power connections as listed above\n');
fprintf('3. Click "Run" button to simulate\n');
fprintf('4. View waveforms in Scope blocks\n');
fprintf('5. Run "analyze_results.m" after simulation\n\n');

fprintf('To run simulation from command line:\n');
fprintf('  sim(''%s'');\n\n', modelName);

%% CREATE ALTERNATIVE SCRIPT-BASED MODEL

fprintf('Creating alternative script-based simulation...\n');

% Create a simplified averaged model using MATLAB code
% This serves as backup if Simulink blocks have issues

fid = fopen('buck_boost_simulation.m', 'w');
fprintf(fid, '%% BUCK-BOOST CONVERTER AVERAGED MODEL SIMULATION\n');
fprintf(fid, '%% Simplified state-space model for verification\n\n');
fprintf(fid, 'clear all; close all; clc;\n\n');
fprintf(fid, 'load(''buck_boost_parameters.mat'');\n\n');
fprintf(fid, '%% Time vector\n');
fprintf(fid, 'Ts = 1/(fs*100); %% Sample time\n');
fprintf(fid, 't = 0:Ts:0.01; %% 10ms simulation\n\n');
fprintf(fid, '%% State-space averaged model\n');
fprintf(fid, '%% States: [iL; vC]\n');
fprintf(fid, 'L = L_standard;\n');
fprintf(fid, 'C = C_standard;\n');
fprintf(fid, 'R = Rload;\n\n');
fprintf(fid, '%% Matrices for switched model\n');
fprintf(fid, 'A_on = [0, 0; 0, -1/(R*C)];\n');
fprintf(fid, 'B_on = [1/L; 0];\n');
fprintf(fid, 'A_off = [0, -1/L; 1/C, -1/(R*C)];\n');
fprintf(fid, 'B_off = [0; 0];\n\n');
fprintf(fid, '%% Averaged model: A = D*A_on + (1-D)*A_off\n');
fprintf(fid, 'A_avg = D*A_on + (1-D)*A_off;\n');
fprintf(fid, 'B_avg = D*B_on + (1-D)*B_off;\n');
fprintf(fid, 'C_avg = [0, 1]; %% Output is capacitor voltage\n');
fprintf(fid, 'D_avg = 0;\n\n');
fprintf(fid, '%% Create state-space system\n');
fprintf(fid, 'sys = ss(A_avg, B_avg, C_avg, D_avg);\n\n');
fprintf(fid, '%% Simulate\n');
fprintf(fid, 'u = Vin * ones(size(t)); %% Input voltage\n');
fprintf(fid, '[y, t_out, x] = lsim(sys, u, t);\n\n');
fprintf(fid, '%% Extract states\n');
fprintf(fid, 'iL = x(:,1);\n');
fprintf(fid, 'vC = x(:,2);\n\n');
fprintf(fid, '%% Plot results\n');
fprintf(fid, 'figure(''Name'', ''Buck-Boost Averaged Model'');\n');
fprintf(fid, 'subplot(2,1,1);\n');
fprintf(fid, 'plot(t*1000, vC);\n');
fprintf(fid, 'xlabel(''Time (ms)''); ylabel(''Output Voltage (V)'');\n');
fprintf(fid, 'title(''Output Voltage'');\n');
fprintf(fid, 'grid on;\n\n');
fprintf(fid, 'subplot(2,1,2);\n');
fprintf(fid, 'plot(t*1000, iL);\n');
fprintf(fid, 'xlabel(''Time (ms)''); ylabel(''Inductor Current (A)'');\n');
fprintf(fid, 'title(''Inductor Current'');\n');
fprintf(fid, 'grid on;\n\n');
fprintf(fid, 'fprintf(''Steady-state Output Voltage: %%.3f V\\n'', vC(end));\n');
fprintf(fid, 'fprintf(''Steady-state Inductor Current: %%.3f A\\n'', iL(end));\n');
fclose(fid);

fprintf('Created: buck_boost_simulation.m (averaged model)\n\n');

fprintf('============================================\n');
fprintf('ALL FILES CREATED SUCCESSFULLY!\n');
fprintf('============================================\n');
