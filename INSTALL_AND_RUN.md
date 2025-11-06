# How to Install MATLAB and Run the Simulation

## Step 1: Install MATLAB

### Get MATLAB (Choose One):

**Option A: Student/Academic License (Free for students)**
1. Go to: https://www.mathworks.com/academia/student_version.html
2. Sign up with your university email
3. Download MATLAB (includes Simulink)
4. Install these toolboxes:
   - Simulink (included)
   - Simscape
   - Simscape Electrical (Required!)

**Option B: 30-Day Free Trial**
1. Go to: https://www.mathworks.com/campaigns/products/trials.html
2. Create MathWorks account
3. Download MATLAB + Simulink + Simscape Electrical
4. Install

**Option C: MATLAB Online (No Installation!)**
1. Go to: https://matlab.mathworks.com/
2. Sign in (free account)
3. Upload all `.m` files from this repo
4. Run directly in browser!

**Option D: GNU Octave (Free, Limited)**
- Download: https://octave.org/download
- Note: Octave doesn't have Simulink, so visual simulation won't work
- Only design calculations will work

## Step 2: Clone This Repository

```bash
git clone https://github.com/gabrielantonyxaviour/buck-boost-simulation.git
cd buck-boost-simulation
```

## Step 3: Run in MATLAB

### Open MATLAB
1. Launch MATLAB application
2. Navigate to the `buck-boost-simulation` folder
3. In MATLAB command window, type:

```matlab
pwd  % Check you're in the right folder
ls   % Should see .m files
```

### Run the Simulation

**Full Automated Workflow:**
```matlab
run_complete_simulation
```

This will:
1. Calculate all design parameters
2. Create the Simulink model
3. Show interactive menu

**Or Step-by-Step:**

```matlab
% Step 1: Design calculations
design_calculations

% Step 2: Create Simulink model
create_buck_boost_model

% Step 3: Open the model
open_system('BuckBoost_Converter')
```

## Step 4: Complete Manual Connections

**Important:** The Simulink model needs manual power connections!

In the Simulink model window you'll see blocks for:
- DC_Source
- Inductor
- MOSFET
- Diode
- Output_Cap
- Load
- Ground blocks

**Connect them like this:**

```
DC_Source(+) ──→ Inductor ──→ Switching_Node
                                    │
                              ┌─────┴─────┐
                              │           │
                         MOSFET(D)    Diode(K)
                              │           │
                         MOSFET(S)    Diode(A)
                              │           │
                           Ground    DC_Source(-)

Diode(K) ──→ Output_Cap ──→ Load ──→ Ground
                 │
              Ground
```

**Detailed connections printed by the script - follow those!**

## Step 5: Run the Simulation

1. In Simulink model window, click the **Run** button (▶ play icon)
2. Wait 10-30 seconds for simulation to complete
3. You'll see "Ready" in bottom status bar when done

## Step 6: View the Results! 🎉

**Double-click these Scope blocks to see waveforms:**

1. **Vout_Scope** - Output Voltage
   - You'll see: -12V DC with ~100mV ripple
   - Triangular ripple waveform

2. **IL_Scope** - Inductor Current
   - You'll see: ~6.25A with triangular ripple
   - Current oscillating between 5.9A and 6.6A

3. **Gate_Scope** - PWM Gate Signal
   - You'll see: Square wave at 40kHz
   - 33.33% duty cycle

**Use Scope Tools:**
- Click 🔍 **Zoom** to zoom into waveform
- Click **Autoscale** to fit all data
- Click 📏 **Cursor** to measure exact values
- Right-click → **Configuration** to adjust display

## Step 7: Generate Analysis Plots

```matlab
analyze_results
```

This creates:
- `buck_boost_overview.png` - All waveforms
- `buck_boost_performance.png` - Performance metrics
- `simulation_results.txt` - Detailed results
- Opens figure windows with plots

## Expected Visual Output

### Output Voltage Waveform
```
-11.8V ─────────────────────────── ← Peak
          /\    /\    /\    /\
-12.0V ──────────────────────────── ← Average (target)
          \/    \/    \/    \/
-12.2V ─────────────────────────── ← Trough

Time: 0ms ────────────→ 10ms
Ripple: ~100mV peak-to-peak
Frequency: 40kHz
```

### Inductor Current Waveform
```
6.6A ────/\────/\────/\────/\──── ← Peak
        /  \  /  \  /  \  /  \
6.25A ──────────────────────────── ← Average
       \  /  \  /  \  /  \  /
5.9A ────\/────\/────\/────\/──── ← Trough

Shape: Triangular (ramp up during ON, ramp down during OFF)
Never touches zero = CCM mode ✓
```

### Gate/PWM Signal
```
1V  ─┐     ┌─┐     ┌─┐     ┌─┐
     │     │ │     │ │     │ │
     │ON   │ │ ON  │ │ ON  │ │
0V  ─┘─────┘ ┘─────┘ ┘─────┘ ┘───

    ├─8.3μs─┤        ← ON time
    ├────25μs────┤   ← Period (40kHz)

Duty Cycle = 8.3/25 = 33.33% ✓
```

## Troubleshooting

### "Simscape Electrical not found"
→ You need to install Simscape Electrical toolbox
→ In MATLAB: Home → Add-Ons → Get Add-Ons → Search "Simscape Electrical"

### "Simulation errors"
→ Check all blocks are connected (no red exclamation marks)
→ Make sure powergui block is present
→ Follow connection diagram carefully

### "Wrong output voltage"
→ Verify PWM duty cycle is 33.33%
→ Check diode polarity (cathode to switching node)
→ Ensure all grounds connected

### "Can't install MATLAB"
→ Try MATLAB Online (browser-based, free)
→ Or use university computer lab
→ Or Octave (limited, no visual simulation)

## Quick Test Without Full Simulation

If you just want to verify calculations:

```matlab
design_calculations
```

This shows all design parameters without needing the full simulation.

Output:
```
Duty Cycle: 0.3333 (33.33%)
Output Voltage: -12.0 V
Efficiency: 92.6%
Inductor: 320 µH
Capacitor: 330 µF
... (complete component specs)
```

## System Requirements

**Minimum:**
- OS: Windows 10, macOS 10.14, Linux
- RAM: 4 GB
- Disk: 10 GB free space
- MATLAB R2017a or later

**Recommended:**
- RAM: 8 GB+
- MATLAB R2021a or later

## Using MATLAB Online (Easiest!)

**No installation needed!**

1. Go to: https://matlab.mathworks.com/
2. Sign in (create free account if needed)
3. Click "Open MATLAB Online"
4. Upload all `.m` files from this repo:
   - design_calculations.m
   - create_buck_boost_model.m
   - analyze_results.m
   - run_complete_simulation.m
5. Run: `run_complete_simulation`

**Note:** Simulink may be slower in browser, but it works!

---

## Summary

**To see the visual simulation, you MUST:**
1. ✅ Have MATLAB installed (or use MATLAB Online)
2. ✅ Have Simscape Electrical toolbox
3. ✅ Run `create_buck_boost_model` to build model
4. ✅ Complete manual connections
5. ✅ Click Run button in Simulink
6. ✅ Double-click Scope blocks to see waveforms

**That's it! You'll see the real-time simulation with oscilloscope-style waveforms.**
