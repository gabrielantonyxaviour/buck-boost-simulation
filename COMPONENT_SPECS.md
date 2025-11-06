# Buck-Boost Converter Component Specifications

Quick reference for all component values and Simulink block parameters.

## Design Specifications

| Parameter | Symbol | Value | Unit |
|-----------|--------|-------|------|
| Input Voltage | Vin | 24 | V |
| Output Voltage | Vout | -12 | V |
| Output Power | Pout | 50 | W |
| Switching Frequency | fs | 40 | kHz |
| Duty Cycle | D | 0.3333 | (33.33%) |
| Load Resistance | Rload | 2.88 | Ω |

## Component Values

### Inductor (L)

| Parameter | Value | Unit |
|-----------|-------|------|
| Inductance | 320 | µH |
| DC Resistance (RL) | 0.05 | Ω |
| Average Current | 6.25 | A |
| Peak Current | 6.56 | A |
| RMS Current | 6.25 | A |
| Current Ripple | 0.625 | A (p-p) |
| Voltage Rating | 50 | V |
| **Suggested Part:** | Coilcraft MSS1278-334ML or equivalent | |

### Output Capacitor (C)

| Parameter | Value | Unit |
|-----------|-------|------|
| Capacitance | 330 | µF |
| ESR | 0.01 | Ω (10 mΩ) |
| Voltage Rating | 25 | V (min) |
| RMS Current | 0.18 | A |
| Ripple Current | 0.625 | A (p-p) |
| **Suggested Part:** | Panasonic EEU-FR1E331 or low-ESR electrolytic | |

### MOSFET Switch (Q)

| Parameter | Value | Unit |
|-----------|-------|------|
| Max Drain-Source Voltage (Vds) | 36 | V (use 60V rated) |
| Max Drain Current (Id) | 6.56 | A |
| RMS Current | 3.61 | A |
| On-Resistance (Ron) | 0.01 | Ω (10 mΩ typ) |
| Gate Voltage | 5-10 | V |
| Switching Frequency | 40 | kHz |
| **Suggested Part:** | IRFZ44N (55V, 49A, 17.5mΩ) or IRF540 | |

### Diode (D)

| Parameter | Value | Unit |
|-----------|-------|------|
| Max Reverse Voltage (Vr) | 36 | V (use 60V rated) |
| Average Forward Current (If_avg) | 4.17 | A |
| Peak Forward Current (If_peak) | 6.56 | A |
| RMS Current | 5.42 | A |
| Forward Voltage Drop (Vf) | 0.5 | V |
| Forward Resistance (Rf) | 0.01 | Ω (10 mΩ) |
| **Suggested Part:** | MBR2060 (60V, 20A Schottky) or similar fast recovery | |

### Load Resistor (Rload)

| Parameter | Value | Unit |
|-----------|-------|------|
| Resistance | 2.88 | Ω |
| Power Rating | 50 | W (use 75W rated) |
| Voltage | 12 | V |
| Current | 4.17 | A |
| **Suggested Part:** | Wire-wound power resistor, multiple parallel resistors | |

## Simulink Block Parameters

### DC Voltage Source
**Library:** `powerlib/Electrical Sources/DC Voltage Source`

```
Amplitude: 24
Measurement: None
```

### MOSFET
**Library:** `powerlib/Power Electronics/MOSFET`

```
Internal resistance Ron: 0.01
Inductance Lon: 0
Forward voltage Vf: 0.5
Initial current Ic: 0
Snubber resistance Rs: 1e5
Snubber capacitance Cs: inf
Internal diode resistance Rd: 0.01
Internal diode inductance Ld: 0
Internal diode forward voltage Vfd: 0.5
```

### Inductor (Series RLC Branch)
**Library:** `powerlib/Elements/Series RLC Branch`

```
Branch type: RLC
Resistance R: 0.05
Inductance L: 320e-6
Capacitance C: inf
Initial current Ic: 0
Measurements: None
```

### Diode
**Library:** `powerlib/Power Electronics/Diode`

```
Resistance Ron: 0.01
Inductance Lon: 0
Forward voltage Vf: 0.5
Initial current Ic: 0
Snubber resistance Rs: 1e5
Snubber capacitance Cs: inf
```

### Output Capacitor (Series RLC Branch)
**Library:** `powerlib/Elements/Series RLC Branch`

```
Branch type: RLC
Resistance R: 0.01
Inductance L: 0
Capacitance C: 330e-6
Initial voltage Vc: 0
Measurements: None
```

### Load (Series RLC Branch)
**Library:** `powerlib/Elements/Series RLC Branch`

```
Branch type: RLC
Resistance R: 2.88
Inductance L: 0
Capacitance C: inf
Initial current Ic: 0
Measurements: None
```

### Ground (Electrical Reference)
**Library:** `powerlib/Connectors/Ground`

```
(No parameters - just connect)
```

### PWM Generator (Pulse Generator)
**Library:** `simulink/Sources/Pulse Generator`

```
Pulse type: Sample based or Time based
Amplitude: 1
Period (secs): 25e-6
Pulse width (% of period): 33.33
Phase delay (secs): 0
```

**Calculation:**
- Period = 1 / fs = 1 / 40000 = 25 µs = 25e-6 s
- ON time = D × Period = 0.3333 × 25e-6 = 8.33 µs
- Pulse width % = D × 100 = 33.33%

### Voltage Measurement
**Library:** `powerlib/Measurements/Voltage Measurement`

```
Output type: Voltage
Measurement: None
```

### Current Measurement
**Library:** `powerlib/Measurements/Current Measurement`

```
Output type: Current
Measurement: None
```

### powergui
**Library:** `powerlib/Utilities/powergui`

```
Simulation type: Continuous
Sample time: 0
```

## Optional Components

### Input Capacitor (Cin)

If adding input filtering:

| Parameter | Value | Unit |
|-----------|-------|------|
| Capacitance | 220-470 | µF |
| Voltage Rating | 35-50 | V |
| ESR | < 0.05 | Ω |
| Purpose | Reduce input ripple, stabilize source | |

### Snubber Circuits

For reducing voltage spikes:

**MOSFET Snubber (Drain-Source):**
- R = 100 Ω, 1W
- C = 100 nF, 100V ceramic

**Diode Snubber (Cathode-Anode):**
- R = 100 Ω, 1W
- C = 100 nF, 100V ceramic

## Operating Conditions

### Steady-State Expected Values

| Parameter | Expected Value | Unit | Tolerance |
|-----------|---------------|------|-----------|
| Output Voltage (avg) | -12.0 | V | ±1% |
| Output Voltage Ripple | 120 | mV (p-p) | typ |
| Inductor Current (avg) | 6.25 | A | ±5% |
| Inductor Current Ripple | 0.625 | A (p-p) | ±10% |
| MOSFET Vds (OFF) | 36 | V | peak |
| MOSFET Vds (ON) | 0.063 | V | (Id × Ron) |
| Diode Vr (reverse) | 36 | V | peak |
| Diode Vf (forward) | 0.5 | V | typ |
| Efficiency | 93 | % | typ |

### Transient Specifications

| Parameter | Expected Value | Unit |
|-----------|---------------|------|
| Settling Time (2%) | 3-5 | ms |
| Overshoot | < 5 | % |
| Rise Time | 2-3 | ms |

## Power Loss Budget

| Component | Loss Mechanism | Power (W) | % of Total |
|-----------|---------------|-----------|------------|
| MOSFET | Conduction | 0.13 | 33% |
| MOSFET | Switching | 0.04 | 10% |
| Diode | Conduction | 2.08 | 52% |
| Inductor | Copper (DCR) | 0.195 | 5% |
| Capacitor | ESR | 0.003 | < 1% |
| **Total Loss** | | **~4.0** | |
| **Input Power** | | **54.0** | |
| **Efficiency** | | **92.6%** | |

## Design Equations

### Duty Cycle
```
D = |Vout| / (Vin + |Vout|)
D = 12 / (24 + 12) = 0.3333 (33.33%)
```

### Output Voltage
```
Vout = -Vin × D / (1 - D)
Vout = -24 × 0.3333 / 0.6667 = -12 V
```

### Average Inductor Current
```
IL_avg = |Vout| / [Rload × (1 - D)]
IL_avg = 12 / (2.88 × 0.6667) = 6.25 A
```

### Inductor Current Ripple
```
ΔIL = (Vin × D) / (L × fs)
ΔIL = (24 × 0.3333) / (320e-6 × 40000) = 0.625 A
```

### Output Voltage Ripple
```
ΔVout = (Iout × D) / (C × fs)
ΔVout = (4.167 × 0.3333) / (330e-6 × 40000) = 0.105 V = 105 mV

ΔVout_ESR = ΔIL × ESR
ΔVout_ESR = 0.625 × 0.01 = 6.25 mV

ΔVout_total ≈ 111 mV peak-to-peak
```

### Critical Inductance (CCM/DCM boundary)
```
Lcrit = (Vin × D × (1-D)² × Rload) / (2 × fs)
Lcrit = (24 × 0.3333 × 0.6667² × 2.88) / (2 × 40000)
Lcrit = 60.4 µH

L_actual = 320 µH > Lcrit → CCM operation confirmed
```

## Part Selection Guidelines

### Inductor
- Core material: Ferrite or powdered iron
- Saturation current > 1.2 × Ipeak = 7.9 A
- RMS current rating > IL_avg = 6.25 A
- DCR < 0.05 Ω (to minimize losses)
- Shielded preferred (to reduce EMI)

### Capacitor
- Type: Electrolytic (aluminum or polymer) or ceramic (multiple in parallel)
- Voltage rating > 1.5 × |Vout| = 18 V (use 25V or 35V)
- Low ESR (< 0.02 Ω) for low ripple
- Ripple current rating > 0.2 A
- Temperature rating: 85°C or 105°C

### MOSFET
- Voltage rating > 1.5 × (Vin + |Vout|) = 54 V (use 60V or 100V)
- Current rating > 1.5 × Ipeak = 9.8 A (use > 10A)
- Low Ron (< 0.02 Ω) for efficiency
- Fast switching (low Qg, Qgd)
- Logic-level gate drive preferred (Vgs = 5V)

### Diode
- Type: Schottky (for low Vf) or fast recovery
- Voltage rating > 1.5 × (Vin + |Vout|) = 54 V (use 60V)
- Current rating > 1.5 × IL_avg = 9.4 A (use > 10A)
- Low Vf (< 0.5V) for efficiency
- Fast reverse recovery (< 50ns)

## PCB Layout Considerations

### Critical Paths (Keep Short)
1. MOSFET Drain → Inductor
2. MOSFET Source → Ground
3. Diode Cathode → Inductor
4. Diode Anode → Ground
5. Output Capacitor → Load

### Ground Connections
- Power ground (high current): Thick traces/planes
- Signal ground (measurements): Separate from power ground, connect at one point
- Use ground plane for heat sinking

### Trace Widths (for 1 oz copper)
- Input power: > 100 mils (2.5 mm)
- Output power: > 80 mils (2 mm)
- Gate drive: 20-30 mils (0.5-0.8 mm)
- Signals: 10-20 mils (0.25-0.5 mm)

### Component Placement
1. Place inductor close to switching node
2. Place capacitor close to load
3. Place gate driver close to MOSFET
4. Keep switching node area minimal
5. Add test points for measurements

## Testing and Validation

### Initial Power-Up Checklist
- [ ] Verify all connections
- [ ] Check polarity of diode
- [ ] Verify capacitor polarity
- [ ] Set input voltage to 24V
- [ ] Connect electronic load (set to 2.88Ω or 50W at 12V)
- [ ] Monitor output voltage
- [ ] Check for excessive heating

### Measurements Required
- Input voltage and current
- Output voltage and current
- Inductor current waveform
- MOSFET drain-source voltage
- Gate signal
- Switching node voltage
- Efficiency calculation

### Acceptance Criteria
- Output voltage: -12V ± 5%
- Voltage ripple: < 200 mV p-p
- Inductor current: 6.25A ± 10%
- Efficiency: > 90%
- No thermal shutdown
- Stable operation under load variations

---

**Note:** All values assume operation at room temperature (25°C). Derate components appropriately for higher ambient temperatures.

**Revision:** 1.0
**Date:** November 2025
**Status:** Design Specification
