Last Edited: 6/21/20

Hello! 

This is a README for my file "Huque_SFR_script.R". 

Before running the script, please ensure that you have the file "thesis-data.csv" in the correct place. This script runs it using the `here` package and assumes that it is in a folder entitled `DATA`. 

After running the script, there will be SEVEN data frames in the environment and ONE .htm file. The .htm file is called `Huque_SFR_final.htm` and provides the results of the model in a format common in publications. It can be opened in a browser or as a word document. 

Below is a summary of the seven dataframes the script outputs. 

1. thesis_data

      Class: dataframe
      Rows: 34,661
      Observations: 195
      About: Thesis data of all property types (single family, multifamily, mixed use, etc)
      
      
2. SFR_raw

      Class: dataframe
      Rows: 25,266
      Observations: 195
      About: A subset from `thesis_data` that only contains SFR observations. Note this data is not cleaned and includes non-arms length transactions. 
      
      
3. SFR_dat

      Class: dataframe
      Rows: 22,960
      Observations: 77
      About: Final cleaned dataframe that is used to run model specification on. Note that the BPS folder also has this dataset exported to a csv called `Huque_SFR_dat.csv`. 
      
      
4. SFR_controls_table

      Class: dataframe
      Rows: 32
      Observations: 7
      About: Summary statistics for the controls from `SFR_controls_dat`. Gives the mean, median, standard deviation, minimum, maximum, and number of missing observations for each variable. For each summary statistic missing observations have been omitted. This table was created from the `SFR_controls_dat` dataset, which is created and then removed in the SFR script. 


5. SFR_constraints_table

      Class: dataframe
      Rows: 26
      Observations: 4
      About: Counts for each of the constraints from `SFR_dat`. 


6. SFR_final.mod

      Class: lm
      About: An lm object containing the results of the final model. For standard errors and p-values, run the following command: summary(SFR_final.mod)
      

7. SFR_final.coef

      Class: dataframe
      Rows: 45
      Observations: 3
      About: Dataframe with coefficients pulled from `SFR_final.mod`. The third column (`percent_effect`) is the most important; the raw coefficient in second column (`coef`) cannot be used to make claims pertaining to sale price. When using the interpreted coefficient, you can say something like this: "Having a property located in a preservation zone decreases the sale price of the house by 3.8%". 


Additional dataframes are created in the script that may be useful. They are removed at the end of the script, so if you want to use them, do not run those lines. 






