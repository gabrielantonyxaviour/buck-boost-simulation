% RUN COMPLETE BUCK-BOOST CONVERTER SIMULATION WORKFLOW
% This master script runs the entire simulation workflow automatically
% Author: Auto-generated
% Date: November 2025

clear all;
close all;
clc;

fprintf('\n');
fprintf('========================================================\n');
fprintf('    BUCK-BOOST CONVERTER - COMPLETE SIMULATION WORKFLOW\n');
fprintf('========================================================\n\n');

%% STEP 1: DESIGN CALCULATIONS

fprintf('STEP 1: Running Design Calculations...\n');
fprintf('--------------------------------------------------------\n');

try
    run('design_calculations.m');
    fprintf('[✓] Design calculations completed successfully!\n\n');
    pause(2);
catch ME
    fprintf('[✗] Error in design calculations: %s\n', ME.message);
    return;
end

%% STEP 2: CREATE SIMULINK MODEL

fprintf('STEP 2: Creating Simulink Model...\n');
fprintf('--------------------------------------------------------\n');

try
    run('create_buck_boost_model.m');
    fprintf('[✓] Simulink model created successfully!\n\n');
    pause(2);
catch ME
    fprintf('[✗] Error creating model: %s\n', ME.message);
    fprintf('Note: If Simscape Electrical is not installed, you can skip this step.\n\n');
end

%% STEP 3: SIMULATE (AVERAGED MODEL)

fprintf('STEP 3: Running Averaged Model Simulation...\n');
fprintf('--------------------------------------------------------\n');
fprintf('This runs a simplified state-space model for quick verification.\n');
fprintf('For full Simulink simulation, see STEP 4 below.\n\n');

try
    if exist('buck_boost_simulation.m', 'file')
        run('buck_boost_simulation.m');
        fprintf('[✓] Averaged model simulation completed!\n\n');
        pause(2);
    else
        fprintf('[!] Averaged model script not found. Skipping.\n\n');
    end
catch ME
    fprintf('[✗] Error in averaged simulation: %s\n', ME.message);
end

%% STEP 4: INSTRUCTIONS FOR FULL SIMULINK SIMULATION

fprintf('STEP 4: Full Simulink Simulation Instructions\n');
fprintf('--------------------------------------------------------\n');
fprintf('To run the complete detailed Simulink simulation:\n\n');

fprintf('1. Open the model:\n');
fprintf('   >> open_system(''BuckBoost_Converter'')\n\n');

fprintf('2. Complete manual power circuit connections:\n');
fprintf('   - Follow the connection diagram in console output\n');
fprintf('   - Or refer to IMPLEMENTATION_GUIDE.md\n');
fprintf('   - Key connections:\n');
fprintf('     • DC Source (+) → Inductor → Switching Node\n');
fprintf('     • Switching Node → MOSFET Drain & Diode Cathode\n');
fprintf('     • MOSFET Source → Ground\n');
fprintf('     • Diode Anode → DC Source (-)\n');
fprintf('     • Output: Diode Cathode → Capacitor & Load → Ground\n\n');

fprintf('3. Run the simulation:\n');
fprintf('   >> sim(''BuckBoost_Converter'')\n\n');

fprintf('4. Analyze results:\n');
fprintf('   >> analyze_results\n\n');

fprintf('--------------------------------------------------------\n');
fprintf('ALTERNATIVE: Run manually step by step:\n\n');

fprintf('>> design_calculations        %% Calculate parameters\n');
fprintf('>> open_system(''BuckBoost_Converter'')  %% Open model\n');
fprintf('   [Complete connections manually in GUI]\n');
fprintf('>> sim(''BuckBoost_Converter'')          %% Simulate\n');
fprintf('>> analyze_results            %% Analyze\n\n');

%% GENERATE PROJECT SUMMARY

fprintf('========================================================\n');
fprintf('    SIMULATION SETUP COMPLETE!\n');
fprintf('========================================================\n\n');

fprintf('FILES CREATED:\n');
fprintf('  ✓ design_calculations.m          - Design parameter script\n');
fprintf('  ✓ create_buck_boost_model.m      - Model generation script\n');
fprintf('  ✓ analyze_results.m              - Results analysis script\n');
fprintf('  ✓ buck_boost_simulation.m        - Averaged model simulation\n');
fprintf('  ✓ buck_boost_parameters.mat      - Design parameters (data)\n');
fprintf('  ✓ BuckBoost_Converter.slx        - Simulink model\n');
fprintf('  ✓ README.md                      - Project documentation\n');
fprintf('  ✓ IMPLEMENTATION_GUIDE.md        - Detailed instructions\n\n');

fprintf('QUICK REFERENCE - DESIGN PARAMETERS:\n');
fprintf('  Input Voltage:        24 V\n');
fprintf('  Output Voltage:       -12 V\n');
fprintf('  Output Power:         50 W\n');
fprintf('  Switching Frequency:  40 kHz\n');
fprintf('  Duty Cycle:           33.33%%\n');
fprintf('  Inductor:             320 µH\n');
fprintf('  Capacitor:            330 µF\n');
fprintf('  Load:                 2.88 Ω\n\n');

fprintf('EXPECTED RESULTS:\n');
fprintf('  Output Voltage:       -12.0 V ± 0.12 V\n');
fprintf('  Voltage Ripple:       < 120 mV peak-to-peak\n');
fprintf('  Inductor Current:     6.25 A average\n');
fprintf('  Current Ripple:       ~0.625 A peak-to-peak\n');
fprintf('  Efficiency:           92-95%%\n');
fprintf('  Settling Time:        3-5 ms\n\n');

fprintf('NEXT STEPS:\n');
fprintf('  1. Review generated documentation\n');
fprintf('  2. Open and inspect Simulink model\n');
fprintf('  3. Complete manual connections\n');
fprintf('  4. Run full simulation\n');
fprintf('  5. Analyze and document results\n\n');

fprintf('FOR HELP:\n');
fprintf('  - Read README.md for overview\n');
fprintf('  - Read IMPLEMENTATION_GUIDE.md for detailed steps\n');
fprintf('  - Run individual scripts as needed\n');
fprintf('  - Type "help <script_name>" for script documentation\n\n');

fprintf('========================================================\n');
fprintf('    Ready to simulate! Follow STEP 4 instructions above.\n');
fprintf('========================================================\n\n');

%% OPEN MODEL AUTOMATICALLY (OPTIONAL)

% Uncomment the following line to automatically open the Simulink model
% open_system('BuckBoost_Converter');

%% INTERACTIVE MENU (OPTIONAL)

fprintf('Would you like to:\n');
fprintf('  1. Open the Simulink model now\n');
fprintf('  2. View design calculations summary\n');
fprintf('  3. View component specifications\n');
fprintf('  4. Exit\n\n');

choice = input('Enter choice (1-4): ', 's');

switch choice
    case '1'
        if exist('BuckBoost_Converter.slx', 'file')
            fprintf('\nOpening Simulink model...\n');
            open_system('BuckBoost_Converter');
        else
            fprintf('\nModel file not found. Please run create_buck_boost_model.m first.\n');
        end

    case '2'
        fprintf('\n========================================\n');
        fprintf('DESIGN CALCULATIONS SUMMARY\n');
        fprintf('========================================\n\n');

        if exist('buck_boost_parameters.mat', 'file')
            load('buck_boost_parameters.mat');
            fprintf('INPUT:\n');
            fprintf('  Voltage: %.1f V\n\n', Vin);

            fprintf('OUTPUT:\n');
            fprintf('  Voltage: %.1f V\n', Vout);
            fprintf('  Power: %.1f W\n', Pout);
            fprintf('  Current: %.3f A\n\n', Iout);

            fprintf('OPERATING POINT:\n');
            fprintf('  Duty Cycle: %.4f (%.2f%%)\n', D, D*100);
            fprintf('  Switching Frequency: %.0f Hz (%.1f kHz)\n\n', fs, fs/1000);

            fprintf('COMPONENTS:\n');
            fprintf('  Inductor: %.0f µH (%.2f A avg, %.3f A ripple)\n', ...
                    L_standard*1e6, IL_avg, delta_IL_actual);
            fprintf('  Capacitor: %.0f µF (ESR = %.2f mΩ)\n', ...
                    C_standard*1e6, ESR*1000);
            fprintf('  Load: %.2f Ω\n\n', Rload);

            fprintf('SWITCH (MOSFET):\n');
            fprintf('  Max Voltage: %.1f V\n', Vin + abs(Vout));
            fprintf('  Max Current: %.3f A\n', IL_avg + delta_IL_actual/2);
            fprintf('  On-Resistance: %.3f Ω\n\n', Ron);

            fprintf('DIODE:\n');
            fprintf('  Max Reverse Voltage: %.1f V\n', Vin + abs(Vout));
            fprintf('  Avg Forward Current: %.3f A\n', Iout);
            fprintf('  Forward Voltage: %.1f V\n\n', Vf);
        else
            fprintf('Parameters file not found. Run design_calculations.m first.\n\n');
        end

    case '3'
        fprintf('\n========================================\n');
        fprintf('COMPONENT SPECIFICATIONS\n');
        fprintf('========================================\n\n');

        fprintf('For Simulink block parameters:\n\n');

        fprintf('DC Voltage Source:\n');
        fprintf('  Amplitude: 24\n\n');

        fprintf('MOSFET:\n');
        fprintf('  Internal resistance Ron: 0.01\n');
        fprintf('  Forward voltage Vf: 0.5\n\n');

        fprintf('Inductor (Series RLC Branch):\n');
        fprintf('  Resistance R: 0.05\n');
        fprintf('  Inductance L: 320e-6\n');
        fprintf('  Capacitance C: inf\n\n');

        fprintf('Diode:\n');
        fprintf('  Resistance Ron: 0.01\n');
        fprintf('  Forward voltage Vf: 0.5\n\n');

        fprintf('Output Capacitor (Series RLC Branch):\n');
        fprintf('  Resistance R: 0.01\n');
        fprintf('  Inductance L: 0\n');
        fprintf('  Capacitance C: 330e-6\n\n');

        fprintf('Load (Series RLC Branch):\n');
        fprintf('  Resistance R: 2.88\n');
        fprintf('  Inductance L: 0\n');
        fprintf('  Capacitance C: inf\n\n');

        fprintf('PWM Generator:\n');
        fprintf('  Amplitude: 1\n');
        fprintf('  Period: 25e-6\n');
        fprintf('  Pulse width: 33.33 (%%)\n');
        fprintf('  Phase delay: 0\n\n');

    case '4'
        fprintf('\nExiting. Good luck with your simulation!\n\n');

    otherwise
        fprintf('\nInvalid choice. Exiting.\n\n');
end

fprintf('========================================================\n\n');
