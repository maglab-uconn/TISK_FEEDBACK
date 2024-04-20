# WORKFLOW FOR TISK WITH FEEDBACK

#### Jim Magnuson, Heejo You, & Thomas Hannagan


This repository includes everything you need to reproduce the simulations, analyses, and figures from our paper, _"Lexical feedback in the Time-Invariant String Kernel (TISK) model of spoken word recognition"_.  However, proceed with caution. We have noted that some scripts take several minutes or even **several hours** to run.

Most code in this repository was developed by Heejo You. Thomas Hannagan was the original creator of TISK, along with Jonathan Grainger and Jim Magnuson, and contributed important advice and ideas for this project. Magnuson did the TRACE analyses and model comparisons, and wrote the first draft of the paper.


## FILES

Our first step is to make sure we have all the files. This repo is set up to have the lexicon files in the top level, but then all simulation (Python) scripts in the SIMULATIONS folder, and all analysis (R) scripts in ANALYSIS. As simulations progress, data is written into directories inside the Results directory (if it does not exist, it will be created). As ANALYSIS progress, graphs are deposited in the Graphs folder (if it does not exist, it will be created).

#### Lexicon files (top level)
`./Pronunciation_Data.txt`  

#### Simulation files (in SIMULATIONS)
`./SIMULATIONS/Torch_TISK_Class.py # core TISK functions`<br>
`./SIMULATIONS/Model_Setup.py`<br>  
`./SIMULATIONS/Basic_Data.py` <br>
`./SIMULATIONS/Ganong_Effect.py`  <br>
`./SIMULATIONS/Retroactive_Effect.py` <br>
`./SIMULATIONS/Phoneme_Restoration.py`  <br>
`./SIMULATIONS/Graceful_Degradation.py`  <br>
`./SIMULATIONS/Feedback_Map.py`  <br>
`./SIMULATIONS/No_Feedback_Map.py`

#### Analysis files (in ANALYSIS)
`./ANALYSIS/Feedback_Map.R`<br>
`./ANALYSIS/Ganong_Effect.R`<br>
`./ANALYSIS/Graceful_Degradation.R`<br>
`./ANALYSIS/No_Feedback_Map.R`<br>
`./ANALYSIS/Phoneme_Restoration.R`<br>
`./ANALYSIS/Retroactive_Effect.R`<br>
`./compare_lexical_dimensions_2023.11.15.R`<br>
`./my.pairscor_both_fits_forPub.R`<br>
`./plot_competitor_types.2023.R`<br>
`./trace_handling_functions.2015.12.01.R`

## DOING SIMULATIONS

We have confirmed that these simulations all work on a MacBookPro laptop with Anaconda and Python 3.7. installed, with the user profile set up such that the Anaconda version of python is the first in the path.

At the terminal/command line, in the top-level directory, enter any or all of the following commands to run the simulations reported in the manuscript.  

`# SIMULATION 1`<br>
`# BASIC SIMS OF ALL WORDS FOR ACCURACY AND RT` <br>
`# Results will be in ./Results/Basic_Data/`  <br>
`python SIMULATIONS/Basic_Data.py`<p>

`# SIMULATION 2: Ganong Effect `  <br>
`# Results will be in ./Results/Ganong_Effect/`<br>
`python SIMULATIONS/Ganong_Effect.py`

`# SIMULATION 3: Retroactive effect`  <br>
`# Results will be in ./Results/Retroactive_Effect/`  <br>
`python SIMULATIONS/Retroactive_Effect.py`

`# SIMULATION 4: Phoneme restoration`  <br>
`# Results will be in ./Results/Phoneme_Restoration/` <br>
`python SIMULATIONS/Phoneme_Restoration.py`

`# SIMULATION 5: Graceful degradation`  <br>
`# *Note: this command takes ~5-10 minutes to run.*`  <br>
`# Results will be in ./Results/Graceful_Degradation/` <br>
`python SIMULATIONS/Graceful_Degradation.py`

`# SIMULATION 6: Parameter space mapping`  <br>
`# *Note: these commands take SEVERAL HOURS to run.*` <br>
`# Results will be in ./Results/Ganong_Effect/ and ` <br>
`# ./Results/Graceful_Degradation/`  <br>
`python SIMULATIONS/Feedback_Map.py`

`# Results will be in ./Results/Graceful_Degradation/`  <br>
`python SIMULATIONS/No_Feedback_Map.py`

## DOING ANALYSIS

The ANALYSIS can be done by opening each script in R or R Studio, or by calling files from the command line using Rscript (from the base directory for the repository). In RStudio, use a project file or manually set the work directory. Linux and Mac users can use the Rscript tool to run ANALYSIS from the command line without making any changes to the R scripts, as shown below. Windows users can also use Rscript.exe. We leave it to motivated users to determine how to do this under Windows.

For each analysis below, graphs show up in logically named subdirectories under Graphs. The first several analyses are conducted using Rscript.

`Rscript ANALYSIS/Ganong_Effect.R`  <br>
`Rscript ANALYSIS/Retroactive_Effect.R`  <br>
`Rscript ANALYSIS/Phoneme_Restoration.R`  <br>
`Rscript ANALYSIS/Graceful_Degradation.R`  <br>
`Rscript ANALYSIS/Feedback_Map.R`  <br>
`Rscript ANALYSIS/No_Feedback_Map.R`

One final step uses a shell script to make the panels for Figure 5 (which wind up in Graphs/TimeCourse):

`source do_new_timeplots.src`

### TRACE data
The TRACE data is archival so we do not provide code for TRACE simulations or analyses. If you are interested in these steps, contact Jim Magnuson.

### ADDITIONAL NOTES ON figures
- Figures 1, 4a, and 4b come from Hannagan et al. (2013)
- Figures 2 and 3 come from figshare (see references in paper)
