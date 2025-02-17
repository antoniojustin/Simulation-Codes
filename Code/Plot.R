results <- Logistic_results %>%
          mutate(AUC_Diff = -(AUC_TwoPart - AUC_OnePart) / AUC_TwoPart * 100,
                 Brier_Diff = -(Brier_TwoPart - Brier_OnePart) / Brier_TwoPart * 100,
                 Entropy_Diff = -(Entropy_TwoPart - Entropy_OnePart) / Entropy_TwoPart * 100)

# Convert B to a factor for proper grouping in visualization
results$B <- as.factor(results$B)

ggplot(results, aes(x = B)) +
  geom_jitter(aes(y = AUC_Diff, color = "AUC Diff"), width = 0.2, alpha = 0.5) +
  geom_jitter(aes(y = Brier_Diff, color = "Brier Diff"), width = 0.2, alpha = 0.5) +
  geom_jitter(aes(y = Entropy_Diff, color = "Entropy Diff"), width = 0.2, alpha = 0.5) +
  labs(title = "Percent Difference Between Two-Part and One-Part Models (XGB)",
       x = "B", y = "Percent Difference (%)") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray") +
  theme_minimal() +
  scale_color_manual(name = "Metric", values = c("AUC Diff" = "blue", 
                                                 "Brier Diff" = "red", 
                                                 "Entropy Diff" = "green"))