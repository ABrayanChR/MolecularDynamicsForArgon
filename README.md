# Dinámica molecular 3D con potencial de Lennard-Jones (MATLAB)

Simulación de dinámica molecular de un sistema de partículas tipo argón en
una caja cúbica con condiciones periódicas de contorno. Las partículas
interactúan mediante el potencial de Lennard-Jones y las ecuaciones se
resuelven en **unidades reducidas** (adimensionales).

El script calcula la evolución temporal de las energías, la temperatura, la
velocidad del centro de masas y la presión, y estima el error estadístico de
cada magnitud con un **análisis por bloques**.

## Modelo físico

Potencial de Lennard-Jones entre cada par de partículas:

    U(r) = 4ε · [ (σ/r)¹² − (σ/r)⁶ ]

Parámetros del sistema (argón):

| Magnitud | Valor |
|---|---|
| Masa molar `A` | 0.039948 kg/mol |
| Densidad | 1680 kg/m³ |
| Temperatura `To` | 120 K |
| `σ` | 3.4·10⁻¹⁰ m |
| `ε` | `k_B · To` |

Adimensionalización: longitudes en unidades de `σ`, energías en `ε` y tiempo
en `σ·√(m/ε)`. Con ello, la caja tiene lado `La = L/σ` y el paso temporal
reducido es `dta = dt·√(ε/(m·σ²))`.

## Qué hace

- **Condiciones periódicas:** convención de la imagen mínima para calcular la
  distancia entre cada par de partículas, con radio de corte `rc = La/2`.
- **Cálculo de fuerzas** entre todos los pares de partículas.
- **Integración temporal** explícita de posiciones y velocidades.
- **Medidas** en cada paso:
  - Energía cinética, potencial y total
  - Temperatura
  - Velocidad del centro de masas
  - Presión
- **Reanudación:** el estado se guarda en `simulation.mat` en cada paso y se
  puede retomar desde el menú inicial.
- **Visualización** configurable (menú): imágenes 3D de las partículas,
  gráficas de las magnitudes, ambas o ninguna.
- **Análisis por bloques** (`analisisPorBloques`): estima la varianza de cada
  magnitud para distintos tamaños de bloque (potencias de 2) y la representa
  en escala logarítmica.

## Uso

1. Abre MATLAB y sitúate en la carpeta del proyecto.
2. Ejecuta `dinamicamolecular1`.
3. Elige el modo:
   - **Nueva simulación:** crea el sistema desde cero.
   - **Retomar simulación existente:** continúa desde `simulation.mat`.
4. Elige el tipo de visualización.

Cada ejecución avanza `niter = 101` pasos de tiempo. Para simulaciones más
largas, vuelve a ejecutar el script en modo *Retomar*.

### Parámetros principales

Se editan al inicio del script:

| Variable | Valor por defecto | Significado |
|---|---|---|
| `n` | 85 | Número de puntos por arista de la malla inicial |
| `dens` | 1680 | Densidad (kg/m³) |
| `To` | 120 | Temperatura (K) |
| `dt` | 1e-14 | Paso temporal (s) |
| `niter` | 101 | Pasos por ejecución |
| `s` (σ) | 3.4e-10 | Parámetro de longitud de Lennard-Jones (m) |

## Archivos generados

| Archivo | Contenido |
|---|---|
| `simulation.mat` | Estado de la simulación (posiciones, velocidades, medidas) |
| `posicioninicial.png` | Posiciones iniciales de las partículas |
| `posiciont=<t>.png` | Instantáneas de las posiciones cada 250 pasos |
| `Fotos/varianza_<magnitud>.png` | Gráficas del análisis por bloques |

El análisis por bloques también imprime en la consola tablas con la varianza y
la desviación estándar para cada tamaño de bloque.

<img width="425" height="750" alt="medidas1cort" src="https://github.com/user-attachments/assets/89df8ebe-c772-4468-9fec-b324d89ed2ec" />

<img width="425" height="750" alt="medidas2cort" src="https://github.com/user-attachments/assets/cd830910-b1f6-48bc-873d-120886f85c62" />

<img width="425" height="300" alt="posicioninicial" src="https://github.com/user-attachments/assets/a7c124b9-40f2-49bb-b79d-19b6c6217992" />

<img width="425" height="300" alt="posiciont=4500" src="https://github.com/user-attachments/assets/b7f27e57-faf7-46cc-bedf-f75b3739a7b0" />


## Requisitos

- MATLAB R2017b o superior
