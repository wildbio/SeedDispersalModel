# SeedDispersalModel
R code and data for modeling and visualizing seed dispersal (more details in **Description** below)

*Originally published as Data S2 in Carr AN, Hooper DU, Dukes JS. 2019. Long-term propagule pressure overwhelms initial community determination of invader success. Ecosphere 10:e02826.*

## File list

gaussian_plume_dispersal_model.R

plot_boundaries.zip
	
	plots.dbf
	
	plots.prj
	
	plots.sbn
	
	plots.sbx
	
	plots.shp
	
	plots.shx

seed_source_data_2005.zip
	
	sourcedata2005.tif
	
	sourcedata2005.tif.aux
	
	sourcedata2005.tif.ovr
	
	sourcedata2005.tif.vat.cpg
	
	sourcedata2005.tif.vat.dbf

wind_data.csv

## Description

**gaussian_plume_dispersal_model.R** – This R code estimates and visualizes the total number of seeds to enter a given plot (**plots.shp**) from a source raster (**sourcedata2005.tif**) by parameterizing the tilted Gaussian plume model developed by Okubo and Levin (1989). The code allows the specification of wind speed (`u`), wind direction (`dirdata[ ]`; see note below), von Kármán constant (`k`), friction velocity (`ustar`), and seed terminal velocity (`ws`). The code also allows the user to divide the number of seeds available for dispersal by the proportion of time spent in each wind speed-direction combination (wind_data.csv) in the line `distancetemp <- data.frame(..., seed =  rep(PROPORTION*dfattributes$seed_cell...)`. As is, the code estimates seed deposition using a terminal velocity of 1.52 m/s, a wind speed of 5 m/s, a von Kármán constant of 0.41, a friction velocity of 0.1\*wind speed, and a western wind direction \[247.5º - 292.5º), with the proportion of time spent in that wind speed-direction combination equal to 0.13. The code utilizes the packages ‘raster’ (Hijmans 2016), ‘rgdal’ (Bivand et al. 2017), ‘sp’ (Pebesma and Bivand 2005, Bivand et al. 2013), ‘dplyr’ (Wickham et al. 2017), ‘mapmisc’ (Brown 2016), and ‘rasterVis’ (Lamigueiro and Hijmans 2018).

NOTE: `dirdata[ ]` calculates the direction *from* the recipient cell *to* the source patch, which is equal to the wind direction. For example, if we model dispersal using a westerly wind (i.e., a wind blowing from the direction \[247.5º - 292.5º)), we estimate seed deposition in cells that are east of the source patch, such that the direction *from* the recipient cell *to* the source patch is *west* \[247.5º - 292.5º).

**plot_boundaries.zip** – This zip folder contains vector data of experimental plots. The file **plots.shp** is used to designate the polygons within which to sum seed input per plot in **gaussian_plume_dispersal_model.R**. The attributes of the shapefile include:
	
	TRT_BLK – unique identifier for each experimental plot, consisting of functional treatment and block number
	
	TRT – functional treatment for plot
	
	BLOCK – experimental block within which each plot is located
	
	height – weighted mean height (cm) of *C. solstitialis* inflorescences in plot
	
	height_m – weighted mean height (m) of *C. solstitialis* inflorescences in plot

	centso_den – median density of *C. solstitialis* inflorescences plot-1 (2.25 m-2)

	seed_plot – number of *C. solstitialis* seeds available for dispersal per plot

	seed_cell – number of available seeds per cell (resolution 0.25 m) in plot

	seed_ht_id – unique identifier for each plot (antiquated)

**seed_source_data_2005.zip** – This zip folder contains raster data of source patches for *C. solstitialis* seed in 2005. The file **sourcedata2005.tif** is used as the seed source data in **gaussian_plume_dispersal_model.R**. In addition to the ID and OBJECTID fields automatically provided by ArcMap v10.2.2 (ESRI 2014), the attributes of the raster file include:

	Value – unique identifier for each source patch
	
	Count – number of cells (resolution 0.25 m) in source patch
	
	height – weighted mean height (m) of *C. solstitialis* inflorescences in source patch
	
	seed_cell – number of *C. solstitialis* seeds available for dispersal per cell (resolution 0.25 m) in source patch
	
	seed_ht_id – unique identifier for each source patch (antiquated)

**wind_data.csv** – This file contains the proportion of time spent in each combination of wind speed and direction at or above the assumed seed release threshold for *Centaurea solstitialis* (5 m/s). Values represent mean wind data observed in Morgan Hill, California, from 2001 to 2007 (CIMIS 2018), corrected for flowering height using a logarithmic wind profile. Data are used in **gaussian_plume_dispersal_model.R** to allocate the number of seeds available for dispersal in each wind speed-direction combination. Variables include:
	
	Direction – cardinal wind direction (i.e., direction *from* which wind blew), with each direction representing a range of degrees:
		
		E = [67.5 º, 112.5 º)
		
		N = [337.5 º, 22.5 º)
		
		NE = [22.5 º, 67.5 º)
		
		NW = [292.5 º, 337.5 º)
		
		S = [157.5 º, 202.5 º)
		
		SE = [112.5 º, 157.5 º)
		
		SW = [202.5 º, 247.5 º)
		
		W = [247.5º, 292.5º)
	
	5 m/s – proportion of total time that wind blew 4.5-5.4 m/s in each cardinal direction
	
	6 m/s – proportion of total time that wind blew 5.5-6.4 m/s in each cardinal direction
	
	Total – proportion of total time that wind blew 4.5-6.4 m/s in each cardinal direction

## Literature Cited

Bivand, R., T. Keitt, and B. Rowlingson. 2017. rgdal: bindings for the geospatial data abstraction library. R package version 1.2-7. https://CRAN.R-project.org/package=rgdal

Bivand, R. S., E. Pebesma, and V. Gomez-Rubio. 2013. Applied spatial data analysis with R. 2nd edition. Springer, New York, NY.

Brown, P. 2016. mapmisc: utilities for producing maps. R package version 1.5.0. https://CRAN.R-project.org/package=mapmisc

California Irrigation Management Information System (CIMIS). 2018. California weather database: CIMIS #132, Morgan Hill. http://ipm.ucanr.edu/calludt.cgi/WXSTATIONDATA?STN=MORGAN_HILL.A

ESRI. 2014. ArcGIS Desktop: Release 10.2.2. Environmental Systems Research Institute, Redlands, CA, USA. 

Hijmans, R. J. 2016. raster: geographic data analysis and modeling. R package version 2.8-4. https://CRAN.R-project.org/package=raster

Lamigueiro, O. P., and R. J. Hijmans. 2018. rasterVis. R package version 0.45. 

Okubo, A., and S. A. Levin. 1989. A theoretical framework for data analysis of wind dispersal of seeds and pollen. Ecology 70:329-338.

Pebesma, E. J., and R. S. Bivand. 2005. Classes and methods for spatial data in R. R News.

Wickham, H., R. Francois, L. Henry, and K. Müller. 2017. dplyr: a grammar of data manipulation. R package version 0.7.2. https://CRAN.R-project.org/package=dplyr
