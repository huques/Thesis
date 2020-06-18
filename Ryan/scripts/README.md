Last Edited: 6/17/20

The RMD file big-clean produces the SFR and MFR data frames and generate-figures.rmd produces all tables and figures (aside from maps) used in the body of the thesis. 

I. BIG-CLEAN.RMD

1. sfr-cleaned.csv

      Class: dataframe
      Rows: 22,433
      Columns: 39
      About: Complete cases, cleaned SFR data.
      
      
2. mfr-cleaned.csv

      Class: dataframe
      Rows: 3,102
      Observations: 41
      About: Complete cases, cleaned MFR data. 
      
      
II. GENERATE-FIGURES.RMD

All html tables generated in this rmd are output to the directory Ryan/figs/tables/html-tables.

------------------
Summary statistics
------------------
1. sfr-sum-stats.htm

      Class: dataframe
      Rows: 32
      Observations: 7
      About: Summary statistics for the controls from `SFR_controls_dat`. Gives the mean, median, standard deviation, minimum, maximum, and number of missing observations for each variable. For each summary statistic missing observations have been omitted. 
      
      
2. mfr-sum-stats.htm

      Class: dataframe
      Rows: 22,959
      Observations: 76
      About: Final cleaned dataframe that is used to run model specification on. 
      
      
3. price-sum-stats.htm

      Class: dataframe
      Rows: 22,959
      Observations: 33
      About: A subset from`SFR_dat`that only contains the control variables. Used to create summary statistics. 
      
--------------------------------      
VIF - Variance Inflation Factor
--------------------------------    
1. mfr-vif.htm

      Class: dataframe
      Rows: 7
      Columns: 5
      About: Top 6 variance inflated variables with their degrees of freedom and GVIFs for the MFR constraints + neighborhood fixed effects model. 

2. mfr-vif-quad.htm

      Class: dataframe
      Rows: 40
      Columns: 5
      About: Top 39 variance inflated variables with their degrees of freedom and GVIFs for the MFR constraints + quadrant fixed effects model. 

3. sfr-vif.htm

      Class: lm
      Rows: 21
      Columns: 5
      About: Top 20 variance inflated variables with their degrees of freedom and GVIFs for the SFR constraints + neighborhood fixed effects model. 

------------------
Regression tables
------------------
1. sfr-results-controls.htm

      Class: lm list
      Rows: 33
      Columns: 8
      About: Regression table with coefficients, standard errors, R squared, R squared adjusted, AIC, BIC, from 7 models - baseline, quadrant fixed effects, neighborhood FE, baseline & constraints, quadrant FE & constraints, neighborhood FE & constraints, and neighborhood random effects & constraints. FE and constraint coefficients not included.
      
2. sfr-results-constraints.htm

      Class: lm list
      Rows: 31
      Columns: 5
      About: Regression table with oefficients, standard errors, R squared, R squared adjusted, AIC, BIC, from 7 models - baseline, quadrant fixed effects, neighborhood FE, baseline & constraints, quadrant FE & constraints, neighborhood FE & constraints, and neighborhood random effects & constraints. FE and control coefficients not included.

3. sfr-full-results.htm

      Class: lm list
      Rows: 143
      Columns: 8
      About: SFR regression table with coefficients, standard errors, R squared, R squared adjusted, AIC, BIC, from 7 models - baseline, quadrant fixed effects, neighborhood FE, baseline & constraints, quadrant FE & constraints, neighborhood FE & constraints, and neighborhood random effects & constraints. All variables included. 

4. mfr-results-controls.htm

      Class: lm list
      Rows: 30
      Columns: 8
      About: MFR regression table with coefficients, standard errors, R squared, R squared adjusted, AIC, BIC, from 7 models - baseline, quadrant fixed effects, neighborhood FE, baseline & constraints, quadrant FE & constraints, neighborhood FE & constraints, and neighborhood random effects & constraints. FE and constraint coefficients not included (but used in the fit).
      
5. mfr-results-constraints.htm

      Class: lm list
      Rows: 27
      Columns: 5
      About: MFR regression table with coefficients, standard errors, R squared, R squared adjusted, log likelihood, AIC, BIC, residual std. error, F statistic from 7 models - baseline, quadrant fixed effects, neighborhood FE, baseline & constraints, quadrant FE & constraints, neighborhood FE & constraints, and neighborhood random effects & constraints. FE and control coefficients not included (but used in the fit).

6. mfr-full-results.htm

      Class: lm list
      Rows: 137
      Columns: 8
      About: MFR regression table with coefficients, standard errors, R squared, R squared adjusted, log likelihood, AIC, BIC, residual std. error, F statistic from 7 models - baseline, quadrant fixed effects, neighborhood FE, baseline & constraints, quadrant FE & constraints, neighborhood FE & constraints, and neighborhood random effects & constraints. All variables included.


III. cv.R

IV. map-autocorrelation.R

Produces the maps used in the body of the thesis. 

V. sar-mods.R

First attempt at playing with spatial autoregressive models. 




