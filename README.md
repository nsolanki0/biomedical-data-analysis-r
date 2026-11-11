# Biomedical Data Analysis in R

## Overview
This repository documents selected biomedical data-analysis workflows developed during a four-year part-time position as a Student Research Assistant at Charité Universitätsmedizin, Berlin.

The work involved analysing behavioural measurements from mouse and rat behavioural assays addressing neuroscience research questions across approximately 12 research projects. Different analyses were performed according to the requirements of each project, resulting in around 30 analysis workflows overall, of which approximately 15 were developed as new analysis templates.

Data were generated using multiple experimental paradigms and software systems, resulting in heterogeneous data structures and experiment-specific requirements for data extraction, preprocessing, wrangling and analysis.

A major component of the work was the development of reusable R- and RMarkdown-based workflows integrating data processing, statistical analysis, visualisation and automated report generation.

## Computational Workflow

The overall workflow can be summarised as:

```text
                    Experimental data
                           │
                           ▼
                   Data extraction
                           │
                           ▼
                    Preprocessing
                           │
                           ▼
                     Data wrangling
                           │
                           ▼
                       Analysis
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
          Statistical   Group        Visualisation
           testing    comparisons
              │            │            │
              └────────────┼────────────┘
                           │
                           ▼
                       RMarkdown
                           │
                           ▼
                  Automated PDF report
```

The workflows were designed to separate data preparation from downstream analysis where appropriate, while accommodating differences between experimental datasets.

## Data Processing
The experimental data originated from about eight different software systems. Differences in data structure and output format required multiple approaches to data extraction, cleaning, restructuring and preprocessing.

The `data-processing/` directory contains selected preprocessing workflows developed for these different data sources.

## Analysis Workflows
Around 30 different analysis workflows were used across the research projects, of which approximately 15 were developed as new analysis templates.

The `analysis-workflows/` directory contains the analysis templates I developed as part of this work. The templates address different behavioural assays and analytical requirements.

## Automated Analysis and Reporting with RMarkdown
A central component of the work was the development of RMarkdown-based workflows that automated the analysis and reporting process.

The workflows were designed as reusable analysis tools: once the required input data were provided, the workflow automatically performed the relevant data processing, statistical analyses and visualisations, and generated a structured PDF report containing the resulting analyses and outputs.

This created a reproducible workflow from experimental input data to a complete analysis report while reducing manual processing and providing a consistent reporting structure.

The process can be summarised as:

```text
Input experimental data
          │
          ▼
    Automated workflow
          │
          ├── Data processing
          ├── Statistical analysis
          └── Visualisation
          │
          ▼
       RMarkdown
          │
          ▼
      PDF report
```

## Statistical Analysis
The analysis workflows included statistical methods appropriate to the experimental design and analytical question, including:

- Group comparisons
- Null-hypothesis significance testing
- t-tests
- Wilcoxon tests
- Kruskal–Wallis tests
- Descriptive statistics
- Data visualisation

## My Contribution
During this position, I developed and implemented R-based workflows for processing and analysing behavioural and phenotypic data from neuroscience studies.

My work included:

- Data extraction and preprocessing
- Data cleaning and wrangling
- Development of preprocessing approaches for heterogeneous data sources
- Development of analysis workflows for behavioural assays
- Statistical hypothesis testing and group comparisons
- Data visualisation
- Development of RMarkdown-based automated analysis and reporting workflows
- Adaptation and extension of existing analytical approaches where appropriate

The workflows included in this repository represent analysis templates I developed across a range of behavioural assays and research projects.

## Technical Skills
- R
- RMarkdown
- Data preprocessing and wrangling
- Statistical analysis
- Data visualisation
- Automated analysis and reporting
- Biomedical workflow development
- Analysis of behavioural neuroscience data
- Working with heterogeneous experimental datasets

## Code and Data Availability
The original research datasets are not included in this repository.

The availability of the original code and associated research material is subject to relevant institutional, project and data-use requirements. Repository contents will therefore be limited to material that can appropriately be made publicly available.

## Repository Structure

```text
Biomedical-data-analysis-r/
│
├── README.md
│
├── data-processing/
│   ├── ...
│   └── ...
│
└── analysis-workflows/
    ├── ...
    └── ...
```
