# Hospitalization Impact
 Currently holding codes for the impact of knowledge of hospitalization on mortality predictions project
 
 ## Repository Structure
```
├── Code                          # Folder for all results generating codes
|   ├── Main_Fun.R                # Code running large scale simulations
|   ├── Sim_functions.R           # Code generating accuracy and lose metrics for logistic and XGB
|   ├── Stable Simulation.R       # Demonstrate stable improvement for two parts model
|   ├── Helper.R                  # Necessary helper functions 
|   └── Senarios.R                # Code running scenarios described in the paper
├── .gitignore                    # Contains files not push
├── Result                        # Simulation Results
└── README.md                     # Readme file
``` 
## Sim_functions
There are two main functions in the Sim_functions file. The first function `logistic_auc`takes two arguments: dataframe and split ratio. The default for split ratio is 0.8 which corresponded to a five folds validation schedule. The function will be able to randomly split the dataset into test and train sets and train both one part and two parts logistirc regression models using the train set and evaluate predictive accuracy on the test set (AUC, Entropy loss and Brier loss). To track whether the model experienced overfitting and whether the death-live ratio is reasonable, the function will also produce trainning AUC and simulated death-live ratio. Logistic regression coefficients for both one part and two parts model were included in the output for analysis. The second function `xgb_auc` similarly takes two arguments: dataframe and split ratio. This function trains XGBoost models under one part and two parts specification. Likewsie, predictive accuracy inlcuding AUC, Entropy loss and brier loss, as well as training accuracy were included in the output.

## Main_Fun
There is only one function in the Main_Fun file. The `Simulation` function was created to handle large scale simulation with flexible specification. Since the original paper only considered two parts effect of hospitalization factor, this function allowed the user to put two different values to emulate the heterogeous effect of the hospitalization factor. Other covariates can be specified using the syntax `cov = a` where `cov` can be any variable name and `a` can be any numeric values. Note that the value of coefficients are possitively correlated with the number of incidence. Therefore, a value that is too large might lead to no survivors in the second stage, stoping the simulation. One can also specify the number of patients in each iteration and the number of iterations desired.

## Stable Simulation
Develop scenarios in which the two-part model consistently outperforms the one-part model. The key modifications to the original simulation include:1, Increasing the proportion of hospitalized patients with a higher short-term mortality rate. 2, Introducing variability by adding white noise to each stage’s probability. 3, Incorporating additional time-dependent variables. A plot function is also included to show the results. 

## Helper
Currently holds the helper functions for loss functions and list output.

## Senarios
An example codes to run the senarios mentioned in the original paper. We can have either uniform effects or reversed effects for hospitalization factor. Larger number of patients and iterations were performed under each senario in order to test consistency.

## Results folder
Holding current results from simulations.
