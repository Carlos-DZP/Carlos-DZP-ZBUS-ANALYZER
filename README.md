# ZBUS-ANALYZER
*An interactive, step-by-step matrix construction environment for power system impedance analysis using native MATLAB architectures.*

[![MATLAB](https://img.shields.io/badge/MATLAB-App_Designer_Components-blue.svg)](https://www.mathworks.com/products/matlab.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Academic](https://img.shields.io/badge/Status-Academic_Research-success.svg)]()
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.20711215.svg)](https://doi.org/10.5281/zenodo.20711215) ## Description
**ZBUS-ANALYZER** is an open-source, MATLAB-based interactive environment designed for the algorithmic construction and analysis of the Bus Impedance Matrix ($Z_{bus}$) in Electric Power Systems (EPS). Developed at the Instituto Tecnológico de Pachuca, this tool automates the traditional direct building algorithm, providing step-by-step case logging, dynamic network topology rendering, and automatic Kron reduction for closed loops.

---

## Key Features (Analysis Phases)

The script processes power system branch data through an automated, interactive workflow divided into 4 core execution stages:

* **Phase I: Dynamic Topology Rendering.** Real-time graphical visualization of the power network utilizing MATLAB's native `graph` and `plot` engines. The layout automatically emphasizes the **Reference Node (0)** using a distinctive red square marker for rapid visual verification of network grounding.
* **Phase II: Algorithmic Case Identification.** Automatic inspection of input branch data ($R + jX$) to identify and execute the specific condition of the direct building algorithm:
    * **Case 1:** Adding a new branch from the reference node (0) to a new bus.
    * **Case 2:** Adding a new branch from an existing bus to a new bus.
* **Phase III: Kron Reduction Engine.** Advanced modification of the matrix structure when a loop or link is introduced to the system (Cases 3 and 4). The software creates an auxiliary row/column and eliminates the dummy node automatically using the analytical Kron reduction formula:
    $$Z_{new} = Z - \frac{\Delta Z \cdot \Delta Z^T}{Z_{pp}}$$
* **Phase IV: Resolution & Case Logging.** A live text-area terminal outputs comprehensive state messages for each branch added, keeping an audit trail of the mathematical modifications. The final complex-valued matrix is formatted and mapped onto an interactive data table with precise row and column labels.

---

## System Requirements
* **MATLAB** (R2020b or higher recommended, due to the native use of `uifigure` and `uigridlayout` layout containers).
* **Toolboxes Required:** Standard MATLAB installation (No external toolboxes required; features leverage built-in GUI components and graph-theory functions).

---

## Technical Architecture & Memory Management
To maintain standard programming practices within procedural scripts, the tool is engineered with a strict **AppData memory structure** instead of relying on risky global variables:
* `branchData` is stored directly inside the main figure handle using `setappdata(fig, 'branchData', ...)`, isolating structural network information `[From_Node, To_Node, R, X]` from the local workspace.
* Data alerts and topology consistency are enforced via robust input validation routines (preventing isolated subnetworks/islands, negative node values, self-loops, and zero-impedance inputs).

---

## Installation and Quick Start

1. **Clone the repository:**
    ```bash
    git clone [https://github.com/Carlos-DZP/Carlos-DZP-ZBUS-ANALYZER.git](https://github.com/Carlos-DZP/Carlos-DZP-ZBUS-ANALYZER.git)
    ```
2. **Set up MATLAB:**
    Open MATLAB, navigate to the downloaded repository directory, and add the folder to your working path.
3. **Run the tool:**
    Execute the main script via the Command Window:
    ```matlab
    run('Analizador Code_Zbus.m')
    ```
4. **Workflow:**
    * Input the origin node (**From Bus**) and destination node (**To Bus**). *(Note: Node (0) is strictly treated as the system reference).*
    * Enter the branch parameters in per-unit (**R (p.u.)** and **X (p.u.)**) and click **"Add Impedance to Network"**.
    * Once all system components are visible in the **Topology Area**, click the green **"CALCULATE Z-BUS MATRIX"** button to trigger the algorithm and populate the complex matrix.
---
## Authors and Citation
Project developed at the **Tecnológico Nacional de México (Instituto Tecnológico de Pachuca)**, Department of Electrical and Electronic Engineering.

**Developer:**
* Zamora Pérez Carlos Daniel

**Academic Advisor:**
* Ordaz Oliver Mario Oscar

If this project is useful for your research or academic work, please consider citing it:

> Zamora-Pérez, C.D., & Ordaz-Oliver, M.O. (2026). *ZBUS-ANALYZER: An interactive MATLAB-based environment for algorithmic building of the Bus Impedance Matrix in Power Systems (v1.0.1)*. Zenodo. https://doi.org/10.5281/zenodo.14494951
