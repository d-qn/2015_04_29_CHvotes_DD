## Data for all Swiss national votes

1. Duplicate the latest csv data file in *data* (named such as: **allCH_ballots - VOTES_allCH_**2016-03-01.csv ) and renamed to refect the date of the ballot

1. Get the official [BFS data](http://www.bfs.admin.ch/bfs/portal/fr/index/themen/17/03.html)
2. Get the translated vote names from SWI ballot map (download data)
  * Reshuffle columns and rows so that language and vote objects match BFS order
  * Languages order: eng ger	fre	ita	spa	por	jpn chi rus ara
  
1. Add rows manually and be sure to fill
   * Inverted counter (1st column)
   * Keep the same vote ID as the BFS! (2nd column)
   * Ballot date
   * Vote names in eng ger	fre	ita	spa	por	jpn chi rus ara ()
   * Yes and No counts (columns Z & AA)
   * Columns (AP until AV): Turnout (AP), °Yes (AR), °NO (AS), outcome (AT), type (AV)
   * Type of vote (AV), needs to be one of: initiative, facultative Referendum, mandatory Referendum

 
   




## Using C2D.ch 

Stopped since 2015, because their data were not updated

#### From C2D.ch

* Downloaded from:  [C2D](http://www.c2d.ch/votes.php?level=1&country=1&yearr=allyears&speyear%5B%5D=2015&result=0&terms=&table=votes&sub=Submit_Query) (Data -> Vote search -> Country: **Switzerland**)
 * Raw data file: [initiativeDataFile from c2c.ch](/Users/nguyendu/Google Drive/swissinfo/2015_04_22_initiatives/data/VOTEScsv.csv)
 
 * Open in Open Office and discard footer (the last 4 lines) and save it as [Votescsv_cleaned.csv](/Users/nguyendu/Google Drive/swissinfo/2015_04_22_initiatives/data/VOTEScsv_cleaned.csv)
 
### Google sheet 
 
 * Import into Google drive: [allCH_ballots](https://docs.google.com/a/swissinfo.ch/spreadsheets/d/1c4XQLIP9FiKWAPkKZ6IGq5LDStQXymAd7t6_GpqvoMo/edit#gid=953666393)
 
 
 
#### Create the interactive infographics

#### Download the data

* Download that file as CSV: [data file (c2d.ch)](https://docs.google.com/spreadsheets/d/1c4XQLIP9FiKWAPkKZ6IGq5LDStQXymAd7t6_GpqvoMo/edit#gid=953666393)
* Put that file (_allCH_ballots - VOTES_allCH.csv_) into the folder **data**
* Run the script: _01_processCSVfromGsheet.R_
* This will create another csv file with an additional column _type_: type of vote (initiative, mandatory or facultative referendum)


* Download the microcopy file as **TSV** [data file (c2d.ch)](https://docs.google.com/spreadsheets/d/1c4XQLIP9FiKWAPkKZ6IGq5LDStQXymAd7t6_GpqvoMo/edit#gid=953666393) (**second sheet**)


##### Generate the graphics

Run the script: _02_allCHvotes_heatmap_tableTooltip.R_

## Arabic 

* **Modify the first HTML tag to**
```
<html dir="rtl">
```








 