# Buck-Boost Converter Implementation Guide

Detailed step-by-step instructions for building and simulating a buck-boost converter in MATLAB/Simulink.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Automated Build Method](#automated-build-method)
3. [Manual Build Method](#manual-build-method)
4. [Circuit Connection Details](#circuit-connection-details)
5. [Simulation Configuration](#simulation-configuration)
6. [Running the Simulation](#running-the-simulation)
7. [Results Analysis](#results-analysis)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software

- **MATLAB:** R2017a or later
- **Simulink:** Included with MATLAB
- **Simscape Electrical:** (formerly SimPowerSystems)
  - Verify installation: `ver` in MATLAB command window
  - Look for "Simscape Electrical" in the list

### Required Toolboxes

```matlab
% Check installed toolboxes
ver

% Required:
% - Simulink
% - Simscape
% - Simscape Electrical

% Optional:
% - Control System Toolbox (for closed-loop control)
% - Signal Processing Toolbox (for advanced FFT analysis)
```

### Knowledge Prerequisites

- Basic understanding of DC-DC converters
- Familiarity with MATLAB/Simulink interface
- Understanding of power electronics switching theory

---

## Automated Build Method

### Step 1: Run Design Calculations

```matlab
% Navigate to project directory
cd /path/to/buck-boost-simulation

% Run design calculations
design_calculations
```

**Expected Output:**
```
============================================
BUCK-BOOST CONVERTER DESIGN CALCULATIONS
============================================

OPERATING POINT:
  Duty Cycle (D): 0.3333 (33.33%)
  Load Resistance: 2.88 Ohm
  Output Current: 4.167 A
  Average Inductor Current: 6.250 A
  Average Input Current: 2.292 A

INDUCTOR DESIGN:
  Calculated Inductance: 320.00 uH
  Standard Value Used: 320 uH
  Peak Current: 6.563 A
  RMS Current: 6.250 A
  ...
```

This creates `buck_boost_parameters.mat` containing all design values.

### Step 2: Create Simulink Model

```matlab
% Run model generation script
create_buck_boost_model
```

**What This Does:**
1. Loads parameters from MAT file
2. Creates new Simulink model
3. Configures solver settings
4. Adds all power components
5. Adds control and measurement blocks
6. Sets component parameters
7. Creates signal connections (where possible)
8. Saves model as `BuckBoost_Converter.slx`

**Expected Output:**
```
============================================
CREATING BUCK-BOOST CONVERTER SIMULINK MODEL
============================================

Loaded parameters from buck_boost_parameters.mat

Creating Simulink model: BuckBoost_Converter
Configuring solver settings...
Adding power system components...
Power components added successfully!
Adding control components...
Adding measurement instruments...
Adding display and scope blocks...
Connecting blocks...
Model saved successfully: BuckBoost_Converter.slx
...
```

### Step 3: Complete Manual Connections

The script creates most blocks but **power circuit connections require manual completion**:

```matlab
% Open the model
open_system('BuckBoost_Converter')
```

Follow the connection instructions printed by the script (also see [Circuit Connection Details](#circuit-connection-details) below).

### Step 4: Run Simulation

```matlab
% Run from command line
sim('BuckBoost_Converter')
```

Or click **Run** button (▶) in Simulink.

### Step 5: Analyze Results

```matlab
% Run analysis script
analyze_results
```

---

## Manual Build Method

If you prefer to build everything manually or if automated script fails:

### Step 1: Open Simulink

```matlab
% Start Simulink
simulink

% Or
simulinkLibraryBrowser
```

### Step 2: Create New Model

1. Click **Blank Model**
2. **File → Save As**: `BuckBoost_Converter.slx`

### Step 3: Add Power Components

**Library Path:** `Simulink Library Browser → Simscape → Electrical → Specialized Power Systems`

#### A. DC Voltage Source

1. Navigate to: `Electrical Sources → DC Voltage Source`
2. Drag to canvas
3. Double-click to open parameters
4. Set:
   - Amplitude: `24` V
5. Click **OK**

#### B. MOSFET

1. Navigate to: `Power Electronics → MOSFET`
2. Drag to canvas
3. Set parameters:
   - Internal resistance Ron: `0.01` Ω
   - Forward voltage Vf: `0.5` V
   - Internal diode inductance: `0` H
   - Internal diode resistance: `0.01` Ω
   - Internal diode forward voltage: `0.5` V

#### C. Inductor

1. Navigate to: `Elements → Series RLC Branch`
2. Drag to canvas
3. Rename to: `Inductor`
4. Set parameters:
   - Branch type: `RLC`
   - Resistance R: `0.05` Ω
   - Inductance L: `320e-6` H
   - Capacitance C: `inf`

#### D. Diode

1. Navigate to: `Power Electronics → Diode`
2. Drag to canvas
3. Set parameters:
   - Internal resistance Ron: `0.01` Ω
   - Forward voltage Vf: `0.5` V
   - Initial current Ic: `0` A
   - Snubber resistance Rs: `1e5` Ω
   - Snubber capacitance Cs: `inf`

#### E. Output Capacitor

1. Navigate to: `Elements → Series RLC Branch`
2. Drag to canvas
3. Rename to: `Output_Cap`
4. Set parameters:
   - Branch type: `RLC`
   - Resistance R: `0.01` Ω (ESR)
   - Inductance L: `0` H
   - Capacitance C: `330e-6` F

#### F. Load Resistor

1. Navigate to: `Elements → Series RLC Branch`
2. Drag to canvas
3. Rename to: `Load`
4. Set parameters:
   - Branch type: `RLC`
   - Resistance R: `2.88` Ω
   - Inductance L: `0` H
   - Capacitance C: `inf`

#### G. Ground Blocks

1. Navigate to: `Connectors → Ground` (Electrical Reference)
2. Add **three** ground blocks
3. Place strategically:
   - Ground1: Near DC source
   - Ground2: Near MOSFET source
   - Ground3: Near output

#### H. powergui Block

**CRITICAL:** Required for all power electronics simulations

1. Navigate to: `Utilities → powergui`
2. Drag to canvas (place in upper corner)
3. Double-click and set:
   - Simulation type: `Continuous`
   - Sample time: `0` (inherited)

### Step 4: Add Control Components

**Library Path:** `Simulink Library Browser → Simulink → Sources`

#### Pulse Generator (PWM)

1. Find: `Pulse Generator`
2. Drag to canvas
3. Set parameters:
   - Amplitude: `1`
   - Period (secs): `25e-6` (= 1/40000)
   - Pulse width (% of period): `33.33`
   - Phase delay (secs): `0`

### Step 5: Add Measurement Blocks

**Library Path:** `Simscape → Electrical → Specialized Power Systems → Measurements`

#### Voltage Measurements

1. Add **two** `Voltage Measurement` blocks
2. Rename:
   - `Vin_Measure`: For input voltage
   - `Vout_Measure`: For output voltage

#### Current Measurement

1. Add **one** `Current Measurement` block
2. Rename: `IL_Measure`
3. This will be inserted in series with inductor

### Step 6: Add Display/Scope Blocks

**Library Path:** `Simulink Library Browser → Simulink → Sinks`

#### Scopes

Add **three** `Scope` blocks:
1. `Vout_Scope`: Output voltage waveform
2. `IL_Scope`: Inductor current waveform
3. `Gate_Scope`: Gate signal waveform

**Configure Scopes:**
- Double-click each scope
- Click gear icon (⚙) for settings
- Set:
  - Number of input ports: `1`
  - Time span: `auto` or `0.01` (for 10ms display)
  - Sample time: `-1` (inherited)

#### Display Blocks

Add **two** `Display` blocks:
1. `Vout_Display`: Show average output voltage
2. `IL_Display`: Show average inductor current

#### To Workspace Blocks

Add **two** `To Workspace` blocks:
1. `Vout_ToWS`:
   - Variable name: `Vout_data`
   - Save format: `Timeseries`
2. `IL_ToWS`:
   - Variable name: `IL_data`
   - Save format: `Timeseries`

---

## Circuit Connection Details

### Power Circuit Topology

```
        +----[ L ]----+
        |             |
    [DC Source]   [Switching Node]
        |             |
        |          +--+--+
        |          |     |
        |        [D]   [K]
        |    [MOSFET] [Diode]
        |        [S]   [A]
        |          |     |
        +----------+-----+
        |                |
    [Ground1]      [To Output]


Output Section:
    [K]---+----[ C ]----+----[ Rload ]----+
          |             |                 |
      [Ground3]     [Ground3]         [Ground3]
```

### Detailed Connections

**Create these connections manually in Simulink:**

#### 1. Input Circuit

| From | To | Notes |
|------|-----|-------|
| DC_Source (+) | Inductor port 1 | Power flow starts here |
| Inductor port 2 | Switching Node | Create junction (Ctrl+drag) |
| DC_Source (-) | Ground1 | Return path |

#### 2. Switching Node

**The switching node is where inductor, MOSFET drain, and diode cathode meet.**

| From | To | Notes |
|------|-----|-------|
| Switching Node | MOSFET Drain (D) | Switch connects here |
| Switching Node | Diode Cathode (K) | Diode blocks when switch ON |
| Switching Node | IL_Measure (+) | Current sensor |

#### 3. MOSFET Connections

| Terminal | Connects To | Notes |
|----------|-------------|-------|
| Gate (G) | PWM_Generator output | Control signal |
| Drain (D) | Switching Node | Main power path |
| Source (S) | Ground2 | Return through ground |

#### 4. Diode Connections

| Terminal | Connects To | Notes |
|----------|-------------|-------|
| Cathode (K) | Switching Node | Input side |
| Anode (A) | DC_Source (-) | Connected to source negative |

**Alternative:** Some prefer diode anode to separate ground:
```
Diode Anode (A) → Ground1
```
Both are equivalent if all grounds are connected.

#### 5. Output Circuit

| From | To | Notes |
|------|-----|-------|
| Diode Cathode (K) | Output_Cap port 1 | DC blocking |
| Output_Cap port 1 | Load port 1 | Parallel connection |
| Output_Cap port 2 | Ground3 | Return |
| Load port 2 | Ground3 | Return |

#### 6. Current Measurement

Insert `IL_Measure` in series with inductor:
```
Inductor port 2 → IL_Measure (+)
IL_Measure (-) → Switching Node
```

#### 7. Voltage Measurements

**Input Voltage:**
```
Vin_Measure (+) → DC_Source (+)
Vin_Measure (-) → Ground1
```

**Output Voltage:**
```
Vout_Measure (+) → Output_Cap port 1 (same as Load port 1)
Vout_Measure (-) → Ground3
```

#### 8. Signal Connections

| From | To | Notes |
|------|-----|-------|
| PWM_Generator | MOSFET Gate (G) | |
| PWM_Generator | Gate_Scope | View gate signal |
| Vout_Measure | Vout_Scope | |
| Vout_Measure | Vout_Display | |
| Vout_Measure | Vout_ToWS | |
| IL_Measure | IL_Scope | |
| IL_Measure | IL_Display | |
| IL_Measure | IL_ToWS | |

### Connection Tips

1. **Use Junctions:** Ctrl+Drag to create signal branches
2. **Label Signals:** Right-click line → Signal Properties → Name
3. **Color Code:** Right-click line → Format → Line Color
   - Red for power paths
   - Blue for measurements
   - Green for control
4. **Use Goto/From:** For cleaner layout with long connections
5. **Arrange Blocks:** Drag to organize logically

---

## Simulation Configuration

### Solver Settings

**Access:** Model → Model Configuration Parameters (Ctrl+E)

#### Solver Tab

| Parameter | Value | Reason |
|-----------|-------|--------|
| Simulation time - Start | `0` | Start time |
| Simulation time - Stop | `0.01` | 10ms (see transient and steady-state) |
| Solver Type | `Variable-step` | Handles switching efficiently |
| Solver | `ode23tb` | Good for stiff systems |
| Max step size | `auto` | Let solver decide |
| Min step size | `auto` | Let solver decide |
| Relative tolerance | `1e-3` | Good accuracy/speed balance |
| Absolute tolerance | `auto` | Auto-scaled |

**Alternative Solvers:**
- `ode15s`: More robust for very stiff systems
- `ode45`: General purpose (may be slower)
- `ode23t`: Moderate stiffness

#### Data Import/Export Tab

Check boxes for:
- ✓ Time
- ✓ States
- ✓ Output

Format: `Structure with Time` or `Array`

#### Diagnostics Tab

Recommended settings:
- Algebraic loop: `warning` or `error`
- Min step size violation: `warning`
- Consecutive zero crossings: `warning`

### powergui Configuration

Double-click `powergui` block:

| Setting | Value |
|---------|-------|
| Simulation type | Continuous |
| Sample time | 0 (inherited) |

**Optional:**
- Enable "Use local solver" if convergence issues

---

## Running the Simulation

### Method 1: Simulink GUI

1. Open model: `open_system('BuckBoost_Converter')`
2. Click **Run** button (▶) in toolbar
3. Watch progress bar
4. Simulation completes automatically

### Method 2: Command Line

```matlab
% Basic simulation
sim('BuckBoost_Converter')

% With specific stop time
sim('BuckBoost_Converter', 'StopTime', '0.02')

% Save output to variables
simOut = sim('BuckBoost_Converter');
```

### Method 3: Batch Simulation

```matlab
% Simulate multiple parameter sets
duty_cycles = [0.25, 0.33, 0.40, 0.50];
results = cell(length(duty_cycles), 1);

for i = 1:length(duty_cycles)
    % Update duty cycle
    set_param('BuckBoost_Converter/PWM_Generator', ...
              'PulseWidth', num2str(duty_cycles(i)*100));

    % Run simulation
    simOut = sim('BuckBoost_Converter');

    % Store results
    results{i} = simOut;

    fprintf('Completed D = %.2f\n', duty_cycles(i));
end
```

### Monitoring Progress

**View real-time data:**
1. Double-click Scope blocks during simulation
2. Watch Display blocks update
3. Check MATLAB command window for warnings/errors

**Stop simulation:**
- Click **Stop** button (■)
- Or: `Ctrl+T`
- Or: `set_param(modelName, 'SimulationCommand', 'stop')`

---

## Results Analysis

### Using Scopes

**After simulation:**
1. Double-click each Scope block
2. Use toolbar buttons:
   - 🔍 **Zoom:** Select region to zoom
   - ↔ **Autoscale:** Fit all data
   - 📏 **Cursor:** Measure values
   - ⚙ **Settings:** Configure display

**Scope Tips:**
- Right-click → `Configuration Properties` → Set axes limits
- `Tools → Measurements` → Rise time, overshoot, steady-state
- `File → Print to Figure` → Export as MATLAB figure

### Using Analysis Script

**Comprehensive analysis:**
```matlab
analyze_results
```

**What it does:**
- Extracts time series data from workspace
- Calculates steady-state statistics
- Computes ripple values
- Performs FFT analysis
- Compares with theoretical predictions
- Generates plots:
  - Output voltage vs time
  - Inductor current vs time
  - Voltage ripple detail
  - Current ripple detail
  - Frequency spectrum
  - Performance metrics
- Saves results to files

**Generated Files:**
- `simulation_results.txt`: Text summary
- `buck_boost_overview.png`: Main waveforms
- `buck_boost_performance.png`: Metrics
- `results_table.tex`: LaTeX table
- `.fig` files: Editable MATLAB figures

### Manual Analysis

**Extract data from workspace:**
```matlab
% Check available variables
whos

% Output voltage data
t = Vout_data.Time;
v = Vout_data.Data;

% Plot manually
figure;
plot(t*1000, v);
xlabel('Time (ms)');
ylabel('Output Voltage (V)');
title('Buck-Boost Output Voltage');
grid on;

% Calculate statistics
v_avg = mean(v(end-1000:end));  % Last 1000 points
v_ripple = max(v(end-1000:end)) - min(v(end-1000:end));

fprintf('Average Output: %.3f V\n', v_avg);
fprintf('Voltage Ripple: %.3f mV\n', v_ripple*1000);
```

### Exporting Results

**Save workspace:**
```matlab
save('simulation_results.mat')
```

**Export figures:**
```matlab
% As image
print('figure1', '-dpng', '-r300')  % 300 DPI PNG

% As vector
print('figure1', '-depsc')  % EPS for LaTeX

% As PDF
print('figure1', '-dpdf')
```

**Copy scope to clipboard:**
1. Open Scope
2. `Edit → Copy Figure to Clipboard`
3. Paste into document

---

## Troubleshooting

### Common Issues

#### 1. "Simulation fails immediately"

**Symptoms:**
- Red error messages
- "Cannot start simulation"

**Solutions:**
- Check all connections are complete
- Verify `powergui` block exists
- Ensure ground blocks are properly connected
- Check for algebraic loops
- Verify component parameters are valid (no `NaN`, `inf` where inappropriate)

**Debug Steps:**
```matlab
% Check for errors
open_system('BuckBoost_Converter')
% Look for red error icons on blocks

% Verify blocks are connected
hilite_system('BuckBoost_Converter', 'all')
```

#### 2. "Simulation runs very slowly"

**Solutions:**
- Reduce simulation time: `0.01` → `0.005`
- Change solver: `ode23tb` → `ode15s`
- Increase min step size:
  ```matlab
  set_param(modelName, 'MinStep', '1e-7')
  ```
- Use averaged model instead (faster):
  ```matlab
  buck_boost_simulation  % State-space model
  ```

#### 3. "Output voltage is wrong"

**Expected:** -12 V
**Actual:** Different value

**Causes & Solutions:**

| Problem | Cause | Solution |
|---------|-------|----------|
| Vout ≈ 0 | No gate signal | Connect PWM to MOSFET gate |
| Vout = Vin | MOSFET always ON | Check PWM duty cycle |
| Vout ≈ 0 | MOSFET never ON | Check gate polarity |
| Vout wrong magnitude | Wrong duty cycle | Verify D = 0.3333 |
| Vout positive | Diode reversed | Check diode polarity |
| Vout unstable | No capacitor | Check capacitor connected |

**Debug:**
```matlab
% Check PWM signal
% Add scope to PWM_Generator output
% Verify: square wave, 40 kHz, 33.33% duty

% Check gate voltage
% Add voltage measurement across MOSFET gate-source
% Should match PWM signal
```

#### 4. "Large voltage/current spikes"

**Symptoms:**
- Oscillations
- Unrealistic peaks
- Simulation unstable

**Solutions:**

1. **Add snubber circuits:**
   ```
   Across MOSFET (Drain-Source):
     R = 100 Ω, C = 100 nF in series

   Across Diode (Cathode-Anode):
     R = 100 Ω, C = 100 nF in series
   ```

2. **Adjust solver settings:**
   ```matlab
   set_param(modelName, 'RelTol', '1e-4')
   set_param(modelName, 'Solver', 'ode15s')
   ```

3. **Check component models:**
   - Add small resistance to ideal components
   - Use detailed switch models

#### 5. "Inductor current goes negative (DCM mode)"

**Symptom:** Current touches zero or goes negative

**Not necessarily an error!** This indicates Discontinuous Conduction Mode.

**If CCM is desired:**
- Increase inductance: `L = 500e-6` (500 μH)
- Reduce load resistance (increase power)
- Check against critical inductance

```matlab
% Calculate critical inductance
Lcrit = (Vin * D * (1-D)^2 * Rload) / (2 * fs * Pout / abs(Vout)^2);
fprintf('Critical L: %.2f uH\n', Lcrit*1e6);
fprintf('Actual L: %.2f uH\n', L_standard*1e6);

if L_standard > Lcrit
    fprintf('Should be in CCM\n');
else
    fprintf('Will be in DCM\n');
end
```

#### 6. "Convergence issues / Min step size violation"

**Error message:** "Min step size reached"

**Solutions:**

1. **Adjust solver:**
   ```matlab
   set_param(modelName, 'Solver', 'ode15s')
   set_param(modelName, 'MaxStep', '1e-5')
   ```

2. **Use discrete solver:**
   ```matlab
   set_param(modelName, 'SolverType', 'Fixed-step')
   set_param(modelName, 'FixedStep', '1e-7')
   ```

3. **Simplify model:**
   - Remove unnecessary detail
   - Use averaged models for faster simulation

#### 7. "Data not in workspace after simulation"

**Problem:** `Vout_data` or `IL_data` not found

**Solutions:**

1. **Check To Workspace blocks exist**
2. **Verify block settings:**
   - Variable name is correct
   - Save format is `Timeseries` or `Array`
   - Limit data points: `inf` or large number
3. **Check Configuration Parameters:**
   - `Model Configuration Parameters → Data Import/Export`
   - Ensure appropriate boxes are checked

#### 8. "Toolbox not found errors"

**Error:** "Cannot find library..."

**Solution:**
- Verify Simscape Electrical is installed:
  ```matlab
  ver
  ```
- Install missing toolbox:
  - `MATLAB → Add-Ons → Get Add-Ons`
  - Search for "Simscape Electrical"
  - Install

---

## Advanced Techniques

### 1. Parameterizing the Model

Use MATLAB workspace variables in block parameters:

**In Block Dialog:**
- Instead of `24`, use: `Vin`
- Instead of `0.01`, use: `Ron`

**Then change from MATLAB:**
```matlab
Vin = 12;  % Change input voltage
sim('BuckBoost_Converter');
```

### 2. Adding Closed-Loop Control

**Steps:**
1. Measure output voltage
2. Subtract from reference (error)
3. Pass error through PI controller
4. Modulate PWM with controller output

**Example:**
```matlab
% Add these blocks:
% - Constant (Vref = -12)
% - Sum (Vref - Vout)
% - PID Controller (Kp=0.1, Ki=100)
% - Relational Operator (controller output > sawtooth)
% - Generate sawtooth at switching frequency
```

### 3. Thermal Analysis

Add thermal ports to switches:
1. Use detailed power electronics blocks with thermal modeling
2. Connect thermal resistance blocks
3. Connect to temperature sensor

### 4. Efficiency Optimization

Sweep parameters to find optimal design:
```matlab
L_values = [100e-6, 200e-6, 320e-6, 500e-6];
efficiency = zeros(size(L_values));

for i = 1:length(L_values)
    set_param('BuckBoost_Converter/Inductor', 'L', num2str(L_values(i)));
    sim('BuckBoost_Converter');

    % Calculate efficiency from data
    Pout = mean(abs(Vout_data.Data(end-1000:end)).^2) / Rload;
    Pin = mean(Vin_data.Data .* Iin_data.Data);  % If input current measured
    efficiency(i) = Pout / Pin * 100;
end

[max_eff, idx] = max(efficiency);
fprintf('Optimal L = %.0f uH, Efficiency = %.2f%%\n', ...
        L_values(idx)*1e6, max_eff);
```

---

## Best Practices

### Model Organization

1. **Use Subsystems:** Group related blocks
   - Input filter subsystem
   - Power stage subsystem
   - Output filter subsystem
   - Control subsystem

2. **Label Everything:**
   - Block names
   - Signal labels
   - Port labels

3. **Add Annotations:**
   - Document assumptions
   - Note parameter sources
   - Add design calculations

### Simulation Efficiency

1. **Start Simple:**
   - Ideal switches first
   - Add parasitic gradually
   - Verify each step

2. **Use Conditional Subsystems:**
   - Enable/disable features
   - Compare with/without snubbers

3. **Profile Performance:**
   ```matlab
   profile on
   sim('BuckBoost_Converter')
   profile viewer
   ```

### Version Control

1. **Save Intermediate Versions:**
   - `BuckBoost_v1.slx` - Basic
   - `BuckBoost_v2.slx` - With control
   - `BuckBoost_v3.slx` - Optimized

2. **Use Model Comparison:**
   ```matlab
   visdiff('BuckBoost_v1.slx', 'BuckBoost_v2.slx')
   ```

### Documentation

1. **Model Description:** `File → Model Properties → Description`
2. **Block Descriptions:** Right-click → Properties → Description
3. **Export Model Report:** `Tools → Model Report`

---

## Conclusion

This guide provides complete instructions for implementing a buck-boost converter in MATLAB/Simulink. For additional support:

1. Refer to MATLAB documentation: `doc powerlib`
2. Check Simscape Electrical examples: `power_buckboost`
3. Review course materials and textbooks
4. Consult with instructors or colleagues

Happy simulating!
