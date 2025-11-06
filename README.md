# Buck-Boost Converter MATLAB/Simulink Simulation

Complete implementation and analysis of a buck-boost DC-DC converter using MATLAB and Simulink.

## Overview

This project provides a comprehensive buck-boost converter simulation with:
- Automatic design calculations
- Programmatic Simulink model generation
- Detailed results analysis and visualization
- Performance comparison with theoretical values

## Design Specifications

| Parameter | Value |
|-----------|-------|
| Input Voltage | 24 V |
| Output Voltage | -12 V (inverting) |
| Output Power | 50 W |
| Switching Frequency | 40 kHz |
| Duty Cycle | 33.33% |
| Load Resistance | 2.88 Ω |

## Component Values

| Component | Value |
|-----------|-------|
| Inductor (L) | 320 μH |
| Output Capacitor (C) | 330 μF |
| MOSFET Ron | 0.01 Ω |
| Diode Forward Voltage | 0.5 V |
| ESR (Capacitor) | 0.01 Ω |

## Prerequisites

- MATLAB R2017a or later
- Simulink
- Simscape Electrical (formerly SimPowerSystems)
- Control System Toolbox (optional, for advanced features)

## Quick Start

### Option 1: Automated Setup (Recommended)

```matlab
% Run complete workflow
design_calculations        % Calculate all parameters
create_buck_boost_model   % Create Simulink model
% Manually complete power connections in Simulink GUI
sim('BuckBoost_Converter')  % Run simulation
analyze_results           % Analyze and plot results
```

### Option 2: Manual Simulink Build

1. Follow the detailed instructions in `IMPLEMENTATION_GUIDE.md`
2. Use component values from design calculations
3. Build circuit step-by-step using Simulink blocks

### Option 3: Simplified State-Space Model

```matlab
design_calculations       % Generate parameters
buck_boost_simulation     % Run averaged model (no Simulink GUI needed)
```

## File Structure

```
buck-boost-simulation/
├── README.md                          # This file
├── IMPLEMENTATION_GUIDE.md            # Detailed implementation guide
├── design_calculations.m              # Design parameter calculations
├── create_buck_boost_model.m          # Automated model generator
├── analyze_results.m                  # Results analysis script
├── buck_boost_simulation.m            # Averaged model (generated)
├── BuckBoost_Converter.slx            # Simulink model (generated)
├── buck_boost_parameters.mat          # Design parameters (generated)
└── results/                           # Generated results (optional)
    ├── simulation_results.txt
    ├── buck_boost_overview.png
    ├── buck_boost_performance.png
    └── results_table.tex
```

## Detailed Usage

### Step 1: Design Calculations

```matlab
design_calculations
```

This script:
- Calculates duty cycle from voltage specifications
- Designs inductor and capacitor values
- Determines component ratings (voltage, current)
- Estimates losses and efficiency
- Checks for continuous conduction mode (CCM)
- Saves parameters to `buck_boost_parameters.mat`

**Output:**
```
BUCK-BOOST CONVERTER DESIGN CALCULATIONS
============================================

OPERATING POINT:
  Duty Cycle (D): 0.3333 (33.33%)
  Load Resistance: 2.88 Ohm
  Output Current: 4.167 A
  Average Inductor Current: 6.250 A
  ...
```

### Step 2: Create Simulink Model

```matlab
create_buck_boost_model
```

This script:
- Loads design parameters
- Creates new Simulink model programmatically
- Adds all power components (source, MOSFET, diode, inductor, capacitor, load)
- Adds control (PWM generator)
- Adds measurement and display blocks
- Configures solver settings
- Saves model as `BuckBoost_Converter.slx`

**Note:** Power circuit connections require manual completion in Simulink GUI due to the complexity of electrical connections. Follow the printed instructions.

### Step 3: Complete Manual Connections

Open the model in Simulink:
```matlab
open_system('BuckBoost_Converter')
```

Complete the power circuit connections as shown in the console output:

```
1. DC Source (+) -> Inductor port 1
2. Inductor port 2 -> Switching Node (create junction)
3. Switching Node -> MOSFET Drain (D)
4. Switching Node -> Diode Cathode (K)
5. MOSFET Source (S) -> Ground
...
```

### Step 4: Run Simulation

In Simulink GUI:
- Click the **Run** button (▶)
- Wait for simulation to complete (10-30 seconds)
- View waveforms in Scope blocks

Or from MATLAB command window:
```matlab
sim('BuckBoost_Converter')
```

### Step 5: Analyze Results

```matlab
analyze_results
```

This script:
- Extracts simulation data from workspace
- Calculates steady-state values
- Analyzes ripple performance
- Performs FFT frequency analysis
- Compares with theoretical predictions
- Generates comprehensive plots
- Saves results to text files and images

**Output Files:**
- `simulation_results.txt` - Detailed text summary
- `buck_boost_overview.png` - Main waveforms
- `buck_boost_performance.png` - Performance metrics
- `results_table.tex` - LaTeX table for reports

## Expected Results

### Output Voltage
- **Average:** -12.0 V
- **Ripple:** < 120 mV peak-to-peak (< 1%)
- **Settling Time:** 3-5 ms
- **Waveform:** DC level with small triangular ripple at 40 kHz

### Inductor Current
- **Average:** 6.25 A
- **Ripple:** ~0.625 A peak-to-peak (~10%)
- **Peak:** ~6.56 A
- **Minimum:** ~5.94 A (always > 0 for CCM)
- **Waveform:** Triangular ripple on DC level

### Efficiency
- **Expected:** 92-95%
- **Losses:** Switch, diode, inductor, capacitor ESR

### Gate Signal
- **Frequency:** 40 kHz
- **Duty Cycle:** 33.33%
- **ON Time:** 8.33 μs
- **OFF Time:** 16.67 μs

## Modifying Parameters

### Change Output Voltage

Edit `design_calculations.m`:
```matlab
Vout = -16;  % For -16V output
```

The script automatically recalculates duty cycle and component values.

### Change Output Power

Edit `design_calculations.m`:
```matlab
Pout = 100;  % For 100W output
```

Load resistance is automatically recalculated.

### Change Switching Frequency

Edit `design_calculations.m`:
```matlab
fs = 100000;  % For 100 kHz switching
```

Component values are recalculated to maintain ripple specifications.

## Troubleshooting

### Simulation Runs Slowly
**Solution:**
- Increase minimum step size in solver settings
- Use averaged model (`buck_boost_simulation.m`)
- Reduce simulation time

### Voltage/Current Incorrect
**Solution:**
- Verify all power connections in Simulink
- Check PWM signal is connected to MOSFET gate
- Verify component polarities (especially diode)
- Ensure all grounds are connected

### Model Won't Run
**Solution:**
- Verify Simscape Electrical toolbox is installed
- Check for missing connections
- Add `powergui` block if missing
- Verify solver settings (use `ode23tb` or `ode15s`)

### Oscillations or Instability
**Solution:**
- Add snubber circuits across switch and diode
- Reduce capacitor ESR
- Check for floating nodes
- Adjust solver tolerances

## Advanced Features

### Closed-Loop Control

Add voltage feedback and PI controller for regulated output:

```matlab
% In Simulink model:
% 1. Add voltage measurement and feedback
% 2. Add reference voltage (Vref = -12)
% 3. Add Sum block (error = Vref - Vmeasured)
% 4. Add PID Controller (Kp = 0.1, Ki = 100, Kd = 0)
% 5. Connect controller output to PWM modulator
```

### Discontinuous Conduction Mode (DCM)

To observe DCM operation:
```matlab
% In design_calculations.m
L_standard = 1000e-6;  % Increase inductance to 1000 μH
Rload = 10;            % Reduce load (increase resistance)
```

### Parametric Sweep

Test multiple duty cycles:
```matlab
D_values = 0.2:0.05:0.6;
Vout_results = zeros(size(D_values));

for i = 1:length(D_values)
    % Update duty cycle
    set_param('BuckBoost_Converter/PWM_Generator', ...
              'PulseWidth', num2str(D_values(i)*100));
    % Run simulation
    sim('BuckBoost_Converter');
    % Extract result
    Vout_results(i) = mean(Vout_data.Data(end-1000:end));
end

plot(D_values, Vout_results);
xlabel('Duty Cycle'); ylabel('Output Voltage (V)');
```

## Theory

### Buck-Boost Converter Operation

The buck-boost converter is an inverting DC-DC converter that can:
- **Buck Mode:** D < 0.5, |Vout| < Vin
- **Boost Mode:** D > 0.5, |Vout| > Vin
- **Unity Gain:** D = 0.5, |Vout| = Vin

### Key Equations

**Voltage Conversion:**
```
Vout = -Vin × D / (1 - D)
```

**Duty Cycle:**
```
D = |Vout| / (Vin + |Vout|)
```

**Inductor Current (Average):**
```
IL_avg = |Vout| / [Rload × (1 - D)]
```

**Inductor Design:**
```
L = (Vin × D) / (ΔIL × fs)
```

**Capacitor Design:**
```
C = (Iout × D) / (ΔVout × fs)
```

**CCM/DCM Boundary:**
```
Lcrit = (Vin × D × (1-D)² × Rload) / (2 × fs × Pout / Vout²)
```

### Conduction Modes

**Continuous Conduction Mode (CCM):**
- Inductor current never reaches zero
- Occurs when L > Lcrit or light loads
- More predictable behavior

**Discontinuous Conduction Mode (DCM):**
- Inductor current reaches zero during switching cycle
- Occurs when L < Lcrit or heavy loads
- Output voltage depends on load

## Performance Metrics

### Efficiency Factors

**Losses:**
1. **Switch Conduction:** I²L_rms × Ron × D
2. **Switch Switching:** Esw × fs
3. **Diode Conduction:** Vf × Iout + I²L_rms × Rf × (1-D)
4. **Inductor:** I²L_rms × RL
5. **Capacitor ESR:** I²ripple × ESR

**Typical Efficiency:** 90-95% at rated load

### Design Tradeoffs

| Increase | Effect |
|----------|--------|
| Inductance | ↓ Current ripple, ↑ Size, ↑ Cost, ↑ DCM threshold |
| Capacitance | ↓ Voltage ripple, ↑ Size, ↑ Cost |
| Switching Freq | ↓ Component size, ↑ Switching loss, ↑ EMI |
| Duty Cycle | ↑ Output voltage (mag), ↑ Current stress |

## References

1. Erickson, R. W., & Maksimović, D. (2001). *Fundamentals of Power Electronics*. Springer.
2. Mohan, N., Undeland, T. M., & Robbins, W. P. (2003). *Power Electronics: Converters, Applications, and Design*. Wiley.
3. MathWorks. (2023). *Simscape Electrical Documentation*.

## Project Submission Checklist

- [ ] Complete Simulink model (`.slx` file)
- [ ] Circuit diagram (screenshot or Simulink export)
- [ ] Design calculations (documented code output)
- [ ] Simulation results (waveform screenshots)
- [ ] Performance analysis (comparison with theory)
- [ ] Discussion of results
- [ ] Component specifications table
- [ ] MATLAB scripts (`.m` files)
- [ ] Project report (PDF/Word)
- [ ] References cited

## License

This project is provided as educational material for power electronics courses.

## Author

Auto-generated Buck-Boost Converter Simulation Suite
Created: November 2025

## Support

For issues or questions:
1. Review the `IMPLEMENTATION_GUIDE.md`
2. Check MATLAB/Simulink documentation
3. Verify toolbox installation
4. Check component connections in model

## Acknowledgments

Based on standard buck-boost converter design principles and MATLAB/Simulink best practices.
