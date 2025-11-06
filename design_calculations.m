% BUCK-BOOST CONVERTER DESIGN CALCULATIONS
% This script calculates all necessary parameters for buck-boost converter design
% Author: Auto-generated
% Date: November 2025

clear all;
close all;
clc;

fprintf('============================================\n');
fprintf('BUCK-BOOST CONVERTER DESIGN CALCULATIONS\n');
fprintf('============================================\n\n');

%% DESIGN SPECIFICATIONS
Vin = 24;           % Input voltage (V)
Vout = -12;         % Output voltage (V) - negative for inverting buck-boost
Pout = 50;          % Output power (W)
fs = 40000;         % Switching frequency (Hz)
Vripple_percent = 1; % Output voltage ripple (%)
Iripple_percent = 10; % Inductor current ripple (%)

%% BASIC CALCULATIONS
% Duty cycle calculation
D = abs(Vout)/(Vin + abs(Vout));
fprintf('OPERATING POINT:\n');
fprintf('  Duty Cycle (D): %.4f (%.2f%%)\n', D, D*100);

% Load resistance
Rload = abs(Vout)^2/Pout;
fprintf('  Load Resistance: %.2f Ohm\n', Rload);

% Output current
Iout = Pout/abs(Vout);
fprintf('  Output Current: %.3f A\n', Iout);

% Average inductor current
IL_avg = Iout/(1-D);
fprintf('  Average Inductor Current: %.3f A\n', IL_avg);

% Input current (average)
Iin_avg = Pout/Vin * 1.1; % 10% efficiency loss assumed
fprintf('  Average Input Current: %.3f A\n', Iin_avg);

%% COMPONENT DESIGN

% Inductor design
% Formula: L = (Vin * D) / (delta_IL * fs)
delta_IL = IL_avg * (Iripple_percent/100);
L = (Vin * D) / (delta_IL * fs);
L_standard = 320e-6; % Standard value 320 uH

fprintf('\nINDUCTOR DESIGN:\n');
fprintf('  Calculated Inductance: %.2f uH\n', L*1e6);
fprintf('  Standard Value Used: %.0f uH\n', L_standard*1e6);
fprintf('  Peak Current: %.3f A\n', IL_avg + delta_IL/2);
fprintf('  RMS Current: %.3f A\n', IL_avg);

% Recalculate actual ripple with standard inductor
delta_IL_actual = (Vin * D) / (L_standard * fs);
Iripple_actual = (delta_IL_actual/IL_avg) * 100;
fprintf('  Actual Current Ripple: %.2f%%\n', Iripple_actual);

% Output capacitor design
% Formula: C = (Iout * D) / (delta_Vout * fs)
delta_Vout = abs(Vout) * (Vripple_percent/100);
C = (Iout * D) / (delta_Vout * fs);
C_standard = 330e-6; % Standard value 330 uF

fprintf('\nOUTPUT CAPACITOR DESIGN:\n');
fprintf('  Calculated Capacitance: %.2f uF\n', C*1e6);
fprintf('  Standard Value Used: %.0f uF\n', C_standard*1e6);
fprintf('  Voltage Rating Required: %.0f V (use %.0f V)\n', abs(Vout)*1.5, ceil(abs(Vout)*1.5/5)*5);
fprintf('  RMS Current: %.3f A\n', delta_IL_actual/sqrt(12));

% Recalculate actual voltage ripple with standard capacitor
delta_Vout_actual = (Iout * D) / (C_standard * fs);
Vripple_actual = (delta_Vout_actual/abs(Vout)) * 100;
fprintf('  Actual Voltage Ripple: %.2f%%\n', Vripple_actual);

% ESR consideration
ESR = 0.01; % Typical ESR in Ohms
Vripple_ESR = delta_IL_actual * ESR;
Vripple_total = delta_Vout_actual + Vripple_ESR;
fprintf('  Ripple due to ESR: %.0f mV\n', Vripple_ESR*1000);
fprintf('  Total Output Ripple: %.0f mV\n', Vripple_total*1000);

%% SWITCH SPECIFICATIONS

fprintf('\nMOSFET SWITCH SPECIFICATIONS:\n');
Vds_max = Vin + abs(Vout);
fprintf('  Maximum Drain-Source Voltage: %.1f V\n', Vds_max);
fprintf('  Voltage Rating Required: %.0f V (use %.0f V MOSFET)\n', Vds_max*1.5, ceil(Vds_max*1.5/10)*10);
fprintf('  Maximum Drain Current: %.3f A\n', IL_avg + delta_IL_actual/2);
fprintf('  RMS Current: %.3f A\n', IL_avg * sqrt(D));
fprintf('  ON-time: %.2f us\n', D/fs * 1e6);
fprintf('  OFF-time: %.2f us\n', (1-D)/fs * 1e6);
fprintf('  Switching Period: %.2f us\n', 1/fs * 1e6);

% Switch power loss estimation
Ron = 0.01; % MOSFET on-resistance
P_cond_switch = (IL_avg * sqrt(D))^2 * Ron;
E_sw = 1e-6; % Switching energy per transition (typical value in Joules)
P_sw = E_sw * fs;
P_total_switch = P_cond_switch + P_sw;
fprintf('  Conduction Loss: %.3f W\n', P_cond_switch);
fprintf('  Switching Loss: %.3f W (estimated)\n', P_sw);
fprintf('  Total Switch Loss: %.3f W\n', P_total_switch);

%% DIODE SPECIFICATIONS

fprintf('\nDIODE SPECIFICATIONS:\n');
fprintf('  Maximum Reverse Voltage: %.1f V\n', Vds_max);
fprintf('  Voltage Rating Required: %.0f V\n', ceil(Vds_max*1.5/10)*10);
fprintf('  Average Forward Current: %.3f A\n', Iout);
fprintf('  Peak Forward Current: %.3f A\n', IL_avg + delta_IL_actual/2);
fprintf('  RMS Current: %.3f A\n', IL_avg * sqrt(1-D));

% Diode power loss
Vf = 0.5; % Forward voltage drop
Rf = 0.01; % Diode forward resistance
P_diode = Vf * Iout + (IL_avg * sqrt(1-D))^2 * Rf;
fprintf('  Power Dissipation: %.3f W\n', P_diode);

%% EFFICIENCY CALCULATION

fprintf('\nEFFICIENCY ANALYSIS:\n');
% Inductor loss
RL = 0.05; % Inductor DC resistance
P_inductor = IL_avg^2 * RL;
fprintf('  Inductor Loss: %.3f W\n', P_inductor);

% Capacitor loss
P_capacitor = (delta_IL_actual/sqrt(12))^2 * ESR;
fprintf('  Capacitor Loss: %.3f W\n', P_capacitor);

% Total losses
P_loss_total = P_total_switch + P_diode + P_inductor + P_capacitor;
fprintf('  Total Power Loss: %.3f W\n', P_loss_total);

% Input power and efficiency
Pin = Pout + P_loss_total;
efficiency = (Pout/Pin) * 100;
fprintf('  Input Power: %.3f W\n', Pin);
fprintf('  Efficiency: %.2f%%\n', efficiency);

%% CONDUCTION MODE ANALYSIS

fprintf('\nCONDUCTION MODE ANALYSIS:\n');
% Critical inductance for CCM/DCM boundary
Lcrit = (Vin * D * (1-D)^2 * Rload) / (2 * fs * Pout / abs(Vout)^2);
fprintf('  Critical Inductance (Lcrit): %.2f uH\n', Lcrit*1e6);
fprintf('  Actual Inductance: %.0f uH\n', L_standard*1e6);

if L_standard > Lcrit
    fprintf('  Operating Mode: CONTINUOUS CONDUCTION MODE (CCM)\n');
else
    fprintf('  Operating Mode: DISCONTINUOUS CONDUCTION MODE (DCM)\n');
end

% Minimum load for CCM
Rload_min = (2 * L_standard * fs) / (1-D)^2;
Pout_min = abs(Vout)^2 / Rload_min;
fprintf('  Minimum Load for CCM: %.2f Ohm (%.2f W)\n', Rload_min, Pout_min);

%% CONTROL PARAMETERS

fprintf('\nCONTROL SYSTEM PARAMETERS:\n');
% PWM ramp amplitude
Vramp = 5; % Typical PWM ramp amplitude in volts
fprintf('  PWM Ramp Amplitude: %.1f V\n', Vramp);

% Voltage feedback divider
R1 = 10000; % 10k ohms
R2 = R1 * abs(Vout) / (15 - abs(Vout)); % Scale to 15V reference
fprintf('  Feedback Divider R1: %.0f Ohm\n', R1);
fprintf('  Feedback Divider R2: %.0f Ohm\n', R2);

% Control loop parameters (suggested starting values)
fprintf('  Suggested PI Controller:\n');
fprintf('    Proportional Gain (Kp): 0.1\n');
fprintf('    Integral Gain (Ki): 100\n');
fprintf('    Derivative Gain (Kd): 0\n');

%% SAVE PARAMETERS FOR SIMULATION

% Save all parameters to a MAT file for use in Simulink
save('buck_boost_parameters.mat', 'Vin', 'Vout', 'Pout', 'fs', 'D', 'Rload', ...
     'L_standard', 'C_standard', 'Ron', 'Vf', 'Rf', 'RL', 'ESR', ...
     'IL_avg', 'Iout', 'delta_IL_actual');

fprintf('\n============================================\n');
fprintf('Parameters saved to: buck_boost_parameters.mat\n');
fprintf('============================================\n\n');

%% COMPONENT VALUES SUMMARY

fprintf('COMPONENT VALUES SUMMARY FOR SIMULINK:\n');
fprintf('======================================\n');
fprintf('DC Voltage Source:\n');
fprintf('  Voltage = %.0f V\n\n', Vin);

fprintf('MOSFET:\n');
fprintf('  Ron = %.3f Ohm\n', Ron);
fprintf('  Forward voltage Vf = %.1f V\n', 0.5);
fprintf('  Snubber resistance = 1e5 Ohm\n');
fprintf('  Snubber capacitance = inf\n\n');

fprintf('Inductor (Series RLC Branch):\n');
fprintf('  Resistance R = %.3f Ohm\n', RL);
fprintf('  Inductance L = %.0fe-6 H (%.0f uH)\n', L_standard*1e6, L_standard*1e6);
fprintf('  Capacitance C = inf\n\n');

fprintf('Diode:\n');
fprintf('  Resistance Ron = %.3f Ohm\n', Rf);
fprintf('  Forward voltage Vf = %.1f V\n', Vf);
fprintf('  Snubber resistance = 1e5 Ohm\n');
fprintf('  Snubber capacitance = inf\n\n');

fprintf('Output Capacitor (Series RLC Branch):\n');
fprintf('  Resistance R = %.3f Ohm (ESR)\n', ESR);
fprintf('  Inductance L = 0 H\n');
fprintf('  Capacitance C = %.0fe-6 F (%.0f uF)\n\n', C_standard*1e6, C_standard*1e6);

fprintf('Load Resistor (Series RLC Branch):\n');
fprintf('  Resistance R = %.2f Ohm\n', Rload);
fprintf('  Inductance L = 0 H\n');
fprintf('  Capacitance C = inf\n\n');

fprintf('PWM Generator:\n');
fprintf('  Frequency = %.0f Hz\n', fs);
fprintf('  Duty cycle = %.4f (%.2f%%)\n', D, D*100);
fprintf('  Period = %.2f us\n', 1/fs * 1e6);
fprintf('  ON time = %.2f us\n', D/fs * 1e6);
fprintf('======================================\n\n');

%% GENERATE DESIGN REPORT

fprintf('Design calculations complete!\n');
fprintf('Next steps:\n');
fprintf('1. Open Simulink: type "simulink" in command window\n');
fprintf('2. Run "create_buck_boost_model.m" to build the model\n');
fprintf('3. Or manually build the circuit using values above\n');
fprintf('4. Run simulation and use "analyze_results.m" for analysis\n');
