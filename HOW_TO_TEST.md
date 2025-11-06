# How to Test the Buck-Boost Converter Simulation

## ✅ Calculation Test (Python - Already Working!)

I've validated the calculations work correctly:

```bash
python3 test_calculations.py
```

**Result:** ✓ PASSED
- Duty Cycle: 33.33% ✓
- Output Voltage: -12.0 V ✓
- Efficiency: 91.87% ✓
- All calculations match theoretical values ✓

## 🔬 Full MATLAB Simulation (Requires MATLAB)

### Prerequisites
- MATLAB R2017a or later installed
- Simscape Electrical toolbox

### Quick Test (3 minutes)

```matlab
% In MATLAB command window:

% 1. Run design calculations
design_calculations

% Expected output:
%   Duty Cycle: 0.3333 (33.33%)
%   Output Voltage: -12.0 V
%   Efficiency: ~92%
```

### Full Simulation Test (10 minutes)

```matlab
% 1. Create the model
create_buck_boost_model

% 2. Open the model
open_system('BuckBoost_Converter')

% 3. Complete manual connections (see instructions in console)
%    Key connections:
%    - DC Source (+) → Inductor → Switching Node
%    - Switching Node → MOSFET Drain & Diode Cathode
%    - MOSFET Source → Ground
%    - Diode output → Capacitor & Load

% 4. Run simulation
sim('BuckBoost_Converter')

% 5. View results in Scope blocks by double-clicking:
%    - Vout_Scope: Should show -12V with small ripple
%    - IL_Scope: Should show ~6.25A triangular waveform
%    - Gate_Scope: Should show 40kHz square wave

% 6. Analyze results
analyze_results

% This generates:
%    - Plots showing all waveforms
%    - Performance comparison with theory
%    - Exported PNG images
%    - simulation_results.txt file
```

## 📊 What You Should See

### Output Voltage Scope
- **Average:** -12.0 V
- **Ripple:** ~100 mV peak-to-peak
- **Shape:** DC level with small triangular ripple
- **Frequency:** Ripple at 40 kHz

### Inductor Current Scope
- **Average:** 6.25 A
- **Ripple:** ~0.625 A peak-to-peak
- **Shape:** Triangular waveform
- **Always positive** (CCM mode)

### Gate Signal Scope
- **Frequency:** 40 kHz
- **Duty Cycle:** 33.33%
- **Amplitude:** 0-1 V square wave
- **Period:** 25 µs

## 🐛 Troubleshooting

### "MATLAB not found"
- Install MATLAB from mathworks.com
- Or use Octave (free alternative): `sudo apt install octave`

### "Simscape Electrical not installed"
In MATLAB:
```matlab
ver  % Check installed toolboxes
% If missing, install from Add-Ons
```

### "Simulation fails"
1. Check all blocks are connected (no red error icons)
2. Verify powergui block exists
3. Check solver settings (Model → Configuration Parameters)
4. See IMPLEMENTATION_GUIDE.md for detailed troubleshooting

### "Results don't match"
Common issues:
- Wrong duty cycle → Check PWM pulse width = 33.33%
- Diode reversed → Check polarity (K to switching node)
- No output → Verify gate signal connected to MOSFET

## 🎯 Success Criteria

Your simulation is working correctly if:
- ✅ Output voltage: -12.0 V ± 0.5 V
- ✅ Voltage ripple: < 200 mV
- ✅ Inductor current: 6.25 A ± 0.5 A
- ✅ Current never goes negative (CCM)
- ✅ Efficiency: > 90%
- ✅ No error messages

## 📁 Expected Output Files

After running `analyze_results`:
```
buck_boost_overview.png        - Main waveforms
buck_boost_performance.png     - Performance metrics
simulation_results.txt         - Text summary
results_table.tex              - LaTeX table
buck_boost_parameters.mat      - Saved parameters
```

## 🚀 Master Script

Run everything automatically:
```matlab
run_complete_simulation
```

This interactive script will:
1. Run design calculations
2. Create Simulink model
3. Guide you through connections
4. Provide menu to open model and view results
