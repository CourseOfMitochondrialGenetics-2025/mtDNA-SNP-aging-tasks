# 📑 Complete Student Analysis Guide

## 🎯 START HERE

If you're a **student receiving these materials**, read documents in
this order:

1.  **student_analysis_guide.md** ← Read second (20-30 min)
    -   Understand the osteoarthritis dataset
    -   Learn about Age–VAF correlation
    -   Choose your research question
2.  **student_analysis_template.R** ← Run third (10-15 min)
    -   Executable analysis script
    -   Modify for your needs
    -   Generates all results
3.  **quick_reference_card.md** ← Use during coding (5 min)
    -   Quick copy-paste functions
    -   Statistical interpretations
    -   Troubleshooting help

------------------------------------------------------------------------

## 📚 What Each Document Contains

### Document 1: student_analysis_guide.md

**Comprehensive learning guide (15+ pages)**

Sections: 1. Dataset introduction and data structure explanation 2. Key
variables (47 total) with definitions 3. Biological background: Age–VAF
correlation 4. Five alternative research questions (Options A-E) 5. Data
preparation steps and deduplication 6. Statistical analysis framework 7.
Visualization best practices 8. Report writing structure 9.
Troubleshooting guide 10. Appendix with formulas

**Best for:** Learning, reference, troubleshooting

------------------------------------------------------------------------

### Document 2: student_analysis_template.R

**Executable R script (450+ lines)**

Parts: - Part 0: Setup and library loading - Part 1: Load data - Part 2:
Data inspection and QC - Part 3: Data cleaning - Part 4: Create
patient-level dataset (3 methods) - Part 5: Descriptive statistics -
Part 6: Age–VAF correlation analysis - Part 7: Age–VAF by arthritis
type - Part 8: VAF vs inflammatory markers - Part 9: Group comparisons -
Part 10: Generate 5 visualizations - Part 11: Save results - Part 12:
Summary and conclusions

**Best for:** Running analysis, learning R patterns

------------------------------------------------------------------------

### Document 3: quick_reference_card.md

**Quick lookup reference (2 pages)**

Sections: - 5-minute quick start code - Key analyses at a glance -
Common R tasks (copy-paste ready) - Statistical interpretation table -
Critical reminders (DO's and DON'Ts) - File organization template -
Troubleshooting tips

**Best for:** Quick answers while coding

------------------------------------------------------------------------

## 🎯 Three Main Study Paths

### Path A: Replicate Lobanova et al. 2025 (Easiest)

1.  Read student_analysis_guide.md Sections 1-3 (20 min)
2.  Run student_analysis_template.R Parts 1-6 (15 min)
3.  Write report (60 min) **Total: 1.5 hours**

### Path B: Explore Inflammation (Intermediate)

1.  Read student_analysis_guide.md Sections 1-2, 4 (20 min)
2.  Modify student_analysis_template.R Part 8 (15 min)
3.  Run modified analysis (10 min)
4.  Write report (60 min) **Total: 2 hours**

### Path C: Custom Research Question (Advanced)

1.  Design custom analysis
2.  Modify and extend template.R (30 min)
3.  Run analysis (15 min)
4.  Write full report with methods (90 min) **Total: 3+ hours**

------------------------------------------------------------------------

## 📱 How to Access Documents

### As Text Files

```         
Download all files
Open .md files in: Text editor, Word, Google Docs, or browser
Open .R files in: RStudio (recommended) or text editor
```

### To Print

```         
Convert .md to PDF using:
- GitHub (paste text, then print)
- Pandoc (command: pandoc file.md -o file.pdf)
- Online converter
- VS Code with markdown preview
```

### To Study Online

```         
View on:
- GitHub (recommended, formatted nicely)
- GitLab
- Gitea
- Any markdown viewer
```

------------------------------------------------------------------------

## 💾 File Organization

```         
code/
├── student_analysis_guide.md     ← Start!
├── student_analysis_template.R   ← Run this
├── quick_reference_card.md       ← Use while coding
└── README.md                     ← You are here

datasets/
└── Supplementary_File_S1_Clinical_data_of_Osteoarthritic_cohort.xlsx
```
------------------------------------------------------------------------

## 🎓 Learning Outcomes

After using this package, you will:

**Know:** - mtDNA biology and heteroplasmy - When to use which
statistical tests - How to detect and fix data quality issues

**Can do:** - Load genomic datasets - Deduplicate and clean data -
Calculate correlations and regressions - Create scientific
visualizations - Write analysis reports

**Understand:** - Age–VAF relationship in mtDNA - How to interpret
p-values and correlations - Scientific method for data analysis - How to
troubleshoot bioinformatics problems

------------------------------------------------------------------------

## 🎉 You're Ready!

You now have everything needed for a professional mtDNA analysis: - ✅
Conceptual understanding (guide) - ✅ Executable code (template) - ✅
Quick references (card) - ✅ Navigation help (README) 

**Begin with student_analysis_guide.md and enjoy
your analysis!**

