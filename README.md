# 3D Molecular Dynamics with Lennard-Jones Potential (MATLAB)

Molecular dynamics simulation of a system of argon-like particles in a cubic
box with periodic boundary conditions. The particles interact through the
Lennard-Jones potential, and the equations are solved in **reduced units**
(dimensionless).

The script computes the time evolution of the energies, temperature, center of
mass velocity and pressure, and estimates the statistical error of each
quantity with a **block analysis**.

## Physical model

Lennard-Jones potential between each pair of particles:

    U(r) = 4ε · [ (σ/r)¹² − (σ/r)⁶ ]

System parameters (argon):

| Quantity | Value |
|---|---|
| Molar mass `A` | 0.039948 kg/mol |
| Density | 1680 kg/m³ |
| Temperature `To` | 120 K |
| `σ` | 3.4·10⁻¹⁰ m |
| `ε` | `k_B · To` |

Non-dimensionalization: lengths in units of `σ`, energies in `ε` and time in
`σ·√(m/ε)`. The box then has side `La = L/σ` and the reduced time step is
`dta = dt·√(ε/(m·σ²))`.

## What it does

- **Periodic boundary conditions:** minimum image convention to compute the
  distance between each pair of particles, with cutoff radius `rc = La/2`.
- **Force computation** between all pairs of particles.
- **Explicit time integration** of positions and velocities.
- **Measurements** at every step:
  - Kinetic, potential and total energy
  - Temperature
  - Center of mass velocity
  - Pressure
- **Resuming:** the state is saved to `simulation.mat` at every step and can be
  resumed from the initial menu.
- **Configurable visualization** (menu): 3D images of the particles, plots of
  the measured quantities, both, or none.
- **Block analysis** (`analisisPorBloques`): estimates the variance of each
  quantity for different block sizes (powers of 2) and plots it on a
  logarithmic scale.

## Usage

1. Open MATLAB and move to the project folder.
2. Run `dinamicamolecular1`.
3. Choose the mode:
   - **New simulation:** creates the system from scratch.
   - **Resume existing simulation:** continues from `simulation.mat`.
4. Choose the visualization type.

Each run advances `niter = 101` time steps. For longer simulations, run the
script again in *Resume* mode.

### Main parameters

Edit them at the top of the script:

| Variable | Default | Meaning |
|---|---|---|
| `n` | 85 | Number of points per edge of the initial grid |
| `dens` | 1680 | Density (kg/m³) |
| `To` | 120 | Temperature (K) |
| `dt` | 1e-14 | Time step (s) |
| `niter` | 101 | Steps per run |
| `s` (σ) | 3.4e-10 | Lennard-Jones length parameter (m) |

## Generated files

| File | Contents |
|---|---|
| `simulation.mat` | Simulation state (positions, velocities, measurements) |
| `posicioninicial.png` | Initial positions of the particles |
| `posiciont=<t>.png` | Snapshots of the positions every 250 steps |
| `Fotos/varianza_<quantity>.png` | Block analysis plots |

The block analysis also prints tables in the console with the variance and the
standard deviation for each block size.

<img width="425" height="750" alt="medidas1cort" src="https://github.com/user-attachments/assets/89df8ebe-c772-4468-9fec-b324d89ed2ec" />

<img width="425" height="750" alt="medidas2cort" src="https://github.com/user-attachments/assets/cd830910-b1f6-48bc-873d-120886f85c62" />

<img width="425" height="300" alt="posicioninicial" src="https://github.com/user-attachments/assets/a7c124b9-40f2-49bb-b79d-19b6c6217992" />

<img width="425" height="300" alt="posiciont=4500" src="https://github.com/user-attachments/assets/b7f27e57-faf7-46cc-bedf-f75b3739a7b0" />


## Requirements

- MATLAB R2017b or later
