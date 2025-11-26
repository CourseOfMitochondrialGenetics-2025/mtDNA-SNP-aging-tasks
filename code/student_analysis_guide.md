# Student Analysis Guide: mtDNA Variants and Clinical Data Integration
## Osteoarthritis Cohort Study

---

## 1. Introduction to the Dataset

### 1.1 What is this data?

**Supplementary_File_S1_Clinical_data_of_Osteoarthritic_cohort.xlsx** contains integrated clinical and molecular data from patients with osteoarthritis (OA) who have undergone mitochondrial DNA analysis.

**Key characteristics:**
- **Patients:** Multiple individuals diagnosed with primary or post-traumatic osteoarthritis
- **Molecular data:** mtDNA variants (SNPs/MNPs) detected via NGS and MitoHPC pipeline
- **Clinical data:** Comprehensive health parameters (age, BMI, blood pressure, haematological markers, inflammatory indices)
- **Genetics:** mtDNA haplogroup classification and copy number
- **Data structure:** Each row represents ONE MUTATION (not one patient!). Therefore, **patients are duplicated** across rows when they have multiple variants.

### 1.2 Important concept: Data structure and deduplication

⚠️ **CRITICAL:** The data table contains **one row per mutation**, meaning individual patients appear multiple times.

Example:
```
Patient 101, Age 80, has 2 mutations (189 A>G and 408 T>A)
→ Patient 101 appears in 2 rows (one for each mutation)
```

**Before any analysis, you must:**
1. Deduplicate patients
2. Create a unique patient-level dataset
3. Decide how to handle multiple mutations per patient (e.g., take mean VAF, max VAF, or analyze separately)

---

## 2. Dataset Overview

### 2.1 Key columns explained

#### **Clinical/Demographic Data:**
- **Patient_ID:** Unique identifier for each individual
- **Age:** Patient age in years (KEY VARIABLE for age–VAF correlation)
- **Gender:** F (female) or M (male)
- **BMI:** Body Mass Index = Weight(kg) / Height(m)²
- **Arthritis_type:** 'primary' (idiopathic) or 'post-traumatic'

#### **Haematological/Biochemical Markers:**
- **Hemoglobin, Red_blood_cells, Leukocytes:** Basic blood counts
- **Thrombocytes:** Platelet count
- **ALT, AST, Creatinine, Glucose, Cholesterol:** Liver, kidney, metabolic function

#### **Inflammatory Indices** (KEY for disease severity):
- **ESR:** Erythrocyte sedimentation rate
- **NLR:** Neutrophil-Lymphocyte Ratio
- **SIRI:** Systemic Inflammation Response Index
- **SII:** Systemic Immune-Inflammation Index
- **AISI:** Aggregate Index of Systemic Inflammation
- **LMR:** Lymphocyte-Monocyte Ratio

#### **Hand Strength:**
- **Dynamometry_left, Dynamometry_right:** Grip strength (kg)
- **Dynamometry_mean:** Average grip strength
- **Dynamometry_BMI_ratio:** Normalized strength metric

#### **Molecular/Genetic Data:**
- **Haplogroup:** mtDNA haplogroup (e.g., H5a1a, J1b1a1, U5b1b1a1a)
- **SNP_position:** Position on mtDNA (e.g., 189, 408, 16134)
- **SNP_type:** Type of substitution (e.g., A>G, T>A, C>T)
- **Allele_frequency (VAF):** Variant Allele Frequency = heteroplasmy % (0–1 scale)
  - Example: 0.07 = 7% heteroplasmy
- **mtDNA_copy_number:** Absolute count of mtDNA molecules (can be very high)
- **MitoHPC_filter_type:** 'strict' (FILTER=PASS) or 'loose' (INFO AS_FilterStatus)
- **Mutation_type:** Category of mutation
  - 'exp_data' = has mutations 189 or 408 (experimental variants)
  - 'cont1_CR' = control region mutations (not 189/408)
  - 'cont2_nonCR' = non-control region mutations

#### **Quality Control:**
- **Contamination_status:** YES/NO (NUMT or other contamination detected)
- **Distance:** Phylogenetic distance metric
- **Sample_coverage:** Depth of coverage (reads)

---

## 3. Motivating Analysis: Age–VAF Correlation (Lobanova et al. 2025)

### 3.1 Background

The **Lobanova et al. 2025** study likely demonstrates that **mtDNA variant allele frequency (heteroplasmy) increases with age**.

**Biological hypothesis:**
- mtDNA accumulates mutations throughout life
- Heteroplasmic variants expand over time due to:
  - Clonal expansion of mutant mtDNA
  - Replicative advantage in certain tissues (e.g., muscles, neurons)
  - Age-related decline in cellular quality control
  - Oxidative stress accumulation

### 3.2 Expected findings

- **Positive correlation:** Age ↔ VAF (higher age = higher heteroplasmy)
- **Variant-specific:** Different variants may show different correlation patterns
- **Tissue-dependent:** Some variants show stronger age effect in specific tissues

### 3.3 How to reproduce this analysis

**Step 1: Deduplicate patients**
```
→ Remove duplicate patient rows
→ Calculate summary VAF for each patient (mean, max, or specific variant)
```

**Step 2: Calculate correlation**
```
→ Pearson correlation: Age vs Allele_frequency
→ Spearman rank correlation (more robust to outliers)
```

**Step 3: Visualize**
```
→ Scatter plot: X-axis = Age, Y-axis = VAF
→ Add trend line (linear regression)
→ Color by mutation type or haplogroup
```

**Step 4: Statistical testing**
```
→ p-value: Is correlation statistically significant (p < 0.05)?
→ R² value: How much variance in VAF is explained by age?
```

---

## 4. Alternative Research Questions

If you choose NOT to replicate Lobanova et al., consider these alternatives:

### **Option A: mtDNA variants and inflammatory markers**
- **Question:** Do patients with higher VAF have elevated inflammatory indices (SIRI, SII, NLR)?
- **Hypothesis:** High-heteroplasmy mtDNA variants may be associated with systemic inflammation
- **Analysis:** Correlation between Allele_frequency and SIRI/SII/NLR

### **Option B: mtDNA copy number and clinical parameters**
- **Question:** Does mtDNA copy number correlate with age, BMI, or disease severity?
- **Hypothesis:** mtDNA copy number changes may reflect mitochondrial compensatory response
- **Analysis:** Correlation between mtDNA_copy_number and Age/BMI/SIRI

### **Option C: Haplogroup differences**
- **Question:** Do different mtDNA haplogroups (H, J, U, etc.) show different VAF patterns?
- **Hypothesis:** Haplogroup-specific variants accumulate differently due to genetic background
- **Analysis:** ANOVA or Kruskal-Wallis test comparing VAF across haplogroups

### **Option D: Mutation type and clinical outcomes**
- **Question:** Are experimental variants (189, 408) vs control region variants vs non-CR variants associated with different clinical outcomes?
- **Hypothesis:** Disease-specific mtDNA mutations (189, 408) may show stronger clinical associations
- **Analysis:** Compare clinical markers across Mutation_type categories

### **Option E: Age-stratified analysis**
- **Question:** Does the Age–VAF relationship differ between young (<60) vs elderly (≥60) patients?
- **Hypothesis:** Aging may show a non-linear relationship with heteroplasmy (plateau effect)
- **Analysis:** Separate analyses for age groups; test for interaction

---

## 5. Data Preparation Steps

### 5.1 Load and inspect data

```r
# Load Excel file
library(readxl)
data <- read_excel("Supplementary_File_S1_Clinical_data_of_Osteoarthritic_cohort.xlsx")

# Check structure
dim(data)           # Number of rows and columns
head(data, 20)      # First 20 rows
str(data)           # Data types
```

### 5.2 Handle missing values

```r
# Identify missing data
summary(data)
colSums(is.na(data))

# Decide what to do with NAs:
# Option 1: Remove rows with NA
data_clean <- na.omit(data)

# Option 2: Remove specific columns with many NAs
data_clean <- data[, colSums(is.na(data)) < nrow(data) * 0.5]

# Option 3: Impute with mean/median
data$Age[is.na(data$Age)] <- median(data$Age, na.rm = TRUE)
```

### 5.3 Deduplicate patients (CRITICAL!)

```r
# Check for duplicates
table(data$Patient_ID)  # How many times does each patient appear?

# Create patient-level dataset (example: take first occurrence)
patient_data <- data %>%
  distinct(Patient_ID, .keep_all = TRUE)

# Alternative: aggregate multiple mutations per patient
patient_summary <- data %>%
  group_by(Patient_ID) %>%
  summarise(
    Age = first(Age),
    Gender = first(Gender),
    BMI = first(BMI),
    SIRI = first(SIRI),
    mtDNA_copy_number = first(mtDNA_copy_number),
    mean_VAF = mean(Allele_frequency, na.rm = TRUE),
    max_VAF = max(Allele_frequency, na.rm = TRUE),
    n_mutations = n(),
    haplogroup = first(Haplogroup)
  )
```

### 5.4 Transform variables

```r
# Convert Allele_frequency to percentage
data$VAF_percent <- data$Allele_frequency * 100

# Create age groups
data$Age_group <- cut(data$Age, 
                      breaks = c(0, 60, 70, 100),
                      labels = c("Young", "Middle", "Elderly"))

# Log-transform skewed variables (e.g., mtDNA copy number)
data$mtDNA_copy_log <- log10(data$mtDNA_copy_number + 1)
```

---

## 6. Statistical Analysis Framework

### 6.1 Descriptive statistics

```r
# Summary of key variables
describe(data$Age)
describe(data$Allele_frequency)
describe(data$SIRI)

# By group
data %>%
  group_by(Arthritis_type) %>%
  summarise(
    mean_age = mean(Age),
    sd_age = sd(Age),
    mean_vaf = mean(Allele_frequency),
    median_vaf = median(Allele_frequency)
  )
```

### 6.2 Correlation analysis

```r
# Pearson correlation (assumes linearity, normality)
cor.test(data$Age, data$Allele_frequency, method = "pearson")

# Spearman rank correlation (robust to outliers)
cor.test(data$Age, data$Allele_frequency, method = "spearman")

# Correlation matrix
cor_matrix <- cor(data[, c("Age", "Allele_frequency", "SIRI", "BMI")], 
                  use = "complete.obs")
```

### 6.3 Linear regression

```r
# Simple regression: VAF ~ Age
model1 <- lm(Allele_frequency ~ Age, data = data)
summary(model1)

# Multiple regression: VAF ~ Age + Gender + BMI
model2 <- lm(Allele_frequency ~ Age + Gender + BMI, data = data)
summary(model2)

# Diagnostic plots
plot(model1)
```

### 6.4 Group comparisons

```r
# T-test: VAF between male/female
t.test(Allele_frequency ~ Gender, data = data)

# ANOVA: VAF across haplogroups
aov_result <- aov(Allele_frequency ~ Haplogroup, data = data)
summary(aov_result)

# Kruskal-Wallis (non-parametric alternative)
kruskal.test(Allele_frequency ~ Mutation_type, data = data)
```

---

## 7. Visualization Best Practices

### 7.1 Scatter plot with trend line

```r
ggplot(data, aes(x = Age, y = Allele_frequency * 100)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Age vs mtDNA Heteroplasmy",
       x = "Age (years)",
       y = "Heteroplasmy (%)") +
  theme_minimal()
```

### 7.2 Box plot by groups

```r
ggplot(data, aes(x = Mutation_type, y = Allele_frequency * 100)) +
  geom_boxplot() +
  geom_jitter(width = 0.2, alpha = 0.3) +
  labs(title = "VAF by Mutation Type",
       x = "Mutation Category",
       y = "Heteroplasmy (%)") +
  theme_minimal()
```

### 7.3 Heatmap of correlations

```r
library(corrplot)
cor_data <- data %>% select(Age, Allele_frequency, SIRI, SII, BMI, mtDNA_copy_number)
corrplot(cor(cor_data, use = "complete.obs"), 
         method = "circle", 
         type = "upper")
```

---

## 8. Reporting Your Findings

### 8.1 Structure of scientific analysis

1. **Background:** Why is this question important?
2. **Hypothesis:** What do you predict?
3. **Methods:** How did you analyze the data?
4. **Results:** What did you find? (statistics, plots, tables)
5. **Interpretation:** What do the results mean?
6. **Limitations:** What are potential weaknesses?
7. **Conclusion:** Key takeaways

### 8.2 Example report outline

**Title:** "Age-associated mtDNA heteroplasmy in osteoarthritis cohort"

**Background:**  
mtDNA accumulates variants with age. Little is known about age–VAF correlations in OA cohorts.

**Methods:**  
Analyzed N=X patients from OA cohort. Calculated Pearson and Spearman correlations between age and Allele_frequency.

**Results:**  
Significant positive correlation between age and VAF (r=0.XX, p<0.05). Mean VAF increased from XX% (young) to YY% (elderly).

**Interpretation:**  
Findings consistent with Lobanova et al. showing age-related mtDNA heteroplasmy expansion.

---

## 9. Troubleshooting Common Issues

### Problem 1: "Patients appear multiple times"
**Solution:** Use `distinct(Patient_ID, .keep_all = TRUE)` or aggregate by patient

### Problem 2: "Missing values in Age or VAF columns"
**Solution:** Use `na.omit()` or `drop_na()` before correlations

### Problem 3: "Correlation not significant"
**Possible reasons:**
- Small sample size (N too low)
- Weak biological effect
- High variability/noise
- Non-linear relationship

**Solutions:**
- Increase sample size
- Try non-parametric tests (Spearman)
- Check for outliers
- Visualize data first

### Problem 4: "Unclear results—multiple mutations per patient"
**Solution:** Report separately:
- Analysis with all mutation rows (N=total mutations)
- Analysis with deduplicated patients (N=unique patients)
- Analysis with aggregated VAF (mean/max per patient)

---

## 10. References and Further Reading

- **Lobanova et al. 2025**: Age-associated mtDNA heteroplasmy (your motivation paper)
- **mtDNA aging literature**: See bibliography.md from main course
- **Statistical methods**: "The R Book" by Crawley M.J. (comprehensive statistics guide)
- **Data visualization**: "ggplot2: Elegant Graphics for Data Analysis" by Hadley Wickham

---

## Appendix: Key Formulas

### Pearson Correlation Coefficient
\[ r = \frac{\sum (x_i - \overline{x})(y_i - \overline{y})}{\sqrt{\sum (x_i - \overline{x})^2 \sum (y_i - \overline{y})^2}} \]

### Linear Regression (Age vs VAF)
\[ \text{VAF} = \beta_0 + \beta_1 \times \text{Age} + \epsilon \]
- β₀ = intercept (baseline VAF)
- β₁ = slope (change in VAF per year of age)
- ε = error term

### Heteroplasmy Percentage
\[ \text{Heteroplasmy %} = \text{Allele_frequency} \times 100 \]

---

**Document Version:** 1.0  
**Last Updated:** 26 November 2025  
**For:** mtDNA Bioinformatics Course, University of Vienna
