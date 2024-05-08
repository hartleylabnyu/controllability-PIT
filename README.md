
# con_pit

## Description

**Adolescents flexibly adapt action selection based on controllability inferences**

This repository contains tasks, anonymized data, and analysis code for the study: Raab, H.A.+, Goldway, N.+, Foord, C., & Hartley, C.A. (2024). [Adolescents flexibly adapt action selection based on controllability inferences.](https://learnmem.cshlp.org/content/31/3/a053901.abstract) *Learning & Memory.*

## Task

We conducted experiments involving 90 participants aged 8-27, who performed a probabilistic Go/No-Go learning task in both controllable and uncontrollable environments.

## Data

Raw data used for regression analysis and reinforcement-learning modeling, stored in MATLAB files (.mat), can be found in the "data" folder.

## Analysis Code

Data analysis was conducted in R using the R Markdown analysis script located in the "Con_pit_analysis_main" folder. Additionally, code for reinforcement learning modeling can be found in the "computational_modeling_code" folder, with the main script named "Main_fitting_code.m."

## Computational Modeling

The computational models were fitted using the "fmincon" function from the Optimization Toolbox in MATLAB 2023a.

