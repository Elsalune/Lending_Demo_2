# Lending Club Data Science Demo

This internal DXC demonstration aims at presenting a full Data Science project on a peer-to-peer lending problematic. Starting with the raw data collection and ending with a minimal viable application, it presents the typical deliverables that will be submitted to the client in the Predict offer. 

## Access project and data

```
git clone https://gitlab.com/dxc_data_science/Lending_Club.git
```
Cloning the repo, you will get everything you need to explore the project except the most important thing: the Data (The file is too large to be stored on GitLab). 

To access the data you will have to:
1. Create a folder called **inputs** in the Lending_Club folder
2. Download the **loan.csv** file from [Kaggle](https://www.kaggle.com/wendykan/lending-club-loan-data/data) and put it in the inputs folder

## DataBook (Exploratory Data Analysis)

A Data Science project always starts exploring the data in order to visualize, clean and understand it. It is also the best way to validate some assumptions and be prepared for the modelling stage.

Our project includes 2 files that presents the data and the exploration:
*  **LCDataDescription_final.xlsx** located in Lending_Club\data_description describes all the variables in the dataset (Description sheet) and presents descriptive statistics on quantitative variables (Summary statistics sheet).
*  **LendingClubRmd.Rmd** located in Lending_Club\eda\LendingClubRmd is the source file that generates the DataBook in html format. 

### prerequisites for generating html report

* R - click [here](https://www.r-project.org/) if not installed
* R studio - click [here](https://www.rstudio.com/products/rstudio/download/) if not installed
* R dxcrmd package - click [here](https://gitlab.com/dxc_data_science/dxcrmd) if not installed

In order to generate the html report: Open **LendingClubRmd.Rmd** in RStudio and click on **Knit**. 

Enjoy the reading! 

## Machine Learning Model 

## InsightBook

## Application 
