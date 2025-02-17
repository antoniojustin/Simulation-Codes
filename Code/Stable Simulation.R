# Dependencies 
# Custom functions
source('/Users/antonioqin/Desktop/PhD Work/2.Mortality/2.Paper/Simulation Codes/Codes/Sim_functions.R')
source('/Users/antonioqin/Desktop/PhD Work/2.Mortality/2.Paper/Simulation Codes/Codes/Helper.R')

# Number of individuals:
B_values = c(1000, 10000, 100000, 1000000)

# Coefficiets:
beta_h1 = 1
beta_h2 = -1

# Logs:
Logistic_results <- data.frame(B = integer(), 
                               Run = integer(), 
                               AUC_OnePart = numeric(), 
                               AUC_TwoPart = numeric(),
                               Brier_OnePart = numeric(), 
                               Brier_TwoPart = numeric(),
                               Entropy_OnePart = numeric(), 
                               Entropy_TwoPart = numeric())

XGB_results <- data.frame(B = integer(), 
                               Run = integer(), 
                               AUC_OnePart = numeric(), 
                               AUC_TwoPart = numeric(),
                               Brier_OnePart = numeric(), 
                               Brier_TwoPart = numeric(),
                               Entropy_OnePart = numeric(), 
                               Entropy_TwoPart = numeric())

for (B in B_values) {
  for (run in 1:10) {
    # Variable Simulation:
    hosp0 = c(rep(1, B/4*3), rep(0, B/4)) # Binary
    hosp1 = rnorm(B)   # Continuous
    hosp2 = sample(-5:5, B, replace = TRUE) * 0.1 # Integer, multiply 0.1 cause impact too much
    df = model.matrix( ~ hosp0 + hosp1^2 + hosp2 - 1) # Add square term for more noise
    # This guarantees that stage 1 is around 0.6 and stage 2 is around 0.2 for hospitalized patients
    # Add another predictor that is not observed
    # Do the reverse simulation 
    
    # Outcome simulation:
    #-------------------#
    #-----Stage 1-------#
    #-------------------#
    
    stage_1_prob = 1/(1 + exp(- df %*%  rep(beta_h1, 3) + rnorm(B))) # add noise
    y_1 = rbinom(B, 1, stage_1_prob) 
    # model = glm(death1 ~ hosp, family = binomial())
    
    #-------------------#
    #-----Stage 2-------#
    #-------------------#
    
    idx = which(y_1 == 0)
    stage_2_prob = 1/(1 + exp(- df[idx,] %*%  rep(beta_h2, 3) + rnorm(length(idx)))) # add noise
    death2 = rbinom(length(idx), 1, stage_2_prob)
    
    #-------------------#
    #---All Together----#
    #-------------------#
    
    y_2 = y_1
    y_2[idx] = death2
    data_full <- data.frame(df, y_1 = y_1, y_2 = y_2)
    l = logistic_auc(data_full)
    x = xgb_auc(data_full)
    
    Logistic_results  <- rbind(Logistic_results , data.frame(B = B, 
                                                             Run = run, 
                                                             AUC_OnePart = l[[1]][1], 
                                                             AUC_TwoPart = l[[1]][2],
                                                             Brier_OnePart = l[[6]][3], 
                                                             Brier_TwoPart = l[[6]][4],
                                                             Entropy_OnePart = l[[6]][1], 
                                                             Entropy_TwoPart = l[[6]][2]))
    
    XGB_results  <- rbind(XGB_results , data.frame(B = B, 
                                                   Run = run, 
                                                   AUC_OnePart = x[1], 
                                                   AUC_TwoPart = x[2],
                                                   Brier_OnePart = x[8], 
                                                   Brier_TwoPart = x[9],
                                                   Entropy_OnePart = x[6], 
                                                   Entropy_TwoPart = x[7]))
    
    # Print progress
    print(paste("Run", run, "completed for B =", B))
  }
}

#write.csv(Logistic_results, "Logistic_simulation_results.csv", row.names = FALSE)
#write.csv(XGB_results, "XGB_simulation_results.csv", row.names = FALSE)

Logistic_results <- Logistic_results %>%
  mutate(AUC_Diff = -(AUC_TwoPart - AUC_OnePart) / AUC_TwoPart * 100,
         Brier_Diff = -(Brier_TwoPart - Brier_OnePart) / Brier_TwoPart * 100,
         Entropy_Diff = -(Entropy_TwoPart - Entropy_OnePart) / Entropy_TwoPart * 100)

# Convert B to a factor for proper grouping in visualization
Logistic_results$B <- as.factor(Logistic_results$B)

ggplot(results, aes(x = B)) +
  geom_jitter(aes(y = AUC_Diff, color = "AUC Diff"), width = 0.2, alpha = 0.5) +
  geom_jitter(aes(y = Brier_Diff, color = "Brier Diff"), width = 0.2, alpha = 0.5) +
  geom_jitter(aes(y = Entropy_Diff, color = "Entropy Diff"), width = 0.2, alpha = 0.5) +
  labs(title = "Percent Difference Between Two-Part and One-Part Models (XGB)",
       x = "Number of individuals", y = "Percent Difference (%)") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray") +
  theme_minimal() +
  scale_color_manual(name = "Metric", values = c("AUC Diff" = "blue", 
                                                 "Brier Diff" = "red", 
                                                 "Entropy Diff" = "green"))