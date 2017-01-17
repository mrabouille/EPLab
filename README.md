# EPLab
EnergyPlus Laboratory for Sensitivity and Uncertainty Analysis in Building Energy Modeling

[![DOI](https://zenodo.org/badge/20752/mrabouille/EPLab.svg)](https://zenodo.org/badge/latestdoi/20752/mrabouille/EPLab)

The tool proposes:
- Simple statistical definition of the inputs
- Complex modification of the simulation file (idf)
- Simulation and extraction of the results
- Results management (by zone, orientation ...) and export
- Visualization of the behavior (outputs vs inputs, outputs vs outputs for optimization purpose)
- Perform SA among a set of methods: RBD-FAST SOBOL PCE

## Quick Start
run EPLab.m and select a config file \*config.m (for exemple NREL_Case610config.m file in testFiles folder). This file is configured to run with version 8.3 , 8.4 or 8.5 of [EnergyPlus](https://github.com/NREL/EnergyPlus/releases) that has to be installed in the C:\ directory.
