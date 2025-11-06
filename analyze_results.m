% ANALYZE BUCK-BOOST CONVERTER SIMULATION RESULTS
% This script analyzes and visualizes the simulation results
% Author: Auto-generated
% Date: November 2025

close all;
clc;

fprintf('============================================\n');
fprintf('BUCK-BOOST CONVERTER RESULTS ANALYSIS\n');
fprintf('============================================\n\n');

%% CHECK IF SIMULATION DATA EXISTS
if ~exist('Vout_data', 'var') || ~exist('IL_data', 'var')
    fprintf('ERROR: Simulation data not found in workspace!\n');
    fprintf('Please run the Simulink model first:\n');
    fprintf('  1. Open model: open_system(''BuckBoost_Converter'')\n');
    fprintf('  2. Run simulation: sim(''BuckBoost_Converter'')\n');
    fprintf('  3. Then run this script again\n\n');
    return;
end

%% LOAD DESIGN PARAMETERS
if exist('buck_boost_parameters.mat', 'file')
    load('buck_boost_parameters.mat');
else
    fprintf('Warning: Design parameters not found. Using default values.\n');
    Vin = 24;
    Vout = -12;
    fs = 40000;
    D = 0.3333;
end

%% EXTRACT TIME SERIES DATA

% Extract output voltage data
if isa(Vout_data, 'timeseries')
    t_vout = Vout_data.Time;
    v_out = Vout_data.Data;
else
    t_vout = Vout_data(:,1);
    v_out = Vout_data(:,2);
end

% Extract inductor current data
if isa(IL_data, 'timeseries')
    t_il = IL_data.Time;
    i_L = IL_data.Data;
else
    t_il = IL_data(:,1);
    i_L = IL_data(:,2);
end

fprintf('Data loaded successfully!\n');
fprintf('  Output voltage samples: %d\n', length(v_out));
fprintf('  Inductor current samples: %d\n', length(i_L));
fprintf('  Simulation time: %.3f ms\n\n', max(t_vout)*1000);

%% CALCULATE STEADY-STATE VALUES

% Consider last 20% of simulation for steady-state analysis
steady_start = round(0.8 * length(v_out));

v_out_ss = v_out(steady_start:end);
i_L_ss = i_L(steady_start:end);
t_ss = t_vout(steady_start:end);

% Calculate statistics
Vout_avg = mean(v_out_ss);
Vout_rms = rms(v_out_ss);
Vout_max = max(v_out_ss);
Vout_min = min(v_out_ss);
Vout_ripple = Vout_max - Vout_min;
Vout_ripple_percent = (Vout_ripple / abs(Vout_avg)) * 100;

IL_avg = mean(i_L_ss);
IL_rms = rms(i_L_ss);
IL_max = max(i_L_ss);
IL_min = min(i_L_ss);
IL_ripple = IL_max - IL_min;
IL_ripple_percent = (IL_ripple / IL_avg) * 100;

fprintf('STEADY-STATE ANALYSIS:\n');
fprintf('======================\n\n');

fprintf('Output Voltage:\n');
fprintf('  Average: %.3f V (Expected: %.1f V)\n', Vout_avg, Vout);
fprintf('  RMS: %.3f V\n', Vout_rms);
fprintf('  Maximum: %.3f V\n', Vout_max);
fprintf('  Minimum: %.3f V\n', Vout_min);
fprintf('  Peak-to-Peak Ripple: %.3f mV\n', Vout_ripple*1000);
fprintf('  Ripple Percentage: %.2f%%\n', Vout_ripple_percent);
fprintf('  Error from Expected: %.2f%%\n\n', abs((Vout_avg - Vout)/Vout)*100);

fprintf('Inductor Current:\n');
fprintf('  Average: %.3f A (Expected: %.3f A)\n', IL_avg, IL_avg);
fprintf('  RMS: %.3f A\n', IL_rms);
fprintf('  Maximum: %.3f A\n', IL_max);
fprintf('  Minimum: %.3f A\n', IL_min);
fprintf('  Peak-to-Peak Ripple: %.3f A\n', IL_ripple);
fprintf('  Ripple Percentage: %.2f%%\n\n', IL_ripple_percent);

% Check for DCM (Discontinuous Conduction Mode)
if IL_min <= 0
    fprintf('  WARNING: Operating in DCM (Current touches zero)\n\n');
else
    fprintf('  Operating Mode: CCM (Continuous Conduction Mode)\n\n');
end

%% CALCULATE OUTPUT POWER AND EFFICIENCY

Pout_actual = abs(Vout_avg)^2 / Rload;
Iout_actual = abs(Vout_avg) / Rload;

fprintf('Power Analysis:\n');
fprintf('  Output Power: %.3f W\n', Pout_actual);
fprintf('  Output Current: %.3f A\n', Iout_actual);

% Estimate losses (simplified)
if exist('Ron', 'var') && exist('Rf', 'var')
    P_switch = IL_rms^2 * Ron * D;
    P_diode = Vf * Iout_actual + IL_rms^2 * Rf * (1-D);
    P_inductor = IL_rms^2 * RL;
    P_capacitor = ((IL_ripple/sqrt(12))^2) * ESR;

    P_loss_total = P_switch + P_diode + P_inductor + P_capacitor;
    Pin_estimated = Pout_actual + P_loss_total;
    efficiency = (Pout_actual / Pin_estimated) * 100;

    fprintf('  Estimated Losses: %.3f W\n', P_loss_total);
    fprintf('  Estimated Input Power: %.3f W\n', Pin_estimated);
    fprintf('  Estimated Efficiency: %.2f%%\n\n', efficiency);
end

%% FREQUENCY ANALYSIS

fprintf('FREQUENCY ANALYSIS:\n');
fprintf('===================\n\n');

% FFT of output voltage
Fs = 1/mean(diff(t_ss));  % Sampling frequency
N = length(v_out_ss);
f = Fs*(0:(N/2))/N;
Y = fft(v_out_ss);
P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% Find dominant frequencies
[peaks, locs] = findpeaks(P1, 'MinPeakHeight', max(P1)*0.01, 'NPeaks', 5);
dominant_freqs = f(locs);

fprintf('Output Voltage Spectrum:\n');
fprintf('  Sampling Frequency: %.0f Hz\n', Fs);
fprintf('  Expected Ripple Frequency: %.0f Hz (switching frequency)\n', fs);

if ~isempty(dominant_freqs)
    fprintf('  Dominant Frequencies:\n');
    for i = 1:length(dominant_freqs)
        fprintf('    %.0f Hz (%.3f V)\n', dominant_freqs(i), peaks(i));
    end
end
fprintf('\n');

%% SETTLING TIME ANALYSIS

fprintf('TRANSIENT ANALYSIS:\n');
fprintf('===================\n\n');

% Find settling time (time to reach within 2% of final value)
target = Vout_avg;
tolerance = 0.02 * abs(target);

settled_idx = find(abs(v_out - target) <= tolerance, 1, 'first');
if ~isempty(settled_idx)
    settling_time = t_vout(settled_idx);
    fprintf('Settling Time (2%% band): %.3f ms\n', settling_time*1000);
else
    fprintf('Settling Time: Not reached within simulation time\n');
end

% Find overshoot
if Vout < 0
    overshoot = abs(min(v_out) - Vout_avg);
else
    overshoot = abs(max(v_out) - Vout_avg);
end
overshoot_percent = (overshoot / abs(Vout_avg)) * 100;

fprintf('Overshoot: %.3f V (%.2f%%)\n\n', overshoot, overshoot_percent);

%% GENERATE COMPREHENSIVE PLOTS

fprintf('Generating plots...\n');

% Figure 1: Overview
fig1 = figure('Name', 'Buck-Boost Converter - Overview', 'Position', [100, 100, 1200, 800]);

% Output Voltage
subplot(3,2,1);
plot(t_vout*1000, v_out, 'b', 'LineWidth', 1.5);
hold on;
yline(Vout, 'r--', 'Target', 'LineWidth', 1.5);
yline(Vout_avg, 'g--', 'Actual Avg', 'LineWidth', 1.5);
xlabel('Time (ms)');
ylabel('Voltage (V)');
title('Output Voltage vs Time');
grid on;
legend('Vout', 'Target', 'Average', 'Location', 'best');

% Output Voltage - Steady State Zoom
subplot(3,2,2);
t_zoom_start = max(t_vout) - 1e-3; % Last 1ms
idx_zoom = t_vout >= t_zoom_start;
plot(t_vout(idx_zoom)*1000, v_out(idx_zoom), 'b', 'LineWidth', 1.5);
xlabel('Time (ms)');
ylabel('Voltage (V)');
title('Output Voltage - Steady State Detail (Last 1ms)');
grid on;

% Inductor Current
subplot(3,2,3);
plot(t_il*1000, i_L, 'r', 'LineWidth', 1.5);
hold on;
yline(IL_avg, 'g--', 'Average', 'LineWidth', 1.5);
yline(0, 'k--', 'LineWidth', 0.5);
xlabel('Time (ms)');
ylabel('Current (A)');
title('Inductor Current vs Time');
grid on;
legend('iL', 'Average', 'Location', 'best');

% Inductor Current - Steady State Zoom
subplot(3,2,4);
plot(t_il(idx_zoom)*1000, i_L(idx_zoom), 'r', 'LineWidth', 1.5);
xlabel('Time (ms)');
ylabel('Current (A)');
title('Inductor Current - Steady State Detail (Last 1ms)');
grid on;

% Output Voltage Histogram
subplot(3,2,5);
histogram(v_out_ss, 50, 'FaceColor', 'b', 'EdgeColor', 'none');
xlabel('Voltage (V)');
ylabel('Count');
title('Output Voltage Distribution (Steady State)');
grid on;

% Frequency Spectrum
subplot(3,2,6);
plot(f/1000, P1, 'LineWidth', 1.5);
xlabel('Frequency (kHz)');
ylabel('Magnitude (V)');
title('Output Voltage Frequency Spectrum');
xlim([0, 200]); % Show up to 200 kHz
grid on;

% Figure 2: Performance Metrics
fig2 = figure('Name', 'Performance Metrics', 'Position', [150, 150, 1000, 600]);

% Ripple Analysis
subplot(2,2,1);
plot(t_ss*1000, v_out_ss - Vout_avg, 'b', 'LineWidth', 1);
xlabel('Time (ms)');
ylabel('Ripple Voltage (V)');
title(sprintf('Output Voltage Ripple (%.2f mV p-p)', Vout_ripple*1000));
grid on;

subplot(2,2,2);
plot(t_ss*1000, i_L_ss - IL_avg, 'r', 'LineWidth', 1);
xlabel('Time (ms)');
ylabel('Ripple Current (A)');
title(sprintf('Inductor Current Ripple (%.3f A p-p)', IL_ripple));
grid on;

% Power Analysis
subplot(2,2,3);
bar([Pout_actual, P_loss_total, Pin_estimated]);
set(gca, 'XTickLabel', {'Output Power', 'Losses', 'Input Power'});
ylabel('Power (W)');
title('Power Distribution');
grid on;

% Summary Text
subplot(2,2,4);
axis off;
summary_text = {
    'SIMULATION SUMMARY';
    '==================';
    '';
    sprintf('Target Output: %.1f V', Vout);
    sprintf('Actual Output: %.3f V', Vout_avg);
    sprintf('Error: %.2f%%', abs((Vout_avg - Vout)/Vout)*100);
    '';
    sprintf('Voltage Ripple: %.1f mV', Vout_ripple*1000);
    sprintf('Current Ripple: %.3f A', IL_ripple);
    '';
    sprintf('Duty Cycle: %.2f%%', D*100);
    sprintf('Switching Freq: %.0f kHz', fs/1000);
    '';
    sprintf('Output Power: %.2f W', Pout_actual);
    sprintf('Efficiency: %.1f%%', efficiency);
};
text(0.1, 0.9, summary_text, 'VerticalAlignment', 'top', 'FontName', 'FixedWidth', 'FontSize', 10);

%% SAVE RESULTS

fprintf('Saving results...\n');

% Save figures
saveas(fig1, 'buck_boost_overview.png');
saveas(fig2, 'buck_boost_performance.png');
saveas(fig1, 'buck_boost_overview.fig');
saveas(fig2, 'buck_boost_performance.fig');

% Save analysis results to file
results_file = 'simulation_results.txt';
fid = fopen(results_file, 'w');
fprintf(fid, 'BUCK-BOOST CONVERTER SIMULATION RESULTS\n');
fprintf(fid, '========================================\n\n');
fprintf(fid, 'Date: %s\n\n', datestr(now));

fprintf(fid, 'DESIGN PARAMETERS:\n');
fprintf(fid, '  Input Voltage: %.1f V\n', Vin);
fprintf(fid, '  Target Output Voltage: %.1f V\n', Vout);
fprintf(fid, '  Duty Cycle: %.4f (%.2f%%)\n', D, D*100);
fprintf(fid, '  Switching Frequency: %.0f Hz\n', fs);
fprintf(fid, '  Load Resistance: %.2f Ohm\n\n', Rload);

fprintf(fid, 'SIMULATION RESULTS:\n');
fprintf(fid, '  Average Output Voltage: %.3f V\n', Vout_avg);
fprintf(fid, '  Output Voltage Ripple: %.3f mV (%.2f%%)\n', Vout_ripple*1000, Vout_ripple_percent);
fprintf(fid, '  Average Inductor Current: %.3f A\n', IL_avg);
fprintf(fid, '  Inductor Current Ripple: %.3f A (%.2f%%)\n', IL_ripple, IL_ripple_percent);
fprintf(fid, '  Output Power: %.3f W\n', Pout_actual);
fprintf(fid, '  Estimated Efficiency: %.2f%%\n\n', efficiency);

fprintf(fid, 'PERFORMANCE:\n');
fprintf(fid, '  Voltage Error: %.2f%%\n', abs((Vout_avg - Vout)/Vout)*100);
fprintf(fid, '  Settling Time: %.3f ms\n', settling_time*1000);
fprintf(fid, '  Overshoot: %.2f%%\n', overshoot_percent);
fprintf(fid, '  Conduction Mode: %s\n', ternary(IL_min > 0, 'CCM', 'DCM'));

fclose(fid);

fprintf('\nResults saved to:\n');
fprintf('  - %s\n', results_file);
fprintf('  - buck_boost_overview.png/fig\n');
fprintf('  - buck_boost_performance.png/fig\n\n');

%% COMPARISON WITH THEORY

fprintf('COMPARISON WITH THEORETICAL VALUES:\n');
fprintf('====================================\n\n');

% Theoretical values
Vout_theory = -Vin * D / (1-D);
IL_theory = abs(Vout_theory) / (Rload * (1-D));
delta_IL_theory = (Vin * D) / (L_standard * fs);
delta_Vout_theory = (abs(Vout_theory) * D) / (Rload * C_standard * fs);

fprintf('Output Voltage:\n');
fprintf('  Theoretical: %.3f V\n', Vout_theory);
fprintf('  Simulated: %.3f V\n', Vout_avg);
fprintf('  Difference: %.2f%%\n\n', abs((Vout_avg - Vout_theory)/Vout_theory)*100);

fprintf('Inductor Current (Average):\n');
fprintf('  Theoretical: %.3f A\n', IL_theory);
fprintf('  Simulated: %.3f A\n', IL_avg);
fprintf('  Difference: %.2f%%\n\n', abs((IL_avg - IL_theory)/IL_theory)*100);

fprintf('Inductor Current Ripple:\n');
fprintf('  Theoretical: %.3f A\n', delta_IL_theory);
fprintf('  Simulated: %.3f A\n', IL_ripple);
fprintf('  Difference: %.2f%%\n\n', abs((IL_ripple - delta_IL_theory)/delta_IL_theory)*100);

fprintf('Output Voltage Ripple:\n');
fprintf('  Theoretical: %.3f mV\n', delta_Vout_theory*1000);
fprintf('  Simulated: %.3f mV\n', Vout_ripple*1000);
fprintf('  Difference: %.2f%%\n\n', abs((Vout_ripple - delta_Vout_theory)/delta_Vout_theory)*100);

%% GENERATE LATEX TABLE (FOR REPORTS)

fprintf('Generating LaTeX table...\n');

latex_file = 'results_table.tex';
fid = fopen(latex_file, 'w');
fprintf(fid, '\\begin{table}[h]\n');
fprintf(fid, '\\centering\n');
fprintf(fid, '\\caption{Buck-Boost Converter Simulation Results}\n');
fprintf(fid, '\\begin{tabular}{|l|c|c|c|}\n');
fprintf(fid, '\\hline\n');
fprintf(fid, '\\textbf{Parameter} & \\textbf{Theoretical} & \\textbf{Simulated} & \\textbf{Error (\\%%)} \\\\\n');
fprintf(fid, '\\hline\n');
fprintf(fid, 'Output Voltage (V) & %.2f & %.2f & %.2f \\\\\n', Vout_theory, Vout_avg, abs((Vout_avg - Vout_theory)/Vout_theory)*100);
fprintf(fid, 'Inductor Current (A) & %.3f & %.3f & %.2f \\\\\n', IL_theory, IL_avg, abs((IL_avg - IL_theory)/IL_theory)*100);
fprintf(fid, 'Current Ripple (A) & %.3f & %.3f & %.2f \\\\\n', delta_IL_theory, IL_ripple, abs((IL_ripple - delta_IL_theory)/delta_IL_theory)*100);
fprintf(fid, 'Voltage Ripple (mV) & %.1f & %.1f & %.2f \\\\\n', delta_Vout_theory*1000, Vout_ripple*1000, abs((Vout_ripple - delta_Vout_theory)/delta_Vout_theory)*100);
fprintf(fid, '\\hline\n');
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\\label{tab:results}\n');
fprintf(fid, '\\end{table}\n');
fclose(fid);

fprintf('LaTeX table saved to: %s\n\n', latex_file);

fprintf('============================================\n');
fprintf('ANALYSIS COMPLETE!\n');
fprintf('============================================\n\n');

fprintf('All results have been saved and plotted.\n');
fprintf('Review the generated figures and text files.\n');

% Helper function for ternary operator
function result = ternary(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end
