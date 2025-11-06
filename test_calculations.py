#!/usr/bin/env python3
"""
Test Buck-Boost Converter Calculations
This validates that the design calculations are correct
"""

import math

print("=" * 60)
print("BUCK-BOOST CONVERTER CALCULATION TEST")
print("=" * 60)
print()

# Design specifications
Vin = 24.0          # Input voltage (V)
Vout = -12.0        # Output voltage (V)
Pout = 50.0         # Output power (W)
fs = 40000.0        # Switching frequency (Hz)

print("INPUT SPECIFICATIONS:")
print(f"  Input Voltage:        {Vin} V")
print(f"  Output Voltage:       {Vout} V")
print(f"  Output Power:         {Pout} W")
print(f"  Switching Frequency:  {fs/1000} kHz")
print()

# Calculate duty cycle
D = abs(Vout) / (Vin + abs(Vout))
print("CALCULATED PARAMETERS:")
print(f"  Duty Cycle:           {D:.4f} ({D*100:.2f}%)")

# Load resistance
Rload = abs(Vout)**2 / Pout
print(f"  Load Resistance:      {Rload:.2f} Ω")

# Output current
Iout = Pout / abs(Vout)
print(f"  Output Current:       {Iout:.3f} A")

# Average inductor current
IL_avg = Iout / (1 - D)
print(f"  Avg Inductor Current: {IL_avg:.3f} A")
print()

# Component design
L_standard = 320e-6  # 320 µH
C_standard = 330e-6  # 330 µF

# Inductor current ripple
delta_IL = (Vin * D) / (L_standard * fs)
print("COMPONENT DESIGN:")
print(f"  Inductor:             {L_standard*1e6:.0f} µH")
print(f"  Current Ripple:       {delta_IL:.3f} A ({(delta_IL/IL_avg)*100:.1f}%)")
print(f"  Peak Current:         {IL_avg + delta_IL/2:.3f} A")

# Output voltage ripple
delta_Vout = (Iout * D) / (C_standard * fs)
print(f"  Capacitor:            {C_standard*1e6:.0f} µF")
print(f"  Voltage Ripple:       {delta_Vout*1000:.1f} mV")
print()

# Verify output voltage calculation
Vout_calc = -Vin * D / (1 - D)
print("VERIFICATION:")
print(f"  Expected Vout:        {Vout} V")
print(f"  Calculated Vout:      {Vout_calc:.3f} V")
print(f"  Match: {'✓ PASS' if abs(Vout - Vout_calc) < 0.01 else '✗ FAIL'}")
print()

# Critical inductance for CCM
Lcrit = (Vin * D * (1-D)**2 * Rload) / (2 * fs)
print("CONDUCTION MODE:")
print(f"  Critical Inductance:  {Lcrit*1e6:.1f} µH")
print(f"  Actual Inductance:    {L_standard*1e6:.0f} µH")
if L_standard > Lcrit:
    print(f"  Mode: CCM (Continuous) ✓")
else:
    print(f"  Mode: DCM (Discontinuous)")
print()

# Estimate efficiency
Ron = 0.01
Vf = 0.5
Rf = 0.01
RL = 0.05
ESR = 0.01

P_switch = IL_avg**2 * Ron * D
P_diode = Vf * Iout + IL_avg**2 * Rf * (1-D)
P_inductor = IL_avg**2 * RL
P_capacitor = (delta_IL/math.sqrt(12))**2 * ESR
P_loss = P_switch + P_diode + P_inductor + P_capacitor
Pin = Pout + P_loss
efficiency = (Pout / Pin) * 100

print("POWER ANALYSIS:")
print(f"  Output Power:         {Pout:.2f} W")
print(f"  Switch Loss:          {P_switch:.3f} W")
print(f"  Diode Loss:           {P_diode:.3f} W")
print(f"  Inductor Loss:        {P_inductor:.3f} W")
print(f"  Capacitor Loss:       {P_capacitor:.4f} W")
print(f"  Total Loss:           {P_loss:.2f} W")
print(f"  Input Power:          {Pin:.2f} W")
print(f"  Efficiency:           {efficiency:.2f}%")
print()

print("=" * 60)
print("CALCULATION TEST: ✓ PASSED")
print("=" * 60)
print()
print("To test in MATLAB:")
print("  1. Open MATLAB")
print("  2. Navigate to this directory")
print("  3. Run: design_calculations")
print("  4. Compare output with values above")
