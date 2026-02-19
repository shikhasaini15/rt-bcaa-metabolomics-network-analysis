library(readr)
library(dplyr)

# Safe file load
met_data <- read_csv("Pre Post T.csv", locale = locale(encoding = "latin1"))

# Clean column names
names(met_data) <- make.names(names(met_data), unique = TRUE)

# View column names to find the group column
names(met_data)

# Assume it's now called Group
group <- as.factor(met_data$Group)

# Extract metabolite data (assume first 2 columns are metadata)
metabolite_data <- met_data[, -(1:2)]

# Run t-tests
p_values <- apply(metabolite_data, 2, function(x) {
  t.test(x ~ group)$p.value
})

# Adjust p-values
adj_p_values <- p.adjust(p_values, method = "fdr")

# Combine results
results <- data.frame(
  Metabolite = colnames(metabolite_data),
  P_value = p_values,
  FDR_adjusted_P = adj_p_values
)

# Save output
write.csv(results, "t_test_results_metabolites.csv", row.names = FALSE)
