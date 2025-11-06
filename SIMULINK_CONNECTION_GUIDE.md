# EXACT SIMULINK CONNECTION GUIDE - STEP BY STEP

## How to Connect Blocks in Simulink

### Basic Connection Method:
1. **Hover** over the small triangle/port on a block
2. **Click and HOLD** mouse button
3. **Drag** to the destination block's port
4. **Release** mouse button
5. A line appears connecting them!

---

## POWER CIRCUIT CONNECTIONS (Do These in Order)

### Connection 1: DC Source to Inductor
```
┌──────────────┐
│  DC_Source   │
│      +       │───────→ (Click here, drag to Inductor left side)
│      -       │
└──────────────┘

                        ┌──────────────┐
                        │   Inductor   │
    (Release here) →───→├──────────────┤
                        └──────────────┘
```

**How to do it:**
1. Click on the **+** terminal of DC_Source
2. Hold mouse button down
3. Drag to the **left side** of Inductor block
4. Release
5. A line appears!

---

### Connection 2: Inductor to MOSFET Drain

```
┌──────────────┐                    ┌──────────────┐
│   Inductor   │                    │   MOSFET     │
│              │────────────────────→│   D (Drain)  │
└──────────────┘                    │   G (Gate)   │
                                    │   S (Source) │
                                    └──────────────┘
```

**How to do it:**
1. Click on **right side** of Inductor
2. Drag to **D (Drain)** terminal of MOSFET
3. Release

---

### Connection 3: PWM Generator to MOSFET Gate

```
┌─────────────────┐
│ PWM_Generator   │
│     [output]    │────┐
└─────────────────┘    │
                       │
                       │         ┌──────────────┐
                       │         │   MOSFET     │
                       │         │   D (Drain)  │
                       └────────→│   G (Gate)   │← Connect here!
                                 │   S (Source) │
                                 └──────────────┘
```

**How to do it:**
1. Click on output of PWM_Generator (right side)
2. Drag to **G (Gate)** terminal of MOSFET
3. Release

---

### Connection 4: MOSFET Source to Ground

```
                       ┌──────────────┐
                       │   MOSFET     │
                       │   D (Drain)  │
                       │   G (Gate)   │
                       │   S (Source) │───┐
                       └──────────────┘   │
                                          │
                                          ↓
                                    ┌──────────┐
                                    │  Ground2 │
                                    │    ⏚     │
                                    └──────────┘
```

**How to do it:**
1. Click on **S (Source)** terminal of MOSFET
2. Drag down to **Ground2** block
3. Release

---

### Connection 5: DC Source Negative to Ground

```
┌──────────────┐
│  DC_Source   │
│      +       │
│      -       │────┐
└──────────────┘    │
                    │
                    ↓
              ┌──────────┐
              │  Ground1 │
              │    ⏚     │
              └──────────┘
```

**How to do it:**
1. Click on **-** terminal of DC_Source
2. Drag to **Ground1** block
3. Release

---

### Connection 6: Diode Connections

**IMPORTANT: Diode has two terminals:**
- **K** = Cathode (marked with line, like |>)
- **A** = Anode (arrow side, like >|)

```
        Switching Node (where Inductor and MOSFET Drain meet)
              │
              │     ┌──────────────┐
              └────→│   Diode      │
                    │   K (Cathode)│
                    │   A (Anode)  │───→ To DC_Source (-)
                    └──────────────┘
```

**How to do it:**
1. Click on **K (Cathode)** of Diode
2. Drag to the **same point** where Inductor connects to MOSFET Drain
   - This creates a junction (3-way connection)
3. Click on **A (Anode)** of Diode
4. Drag to **DC_Source (-)** terminal
5. Release

---

### Connection 7: Output Capacitor

```
From Diode Cathode ─→ ┌──────────────┐
                      │  Output_Cap  │
                      │      +       │
                      │      -       │─→ Ground3
                      └──────────────┘
```

**How to do it:**
1. Click on **+** of Output_Cap
2. Drag to **Diode K (Cathode)** (same junction point)
3. Click on **-** of Output_Cap
4. Drag to **Ground3**
5. Release

---

### Connection 8: Load Resistor

```
From Diode Cathode ─→ ┌──────────────┐
  (parallel with Cap) │     Load     │
                      │      +       │
                      │      -       │─→ Ground3
                      └──────────────┘
```

**How to do it:**
1. Click on **+** of Load
2. Drag to same point as Output_Cap + (the junction)
3. Click on **-** of Load
4. Drag to **Ground3** (same as capacitor ground)
5. Release

---

## MEASUREMENT CONNECTIONS (Optional but Recommended)

### Current Measurement (Inductor Current)

**Insert IL_Measure BETWEEN Inductor and MOSFET:**

```
BEFORE:
Inductor ────────→ MOSFET Drain

AFTER:
Inductor ───→ IL_Measure (+) ───→ IL_Measure (-) ───→ MOSFET Drain
```

**How to do it:**
1. **DELETE** the existing line between Inductor and MOSFET
   - Click on the line, press Delete key
2. Click Inductor right side → Drag to IL_Measure **+** terminal
3. Click IL_Measure **-** terminal → Drag to MOSFET Drain

---

### Voltage Measurement (Output Voltage)

```
                    ┌──────────────────┐
        Junction ──→│  Vout_Measure    │
        (Output)    │        +         │
                    │        -         │─→ Connect to Ground3
                    └──────────────────┘
```

**How to do it:**
1. Click **+** of Vout_Measure
2. Drag to output junction (where Cap and Load connect)
3. Click **-** of Vout_Measure
4. Drag to **Ground3**

---

## FINAL CIRCUIT SHOULD LOOK LIKE THIS:

```
        ┌────────┐
        │DC Source│
        │   24V   │
        └─┬────┬──┘
          +    -
          │    │
          │    └───────────────┐
          │                    │
       ┌──▼────┐            ┌──▼────┐
       │Inductor│            │Ground1│
       │ 320µH  │            └───────┘
       └───┬────┘
           │
           │ (Switching Node - 3-way junction)
           ├──────────┬──────────┐
           │          │          │
        ┌──▼──┐    ┌──▼──┐   ┌──▼────┐
        │MOSFET│   │Diode│   │Output │
        │  D   │   │  K  │   │  Cap  │
        │  G◄──┼───┤PWM  │   │ 330µF │
        │  S   │   │  A  │   └───┬───┘
        └──┬───┘   └──┬──┘       │
           │          │          │
        ┌──▼────┐  ┌──▼────┐ ┌──▼────┐
        │Ground2│  │Source-│ │  Load │
        └───────┘  └───────┘ │ 2.88Ω │
                             └───┬───┘
                                 │
                              ┌──▼────┐
                              │Ground3│
                              └───────┘
```

---

## TIPS FOR MAKING CONNECTIONS

### Creating a Junction (3-way connection):
When you need multiple wires to connect to one point:
1. Connect first wire normally
2. **Hold Ctrl** key (Windows/Linux) or **Cmd** key (Mac)
3. Click on the existing line
4. Drag to new destination
5. This creates a branch!

### If Connection Doesn't Work:
- Make sure you're clicking on the **port** (small triangle/circle)
- Not all sides of blocks have ports
- Look for the small connector symbols

### To Delete a Connection:
1. Click on the line (it turns blue)
2. Press **Delete** key

### To Move Blocks:
- Click and drag the block (not the ports)
- Arrange them so connections are clear

---

## QUICK CHECKLIST ✓

After making connections, verify:
- [ ] DC_Source + connects to Inductor
- [ ] Inductor connects to MOSFET Drain
- [ ] PWM connects to MOSFET Gate
- [ ] MOSFET Source connects to Ground
- [ ] Diode Cathode connects to switching node
- [ ] Diode Anode connects to DC_Source -
- [ ] Output_Cap and Load connect in parallel to output
- [ ] All grounds are connected
- [ ] No red error icons on any blocks

---

## NOW RUN THE SIMULATION!

1. Click **▶ Run** button in toolbar
2. Wait for "Ready" in status bar
3. Double-click **Vout_Scope** to see output voltage!
4. Double-click **IL_Scope** to see inductor current!
5. Double-click **Gate_Scope** to see PWM signal!

**You should see waveforms appear in the scopes!** 🎉
