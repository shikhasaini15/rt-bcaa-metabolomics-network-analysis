# 📦 Load necessary libraries
library(tidyverse)
library(ggplot2)
library(readr)
library(ggrepel)
library(patchwork)
library(FactoMineR)
library(factoextra)
library(ropls)  # For PLS-DA

# 🧪 Load your data
df <- read_csv("Pre Post T P.csv")

# Ensure the first two columns are properly named
colnames(df)[1:2] <- c("Sample", "Group")

# 🎯 Split into Pre and Post groups
pre_df <- df %>% filter(Group == "Pre") %>% select(-Sample, -Group)
post_df <- df %>% filter(Group == "Post") %>% select(-Sample, -Group)

# ✅ Check that number of Pre and Post samples are equal
if (nrow(pre_df) != nrow(post_df)) {
  stop("Pre and Post groups must have the same number of samples for paired test.")
}

# 🧪 Run paired t-test for each metabolite
results <- map2_dfr(pre_df, post_df, ~{
  test <- t.test(.y, .x, paired = TRUE)
  tibble(
    p_value = test$p.value,
    mean_pre = mean(.x),
    mean_post = mean(.y),
    log2FC = log2(mean(.y + 1e-8) / mean(.x + 1e-8))  # add small value to avoid log(0)
  )
}, .id = "Metabolite")

# 🧪 FDR correction
results <- results %>%
  mutate(p_adj = p.adjust(p_value, method = "fdr")) %>%
  arrange(p_value)

# 💾 Save results
write_csv(results, "paired_t_test_results.csv")

# ✅ View top significant metabolites
print(head(results, 10))


# 📊 Volcano Plot using log2FC and -log10(FDR-adjusted p-value)
results <- results %>%
  mutate(
    neg_log10_fdr = -log10(p_adj)
  )

volcano <- ggplot(results, aes(x = log2FC, y = neg_log10_fdr)) +
  geom_point(aes(color = p_adj), size = 1.5, alpha = 0.8) +
  scale_color_gradient(low = "red", high = "blue", name = "FDR (adjusted p)") +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", color = "gray40") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", color = "gray40") +
  labs(
    #title = "Volcano Plot (log2FC vs -log10(FDR))",
    x = "log2 Fold Change (Post / Pre)",
    y = "–log10(FDR-adjusted p-value)"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "right")

# 💾 Save and display plot
ggsave("volcano_plot_FDR.png", volcano, width = 8, height = 6, dpi = 300)
print(volcano)


# 🧪 PCA (unsupervised analysis)
df_numeric <- df %>% select(-Sample)
pca <- PCA(df_numeric[,-1], graph = FALSE)
pca_plot <- fviz_pca_ind(pca,
                         habillage = df_numeric$Group,
                         addEllipses = TRUE,
                         ellipse.level = 0.95,
                         repel = TRUE) +
  labs(title = "PCA: Pre vs Post")

ggsave("PCA_plot.png", pca_plot, width = 8, height = 6)
print(pca_plot)

# 🔍 PLS-DA (supervised)
# Prepare data
X <- as.matrix(df %>% select(-Sample, -Group))
Y <- as.factor(df$Group)

# Run PLS-DA using ropls
pls_model <- opls(X, Y, predI = 2, orthoI = 0, printL = FALSE, plotL = FALSE)

# Plot PLS-DA
pls_plot <- fviz_pca_ind(pls_model@scoreMN,
                         habillage = Y,
                         addEllipses = TRUE,
                         repel = TRUE) +
  labs(title = "PLS-DA: Pre vs Post")

ggsave("PLSDA_plot.png", pls_plot, width = 8, height = 6)
print(pls_plot)
