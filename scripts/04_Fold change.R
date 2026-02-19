# Load libraries
library(tidyverse)

# === Load data ===
df <- read_csv("Pre Post T.Csv")

# Check column names (fix if needed)
colnames(df)[1:2] <- c("Sample", "Group")

# === Convert to long format ===
df_long <- df %>%
  pivot_longer(cols = -c(Sample, Group), names_to = "Metabolite", values_to = "Intensity")

# === Compute mean per group per metabolite ===
group_means <- df_long %>%
  group_by(Metabolite, Group) %>%
  summarise(mean_intensity = mean(Intensity, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = Group, values_from = mean_intensity)

# === Calculate log2 Fold Change ===
fc_table <- group_means %>%
  mutate(
    log2FC = log2(Post / Pre),
    FoldChange = Post / Pre
  ) %>%
  select(Metabolite, Pre, Post, FoldChange, log2FC)

# === Save results to CSV ===
write_csv(fc_table, "fold_change_results.csv")

# Optional: Show top changes
fc_table %>%
  arrange(desc(abs(log2FC))) %>%
  head(10)
