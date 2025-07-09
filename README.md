# The Mismeasure of Weather: Using Earth Observation Data for Estimation of Socioeconomic Outcomes

This README describes the directory structure and code used in the paper "[The Mismeasure of Weather: Using Earth Observation Data for Estimation of Socioeconomic Outcomes][1]." Ideally, this replication package would reproduce the entire workflow from processing the raw weather data, cleaning the raw houeshold survey data, stiching them together, building the panel, running regressions, and creating tables and figures of results. However, this level of reproducibility is not possible because the raw weather data time series for each true household coordinate contains sufficient information to re-identify the household. Therefore, the raw weather data remains confidential with the World Bank. Despite this, we have provided all code for processing the weather data in case someone wants to use it on weather data matched to the publicly available obfuscated coordinates.

The raw household survey data is publicly available and can be cleaned using the code in this replication package. However, the final step in the household cleaning involves matching the cleaned household data to the weather data and therefore creates another potential avenue for re-identification of households. As with the weather cleaning code, we include our household cleaning code so that the work can be replicated, if only with weather data matched to the obfuscated coordinates.

What we can provide in terms of data in this replication package is the processed and matched weather and household data that is sufficiently de-identified that the World Bank is comfortable with public release. Therefore, in the Zenodo repository we provide complete cleaned and merged panel data for each country. This allows a replicator to start with those country level panels and run the replication code to sticth the panels together, run all regressions, and produce all tables and figures in the paper and the online-only supplemental material. Contact Drs. Anna Josephson or Jeffrey D. Michler and they can share an intermediate, de-identified version of the weather data for use in replicating the results.

[![DOI](https://zenodo.org/badge/510811151.svg)](https://zenodo.org/badge/latestdoi/510811151)

This README was last updated on 8 July 2025. 

 ## Index

 - [Project Team](#project-team)
 - [Data cleaning](#data-cleaning)
 - [Pre-requisites](#pre-requisites)
 - [Folder structure](#folder-structure)

## Project Team

Contributors:
* Jeffrey D. Michler [jdmichler@arizona.edu] (Conceptualizaiton, Supervision, Visualization, Writing)
* Anna Josephson [aljosephson@arizona.edu] (Conceptualizaiton, Supervision, Visualization, Writing)
* Talip Kilic (Conceptualization, Resources, Writing)
* Siobhan Murray (Conceptualization, Writing)
* Brian McGreal (Data curation)
* Alison Conley (Data curation)
* Emil Kee-Tui (Data curation)
* Reece Branham (Data curation)
* Rodrigo Guerra Su (Data curation)
* Jacob Taylor (Data curation)
* Kieran Douglas (Data curation)

## Data cleaning

The code in this repository contains the cleaning code for the raw weather and raw household LSMS-ISA data. This code cannot be used to perfectly reproduce the entire workflow and results in the paper because of our use of the true household coordinates. However, one could reproduce a the paper using this code and the publicly available obfuscated coordinates for matching weather data and household data. This requires downloading the weather data from each earth observation (EO) product's website, downloading this repo, and downloading the household data from the [World Bank Microdata Library][2]. The `projectdo.do` should then replicate the data cleaning process.

### Pre-requisites

#### Stata req's

  * The data processing and analysis requires a number of user-written
    Stata programs:
    1. `wxsum`
    2. `blindschemes`
    3. `mdesc`
    4. `estout`
    5. `distinct`
    6. `winsor2`
    7. `bumpline`
    8. `colrspace`
    9. `palettes`
    10. `grc1leg2`
    11. `xfill`

#### Folder structure

The [OSF project page][1] provides more details on the data cleaning. For the household cleaning code to run, the LSMS-ISA data needs to be placed in the following folder structure:<br>

```stata
weather_and_agriculture
├────household_data      
│    └──country          /* one dir for each country */
│       ├──wave          /* one dir for each wave */
│       └──logs
├──weather_data
│    └──country          /* one dir for each country */
│       ├──wave          /* one dir for each wave */
│       └──logs
├──merged_data
│    └──country          /* one dir for each country */
│       ├──wave          /* one dir for each wave */
│       └──logs
├──regression_data
│    ├──country          /* one dir for each country */
│    └──logs
└────results_data        /* overall analysis */
     ├──tables
     ├──figures
     └──logs
```

  [1]: https://doi.org/10.1016/j.jdeveco.2025.103553
  [2]: https://www.worldbank.org/en/programs/lsms/initiatives/lsms-ISA
  [3]: https://osf.io/8hnz5/
