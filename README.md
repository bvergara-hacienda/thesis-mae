# Estimation of a Prudent Public Debt Level for Chile

MATLAB code for my Master's thesis **"Estimación de un Nivel Prudente de Deuda Pública en Chile"** (MSc in Applied Economics, Pontificia Universidad Católica de Chile, December 2022), developed in collaboration with Chile's Autonomous Fiscal Council (CFA).

The model estimates a *prudent* public debt level — a candidate debt ceiling for a dual fiscal rule — using the **maximum feasible primary balance (MFPB)** methodology of Eyraud et al. (2018), built on the stochastic debt-simulation framework of Celasun, Debrun & Ostry (2006):

1. A restricted **VAR** (estimated by FGLS) captures the joint dynamics of non-fiscal variables: domestic and US real interest rates, real effective exchange rate, real GDP growth, and the terms of trade.
2. A **fiscal reaction function** (estimated separately on a panel of 105 countries, 1985–2020) maps debt, the output gap, the terms-of-trade gap, and demographic variables into the primary balance.
3. The **debt accumulation equation** links both blocks. 5,000 Monte Carlo simulations produce fan charts for debt and the primary balance over a 25-year horizon.
4. The prudent debt level is the highest initial debt ratio such that at most 5% of simulated trajectories exceed the MFPB (calibrated at 5.5% of GDP for Chile). The baseline estimate is **51% of GDP**.

## Repository structure

```
├── main/
│   ├── main.m                        # entry point: runs the full pipeline
│   ├── prepare_sample.m              # loads data, interpolates demographic paths
│   ├── var_estimation.m              # unrestricted VAR (OLS)
│   ├── var_estimation_restricted.m   # restricted VAR (FGLS), baseline
│   ├── var_simulation.m              # Monte Carlo simulation of non-fiscal variables
│   ├── point_forecasts.m             # VAR point forecasts
│   ├── fiscal_simulation.m           # debt & primary-balance trajectories
│   ├── fiscal_simulation_theta.m     # extension: endogenous risk premium (default risk)
│   ├── run_theta_sensitivity.m       # sensitivity grid over (alpha, theta)
│   ├── prob_default.m                # default-probability interpolation (Akima)
│   ├── debt_ss.m                     # analytical steady-state debt & comparative statics
│   └── plot_*.m                      # figures (fan charts, fitted values, scenarios)
├── utilities/                        # helper functions (vec, shadedplot)
└── data/
    ├── base var.xlsx                 # quarterly non-fiscal variables (see sources below)
    └── age_dependency.xlsx           # UN age-dependency ratios and projections
```

## Requirements

- MATLAB R2019b or later (base MATLAB plus the Statistics and Machine Learning Toolbox for `tcdf`).
- No additional packages required; helper functions are included in `utilities/`.

## How to run

Open MATLAB and run:

```matlab
cd main
main
```

`main.m` runs the full pipeline (sample preparation, VAR estimation and simulation, fiscal simulation) and reproduces the baseline fan charts, plus the two- and three-scenario demographic comparisons. Extensions are run separately after the baseline:

- `run_theta_sensitivity.m` — projections with an endogenous default-risk premium for combinations of risk aversion (α) and recovery rate (θ).
- `debt_ss.m` — analytical steady-state debt level and comparative statics.

The fiscal reaction function coefficients hard-coded in `main.m` come from a Difference-GMM panel estimation (Arellano–Bond) performed in Stata; see the thesis (Section IV and Annexes 3–4) for the full estimation details and robustness checks.

## Data sources

- Central Bank of Chile: quarterly real GDP growth, PDBC 90-day rate.
- IMF International Financial Statistics: real effective exchange rate, US GDP deflator.
- FRED (St. Louis Fed): 3-month US Treasury bill rate.
- IMF World Economic Outlook (April 2022) and Public Finances in Modern History: fiscal panel data.
- UN World Population Prospects / World Bank WDI: age dependency ratios and projections.

## References

Celasun, O., Debrun, X., & Ostry, J. D. (2006). Primary Surplus Behavior and Risks to Fiscal Sustainability in Emerging Market Countries: A "Fan-Chart" Approach. *IMF Staff Papers*, 53(3).

Eyraud, L., Baum, A., Hodge, A., Jarmuzek, M., Kim, Y., Mbaye, S., & Ture, E. (2018). *How to Calibrate Fiscal Rules: A Primer*. IMF Fiscal Affairs Department.

## Author

Benjamín Vergara Martínez — MSc in Applied Economics, Pontificia Universidad Católica de Chile.
Thesis advisors/counterpart: Autonomous Fiscal Council (Juan Urquiza, Bernardita Piedrabuena).
