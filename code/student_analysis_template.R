# ============================================================================
# mtDNA INDIVIDUAL STUDENT ANALYSIS: OSTEOARTHRITIS COHORT
# Template R Script for Age–VAF Correlation or Personal Study
# ============================================================================
#
# INSTRUCTIONS:
# 1. Load this script into RStudio
# 2. Update file path to your dataset
# 3. Uncomment sections as needed
# 4. Run step-by-step or source() entire script
# 5. Modify analysis based on your research question
#
# Author: [Your Name]
# Date: [Today's Date]
# Course: mtDNA Bioinformatics Practicum, University of Vienna
#
# ============================================================================

# PART 0: SETUP AND LIBRARY LOADING
# ============================================================================

# Clear workspace
rm(list = ls())

# Load required libraries
library(readxl)          # Read Excel files
library(dplyr)           # Data manipulation
library(tidyr)           # Data tidying
library(ggplot2)         # Publication-quality plots
library(corrplot)        # Correlation visualizations
library(psych)           # Descriptive statistics
library(broom)           # Clean statistical output
library(scales)          # Axis scaling and formatting

# Set working directory (UPDATE THIS PATH)
setwd("~/Documents/mtDNA_Analysis/")

# Create output directory for results
dir.create("./results", showWarnings = FALSE)

# ============================================================================
# PART 1: LOAD DATA
# ============================================================================

cat("\n=== LOADING DATA ===\n")

# Load Excel file (UPDATE FILE PATH)
data_raw <- read_excel(
  "Supplementary_File_S1_Clinical_data_of_Osteoarthritic_cohort.xlsx",
  sheet = 1
)

cat("Raw data dimensions:", nrow(data_raw), "rows x", ncol(data_raw), "columns\n")
cat("Column names:\n")
print(colnames(data_raw))

# ============================================================================
# PART 2: DATA INSPECTION AND QUALITY CONTROL
# ============================================================================

cat("\n=== DATA QUALITY INSPECTION ===\n")

# Check data structure
cat("Data structure:\n")
str(data_raw)

# Summary statistics
cat("\nBasic summary:\n")
summary(data_raw)

# Identify duplicated patients (one row per mutation!)
cat("\n=== PATIENT DUPLICATION CHECK ===\n")
patient_counts <- table(data_raw$Patient_ID)
cat("Patients with multiple rows:\n")
print(head(sort(patient_counts, decreasing = TRUE), 10))

# Check missing values
cat("\n=== MISSING VALUES ===\n")
missing_summary <- colSums(is.na(data_raw))
print(missing_summary[missing_summary > 0])

# ============================================================================
# PART 3: DATA CLEANING AND PREPARATION
# ============================================================================

cat("\n=== DATA CLEANING ===\n")

# Create clean dataset
data <- data_raw %>%
  # Remove rows with missing Age or Allele_frequency
  filter(!is.na(Age), !is.na(Allele_frequency)) %>%
  # Convert Allele_frequency to percentage
  mutate(
    VAF_percent = Allele_frequency * 100,
    # Create age groups for stratified analysis
    Age_group = cut(Age, 
                    breaks = c(0, 60, 70, 100),
                    labels = c("Young (<60)", "Middle (60-70)", "Elderly (>70)"),
                    include.lowest = TRUE),
    # Convert haplogroup to factor
    Haplogroup = as.factor(Haplogroup),
    # Log-transform mtDNA copy number (often right-skewed)
    mtDNA_copy_log10 = log10(mtDNA_copy_number + 1)
  )

cat("Clean data dimensions:", nrow(data), "rows x", ncol(data), "columns\n")

# ============================================================================
# PART 4: OPTION A - DEDUPLICATE TO PATIENT LEVEL
# ============================================================================
# Choose ONE method to create patient-level dataset
# Uncomment the one you prefer

cat("\n=== CREATING PATIENT-LEVEL DATASET ===\n")

# METHOD 1: Keep only FIRST occurrence of each patient
# (Simplest, but loses mutation information)
# patient_data <- data %>%
#   distinct(Patient_ID, .keep_all = TRUE)

# METHOD 2: Aggregate multiple mutations per patient
# (RECOMMENDED: summarizes each patient's overall burden)
patient_data <- data %>%
  group_by(Patient_ID) %>%
  summarise(
    Age = first(Age),
    Gender = first(Gender),
    Weight = first(Weight),
    Height = first(Height),
    BMI = first(BMI),
    Arthritis_type = first(Arthritis_type),
    # Clinical markers
    Systolic_BP = first(Systolic_BP),
    Diastolic_BP = first(Diastolic_BP),
    Heart_rate = first(Heart_rate),
    Hemoglobin = first(Hemoglobin),
    Leukocytes = first(Leukocytes),
    ESR = first(ESR),
    # Inflammatory indices
    SIRI = first(SIRI),
    SII = first(SII),
    AISI = first(AISI),
    NLR = first(NLR),
    LMR = first(LMR),
    # Hand strength
    Dynamometry_mean = first(Dynamometry_mean),
    # Genetics
    Haplogroup = first(Haplogroup),
    mtDNA_copy_number = first(mtDNA_copy_number),
    mtDNA_copy_log10 = first(mtDNA_copy_log10),
    # mtDNA variants (aggregate)
    mean_VAF = mean(Allele_frequency, na.rm = TRUE),
    max_VAF = max(Allele_frequency, na.rm = TRUE),
    VAF_percent_mean = mean(VAF_percent, na.rm = TRUE),
    VAF_percent_max = max(VAF_percent, na.rm = TRUE),
    n_mutations = n(),
    .groups = 'drop'
  ) %>%
  mutate(
    Age_group = cut(Age, 
                    breaks = c(0, 60, 70, 100),
                    labels = c("Young (<60)", "Middle (60-70)", "Elderly (>70)"),
                    include.lowest = TRUE)
  )

# METHOD 3: Analyze mutation level separately
# (Keep all mutations, account for patient clustering in statistics)
# mutation_data <- data  # Use original 'data' as-is

cat("Patient-level dataset:", nrow(patient_data), "unique patients\n")
cat("Mean mutations per patient:", 
    round(nrow(data) / nrow(patient_data), 2), "\n")

# ============================================================================
# PART 5: DESCRIPTIVE STATISTICS
# ============================================================================

cat("\n=== DESCRIPTIVE STATISTICS ===\n")

# Overall descriptive statistics
cat("\n--- All Patients ---\n")
describe(patient_data[, c("Age", "BMI", "VAF_percent_mean", "SIRI", "mtDNA_copy_number")])

# By arthritis type
cat("\n--- By Arthritis Type ---\n")
patient_data %>%
  group_by(Arthritis_type) %>%
  summarise(
    N = n(),
    mean_age = mean(Age, na.rm = TRUE),
    sd_age = sd(Age, na.rm = TRUE),
    mean_vaf = mean(VAF_percent_mean, na.rm = TRUE),
    sd_vaf = sd(VAF_percent_mean, na.rm = TRUE),
    mean_bmi = mean(BMI, na.rm = TRUE),
    mean_siri = mean(SIRI, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  print()

# By age group
cat("\n--- By Age Group ---\n")
patient_data %>%
  group_by(Age_group) %>%
  summarise(
    N = n(),
    mean_age = mean(Age),
    mean_vaf = mean(VAF_percent_mean, na.rm = TRUE),
    sd_vaf = sd(VAF_percent_mean, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  print()

# ============================================================================
# PART 6: ANALYSIS OPTION A - AGE–VAF CORRELATION (Lobanova et al. 2025)
# ============================================================================

cat("\n=== AGE–VAF CORRELATION ANALYSIS ===\n")

# Remove rows with missing values for this analysis
analysis_data <- patient_data %>%
  filter(!is.na(Age), !is.na(VAF_percent_mean))

cat("Sample size for correlation analysis:", nrow(analysis_data), "\n")

# --- Pearson Correlation (assumes linearity, normality) ---
pearson_result <- cor.test(
  analysis_data$Age, 
  analysis_data$VAF_percent_mean,
  method = "pearson"
)

cat("\n--- Pearson Correlation ---\n")
cat("r =", round(pearson_result$estimate, 4), "\n")
cat("p-value =", format(pearson_result$p.value, scientific = TRUE), "\n")
cat("95% CI:", round(pearson_result$conf.int, 4), "\n")

# --- Spearman Rank Correlation (robust to outliers) ---
spearman_result <- cor.test(
  analysis_data$Age, 
  analysis_data$VAF_percent_mean,
  method = "spearman"
)

cat("\n--- Spearman Correlation ---\n")
cat("rho =", round(spearman_result$estimate, 4), "\n")
cat("p-value =", format(spearman_result$p.value, scientific = TRUE), "\n")

# --- Linear Regression ---
lm_model <- lm(VAF_percent_mean ~ Age, data = analysis_data)
lm_summary <- summary(lm_model)

cat("\n--- Linear Regression: VAF ~ Age ---\n")
print(lm_summary)

# Extract coefficients for interpretation
intercept <- coef(lm_model)[1]
slope <- coef(lm_model)[2]
r_squared <- lm_summary$r.squared

cat("\nInterpretation:\n")
cat("- Intercept:", round(intercept, 4), 
    "(baseline VAF at age 0)\n")
cat("- Slope:", round(slope, 6), 
    "(change in VAF per year of age)\n")
cat("- R²:", round(r_squared, 4), 
    "(proportion of variance explained by age)\n")

# ============================================================================
# PART 7: ANALYSIS OPTION B - AGE–VAF BY ARTHRITIS TYPE
# ============================================================================

cat("\n=== AGE–VAF CORRELATION BY ARTHRITIS TYPE ===\n")

# Separate correlations for primary vs post-traumatic
for (arthritis in unique(analysis_data$Arthritis_type)) {
  subset <- analysis_data %>% filter(Arthritis_type == arthritis)
  
  cat("\n--- ", arthritis, " Osteoarthritis (N=", nrow(subset), ") ---\n", sep = "")
  
  cor_result <- cor.test(subset$Age, subset$VAF_percent_mean, method = "pearson")
  cat("r =", round(cor_result$estimate, 4), 
      ", p =", format(cor_result$p.value, scientific = TRUE), "\n")
  
  lm_model_subset <- lm(VAF_percent_mean ~ Age, data = subset)
  cat("Slope =", round(coef(lm_model_subset)[2], 6), "\n")
}

# ============================================================================
# PART 8: ANALYSIS OPTION C - VAF vs INFLAMMATORY MARKERS
# ============================================================================

cat("\n=== VAF VS INFLAMMATORY MARKERS ===\n")

# Correlation between VAF and inflammatory indices
inflamm_markers <- c("SIRI", "SII", "AISI", "NLR", "LMR")

inflamm_data <- analysis_data %>%
  filter(!is.na(SIRI), !is.na(SII), !is.na(AISI), !is.na(NLR), !is.na(LMR))

cat("Sample size for inflamm analysis:", nrow(inflamm_data), "\n\n")

inflamm_correlations <- data.frame()
for (marker in inflamm_markers) {
  cor_result <- cor.test(inflamm_data$VAF_percent_mean, 
                          inflamm_data[[marker]], 
                          method = "pearson")
  inflamm_correlations <- rbind(inflamm_correlations, data.frame(
    Marker = marker,
    r = round(cor_result$estimate, 4),
    p_value = round(cor_result$p.value, 4)
  ))
}

cat("\n--- VAF vs Inflammatory Markers Correlations ---\n")
print(inflamm_correlations)

# ============================================================================
# PART 9: ANALYSIS OPTION D - GROUP COMPARISONS
# ============================================================================

cat("\n=== GROUP COMPARISONS ===\n")

# T-test: VAF by gender
cat("\n--- VAF by Gender (t-test) ---\n")
t_test_gender <- t.test(VAF_percent_mean ~ Gender, data = analysis_data)
print(t_test_gender)

# ANOVA: VAF by haplogroup (if enough groups)
haplogroups_present <- length(unique(analysis_data$Haplogroup))
if (haplogroups_present >= 3) {
  cat("\n--- VAF by Haplogroup (ANOVA) ---\n")
  aov_result <- aov(VAF_percent_mean ~ Haplogroup, data = analysis_data)
  print(summary(aov_result))
}

# Kruskal-Wallis: VAF by age group (non-parametric)
cat("\n--- VAF by Age Group (Kruskal-Wallis) ---\n")
kw_result <- kruskal.test(VAF_percent_mean ~ Age_group, data = analysis_data)
print(kw_result)

# ============================================================================
# PART 10: VISUALIZATION
# ============================================================================

cat("\n=== CREATING VISUALIZATIONS ===\n")

# --- Figure 1: Age vs VAF (Main result) ---
fig1 <- ggplot(analysis_data, aes(x = Age, y = VAF_percent_mean)) +
  geom_point(aes(color = Arthritis_type), size = 3, alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, color = "black", linewidth = 1) +
  labs(
    title = "Age-Associated mtDNA Heteroplasmy",
    subtitle = paste0("Pearson r = ", 
                      round(pearson_result$estimate, 3), 
                      ", p = ", 
                      format(pearson_result$p.value, digits = 3)),
    x = "Age (years)",
    y = "Mean Heteroplasmy (%)",
    color = "Arthritis Type"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )

print(fig1)
ggsave("./results/01_age_vaf_correlation.png", fig1, width = 8, height = 6, dpi = 300)

# --- Figure 2: VAF by Arthritis Type ---
fig2 <- ggplot(analysis_data, aes(x = Arthritis_type, y = VAF_percent_mean)) +
  geom_boxplot(fill = "lightblue", color = "black", alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5, color = "darkblue", size = 2) +
  labs(
    title = "Heteroplasmy by Arthritis Type",
    x = "Arthritis Type",
    y = "Mean Heteroplasmy (%)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(fig2)
ggsave("./results/02_vaf_by_arthritis_type.png", fig2, width = 6, height = 5, dpi = 300)

# --- Figure 3: VAF by Age Group ---
fig3 <- ggplot(analysis_data, aes(x = Age_group, y = VAF_percent_mean)) +
  geom_boxplot(fill = "lightcoral", color = "black", alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.5, color = "darkred", size = 2) +
  labs(
    title = "Heteroplasmy by Age Group",
    x = "Age Group",
    y = "Mean Heteroplasmy (%)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(fig3)
ggsave("./results/03_vaf_by_age_group.png", fig3, width = 6, height = 5, dpi = 300)

# --- Figure 4: Correlation Matrix ---
corr_vars <- c("Age", "BMI", "VAF_percent_mean", "SIRI", "NLR", "mtDNA_copy_number")
corr_matrix <- cor(analysis_data[, corr_vars], use = "complete.obs")

png("./results/04_correlation_matrix.png", width = 800, height = 700)
corrplot(corr_matrix, 
         method = "circle", 
         type = "upper",
         diag = TRUE,
         addCoef.col = "black",
         number.cex = 0.8)
dev.off()

# --- Figure 5: VAF vs SIRI ---
fig5 <- ggplot(inflamm_data, aes(x = SIRI, y = VAF_percent_mean)) +
  geom_point(size = 3, alpha = 0.6, color = "darkgreen") +
  geom_smooth(method = "lm", se = TRUE, color = "black") +
  labs(
    title = "Heteroplasmy vs Systemic Inflammation",
    x = "SIRI Index",
    y = "Mean Heteroplasmy (%)"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(fig5)
ggsave("./results/05_vaf_vs_siri.png", fig5, width = 8, height = 6, dpi = 300)

# ============================================================================
# PART 11: SAVE RESULTS
# ============================================================================

cat("\n=== SAVING RESULTS ===\n")

# Save clean dataset
write.csv(patient_data, "./results/patient_level_data.csv", row.names = FALSE)

# Save summary statistics
summary_stats <- data.frame(
  Metric = c("Sample Size", "Mean Age", "Mean VAF (%)", 
             "Pearson r (Age-VAF)", "Pearson p-value", 
             "Slope (VAF per year)", "R-squared"),
  Value = c(nrow(analysis_data),
            round(mean(analysis_data$Age), 2),
            round(mean(analysis_data$VAF_percent_mean, na.rm = TRUE), 2),
            round(pearson_result$estimate, 4),
            format(pearson_result$p.value, scientific = TRUE),
            round(coef(lm_model)[2], 6),
            round(r_squared, 4))
)

write.csv(summary_stats, "./results/summary_statistics.csv", row.names = FALSE)

cat("Results saved to ./results/\n")

# ============================================================================
# PART 12: SESSION INFO AND FINAL SUMMARY
# ============================================================================

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("Session Info:\n")
sessionInfo()

cat("\n=== KEY FINDINGS ===\n")
cat("1. Sample size:", nrow(analysis_data), "patients\n")
cat("2. Age–VAF correlation: r =", round(pearson_result$estimate, 4), 
    ", p =", format(pearson_result$p.value, digits = 3), "\n")
cat("3. Effect size: ", round(slope, 6), "% VAF per year of age\n")
cat("4. Variance explained (R²):", round(r_squared, 4), "\n")

if (pearson_result$p.value < 0.05) {
  cat("5. CONCLUSION: Statistically significant age–VAF correlation detected\n")
  cat("   (consistent with Lobanova et al. 2025)\n")
} else {
  cat("5. CONCLUSION: No significant age–VAF correlation detected\n")
  cat("   (consider alternative explanations or research questions)\n")
}

# ============================================================================
# END OF SCRIPT
# ============================================================================
