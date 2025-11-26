# Quick Reference Card: Student Data Analysis Workflow

## 🎯 Quick Start (5 minutes)

```r
# 1. Load data
library(readxl)
data <- read_excel("Supplementary_File_S1_Clinical_data_of_Osteoarthritic_cohort.xlsx")

# 2. Remove rows with missing Age or VAF
data_clean <- data %>% filter(!is.na(Age), !is.na(Allele_frequency))

# 3. Deduplicate patients (aggregate mutations)
patient_data <- data_clean %>%
  group_by(Patient_ID) %>%
  summarise(Age = first(Age), 
            mean_VAF = mean(Allele_frequency) * 100)

# 4. Correlate Age vs VAF
cor.test(patient_data$Age, patient_data$mean_VAF, method = "pearson")

# 5. Plot
plot(patient_data$Age, patient_data$mean_VAF, main = "Age vs Heteroplasmy")
```

---

## 📊 Key Analyses at a Glance

### Age–VAF Correlation (Lobanova et al. 2025)
```r
cor.test(Age, Allele_frequency * 100, method = "pearson")
lm(Allele_frequency ~ Age) %>% summary()
```
**Expected:** Positive correlation (older → higher heteroplasmy)

### VAF vs Inflammatory Markers
```r
cor.test(Allele_frequency, SIRI, method = "pearson")
```

### Group Comparisons
```r
t.test(Allele_frequency ~ Gender)                    # By sex
aov(Allele_frequency ~ Haplogroup) %>% summary()     # By haplogroup
kruskal.test(Allele_frequency ~ Mutation_type)       # By mutation type
```

---

## 🔧 Common Tasks

### Convert VAF to percentage
```r
data$VAF_percent <- data$Allele_frequency * 100
```

### Create age groups
```r
data$Age_group <- cut(data$Age, breaks = c(0, 60, 70, 100), 
                      labels = c("Young", "Middle", "Elderly"))
```

### Remove duplicates (choose one)
```r
# Method 1: Keep first
unique_patients <- data %>% distinct(Patient_ID, .keep_all = TRUE)

# Method 2: Aggregate
summary_by_patient <- data %>% 
  group_by(Patient_ID) %>%
  summarise(across(everything(), first), 
            mean_VAF = mean(Allele_frequency))
```

### Quick visualization
```r
library(ggplot2)
ggplot(data, aes(x = Age, y = Allele_frequency * 100)) +
  geom_point() +
  geom_smooth(method = "lm")
```

---

## 📈 Statistical Interpretation

| Statistic | Meaning | Example |
|-----------|---------|---------|
| **r = 0.3** | Weak positive correlation | VAF increases slightly with age |
| **r = 0.7** | Strong positive correlation | VAF increases substantially with age |
| **p < 0.05** | Statistically significant | Result unlikely due to chance |
| **R² = 0.25** | 25% of variance explained | Age explains ¼ of VAF variation |

---

## ⚠️ Critical Reminders

✅ **DO:**
- Deduplicate patients before analysis
- Check for missing values (`na.omit()`)
- Visualize before analyzing
- Report both r AND p-value
- Save your results

❌ **DON'T:**
- Forget patients appear multiple times in raw data
- Use parametric tests on non-normal data
- Skip data exploration
- Report results without uncertainty (confidence intervals)

---

## 📁 File Organization

```
Your_Project/
├── data/
│   └── Supplementary_File_S1_Clinical_data_of_Osteoarthritic_cohort.xlsx
├── scripts/
│   ├── student_analysis_template.R    ← Main script
│   └── custom_functions.R              ← Your custom functions
├── results/
│   ├── plots/
│   ├── tables/
│   └── summary_statistics.csv
└── report/
    └── your_analysis_report.Rmd
```

---

## 🚀 Run Your Analysis

```r
# Option 1: Run script line-by-line in RStudio
# Option 2: Source entire script
source("student_analysis_template.R")

# Output: Plots in ./results/, Statistics printed to console
```

---

## 📧 Troubleshooting

**Q: "Error: object 'Allele_frequency' not found"**
- A: Update file path, ensure sheet name is correct

**Q: "Patients appear in multiple rows"**
- A: Use `distinct()` or `group_by()` to deduplicate

**Q: "Correlation not significant (p > 0.05)"**
- A: Try alternative analysis, check for outliers, consider non-parametric test

**Q: "What if I want to do a different analysis?"**
- A: See student_analysis_guide.md for 5 alternative research questions!

---

## 📚 Resources

- **Guide:** student_analysis_guide.md (comprehensive, 10 sections)
- **Script:** student_analysis_template.R (commented, modifiable)
- **Course:** mtDNA Bioinformatics Practicum materials
- **Reference:** Bibliography from main course docs

