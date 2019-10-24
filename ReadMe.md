<pre>
R CODE FOR COHORT CHANGE RATIO-BASED STABLE POPULATION REVIEW SHINY APP - PRELIMINARY WORK, STILL FIGURING/LEARNING AND CHECKING

-----
Some to-do's for the coming week (10192019): 
      -interpolation and timing of mortality adjustment fix/improve
      -open-ended age group cohort-change-ratio and mortality adjustment fix/improve
      -ages 0 to 4 mortality update decision
      -possible cohort change ratios averaging and/or trending (on longer time series of single-year data)
And for the next two to three weeks (10202019):      
      -autoregressive models for the input components, and stochastic option
            (following https://applieddemogtoolbox.github.io/Toolbox/#StochasticForecast)
      -employment-based migration setup
            (following https://applieddemogtoolbox.github.io/Toolbox/#EmplPopHousProj)

-----
References, resources, and related info: 
  Software: 
    -R: https://www.r-project.org/
    -Shiny for R: https://shiny.rstudio.com/

  Population estimates inputs: 
    -US Census Bureau Vintage 2018 Population Estimates: https://www.census.gov/programs-surveys/popest.html

  More information on iTFR: 
    -Hauer and Schmertmann (2019): https://osf.io/adu98/
    -Hauer, Baker, and Brown (2013): https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0067226

  More information on cohort change ratios, including a chapter on stable population: 
    -Baker, Swanson, Tayman, and Tedrow (2017): https://www.worldcat.org/title/cohort-change-ratios-and-their-applications/oclc/988385033
    
  Slides with background thoughts on adjusting net migration: 
    -Hunsinger (2007): https://edyhsgr.github.io/eddieh/documents/ProjPresentation.pdf
   
  Net migration by age over time comparisons from Alaska data: 
    -Hunsinger (2018): http://shiny.demog.berkeley.edu/eddieh/AKPFDMigrationReview/
    
  Interface with net migration adjustment examples and comparisons: 
    -Hunsinger (2019): http://shiny.demog.berkeley.edu/eddieh/NMAdjustCompare/ 
    
  Graph of e0 and Brass' relational life table alpha by US state: 
    -https://twitter.com/ApplDemogToolbx/status/1079286699941752832 
    
  Model life table (0.0 alpha) is the 5x5 2010 to 2014 life table for California from the United States Mortality Database:
    -https://usa.mortality.org/index.php
    
  Migration adjustment profile was made from the US Census Bureau's 2013 to 2017 American Community Survey Public Use Microdata Sample, accessed via IPUMS USA, University of Minnesota: 
    -https://usa.ipums.org/usa/
  
  Related Shiny for R application: 
    -(Hunsinger 2019) http://shiny.demog.berkeley.edu/eddieh/CCRStable/
  
-Eddie Hunsinger (California Department of Finance), August 2019 (updated October 2019)

-----
<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/3.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="https://creativecommons.org/licenses/by-sa/3.0/igo/">Creative Commons Attribution-ShareAlike 3.0 International License</a>.
</pre>