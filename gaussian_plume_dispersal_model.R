# Load required packages

library(raster)
library(rgdal)
library(sp)
library(dplyr)
library(mapmisc)
library(rasterVis)

## Set working directory to location of seed source
## and plot boundary data, and add seed source data 
## for given year (raster with attributes (1) height 
## and (2) number of available seeds/cell)

setwd("...") # Specify folder path
patchdata<-raster("sourcedata2005.tif")

## Create empty data frames and raster stack for loop to fill

mydata<-data.frame(distance=NA,frompatch=NA,height=NA,seed=NA, int = NA, depnum = NA)
dirstack<-stack()
instack<-stack()

pdn<-nrow(patchdata@data@attributes[[1]])

## Run loop to create raster stack of seed shadows for all patches (one patch per run)

for(p in 1:pdn){
  tempdata<-patchdata
  
  ws<-1.52
  u<-5
  k<-0.41
  ustar<-0.1*u
  n<-nrow(tempdata@data@attributes[[1]])
  
  dfattributes<-tempdata@data@attributes[[1]]
  dfattributes$Value[dfattributes$Value!=p]<-NA
  tempdata@data@values<-dfattributes$Value
  
  if(dfattributes$height[p]>0){
  
    
  ## Calculate distance of each cell from source patch,
  ## and reclassify within-patch distance (0 m) 
  ## to distance from perimeter to center of plot (0.75 m)
    
  m<-c(0,p-1,NA,p,n,NA)
  rclmat<-matrix(m,ncol=3,byrow=TRUE)
  rc<-reclassify(tempdata,rclmat)
  distdata<-distance(rc)
  dr<-c(0,0.751)
  drmat<-matrix(dr,ncol=2,byrow=T)
  distdata<-reclassify(distdata,drmat)
  
  
  ## Create data frame with input data for each cell in raster,
  ## with number of seeds available multiplied by the proportion
  ## of time spent in given wind speed/direction (in this case, 0.13)
  
  distancetemp <- data.frame(distance = distdata@data@values, 
                             frompatch = rep(p,length(distdata@data@values)),
                             height = rep(dfattributes$height[which(dfattributes$Value==p)],length(distdata@data@values)),
                             seed = rep(0.13*dfattributes$seed_cell[which(dfattributes$Value==p)],length(distdata@data@values)))
 
  dfdepnum<-data.frame(depnum = NA)
  int.full<-data.frame(prob = NA)
  
  
  ## Create probability density function by parameterizing 
  ## tilted Gaussian plume model (Okubo and Levin 1989),
  ## where x is distance from source patch
  
  pdf<-function(x) (ws/(sqrt(2*pi)*u*sqrt((k*ustar*distancetemp$height[p]*x)/u)))*exp(-((distancetemp$height[p]-((ws*x)/u))^2)/(2*((k*ustar*distancetemp$height[p]*x)/u)))
  
  
  ## Integrate probability density function for an interval
  ## of 0.25 m around given value of x (reflecting raster
  ## resolution of 0.25 m), and multiply probability of deposition
  ## by number of seeds available
  
  for(i in 1:length(distancetemp$distance)){
    int.sub<-data.frame(prob = integrate(pdf,distancetemp$distance[i]-0.25,distancetemp$distance[i]+0.25,
                                           stop.on.error=FALSE)$value)
      depnum<-data.frame(depnum = int.sub$prob*distancetemp$seed[i])
    
    int.full<-rbind(int.full,int.sub)
    dfdepnum<-rbind(dfdepnum,depnum)
    }
  
  int<-int.full[-1,]
  depnum<-dfdepnum[-1,]
  
  
  ## Calculate number of seeds deposited within source patch
  
  rnum<-distdata
  for(j in 1:length(rnum@data@values)){
    if(rnum@data@values[j]==0.751){
      rnum@data@values[j]<-NA
    }else(rnum@data@values[j]<-depnum[j])
  }
  
  indata<-distdata
  for(k in 1:length(indata@data@values)){
    if(indata@data@values[k]!=0.751){
      indata@data@values[k]<-NA
    }else(indata@data@values[k]<-depnum[k])
  }  
  
  ## Restrict seed shadow to single wind direction
  ## In this case, modeling W wind (i.e., wind blowing FROM west TO east),
  ## so interested in recipient cells that are E of source patch (i.e.,
  ## the direction FROM recipient cell TO source patch is WEST)
  
  dirdata<-direction(indata,degrees=TRUE)
  dirdata[dirdata<=247.5|dirdata>292.5]<-NA
  
  dirdep<-mask(rnum,dirdata)
  
  ## Combine runs into cumulative rasters, data frames
  
  dirstack<-stack(dirstack,dirdep)
  instack<-stack(instack,indata)
  
  newdata<-cbind(distancetemp,int,depnum)
  
  mydata<-rbind(mydata,newdata)
  }
}

## Combine cumulative deposition outside/inside source patches
## into single raster, sum seed input per cell using all
## seed shadows, vizualize raster, and save raster to file

allstack<-stack(dirstack,instack)
sum.stack <- calc(allstack, sum, na.rm = TRUE)
plot(sum.stack)
writeRaster(sum.stack,"sumstack_WIND_YEAR.tif")

## Compile and save data (number of seeds per cell) to csv file

mydata<-mydata[-1,]
alldata<-cbind(mydata,int.full,depnum)
summary(alldata)
write.csv(alldata,"dispersaldata_cell_YEAR.csv")


## Make map of plots with seed input per plot

dev.off()

# Upload plot (polygon) boundaries

plotbnds<-readOGR("plots.shp")

# Make sure plot boundaries line up with raster
plot(sum.stack)
plot(tempdata,add=T)
plot(plotbnds,add=T)

# Visualize seed shadows over plot
colfunc <- colorRampPalette(c("white","black"))
plot(sum.stack,col=colfunc(10))
plot(plotbnds,add=T)

# Sum number of seeds deposited in each plot
plotseed<-extract(sum.stack,plotbnds,fun=sum)
plotseed<-matrix(ncol=1,nrow=60,data=plotseed)

# Add seed input as attribute for plot boundary shapefile
plotnew<-plotbnds
plotnew@data$seedinput<-plotseed[,1]
write.csv(plotnew@data,"NEWFILENAME.csv")

# Map plots with color symbolizing seed input
colinput<-cut(plotnew$seedinput,breaks=quantile(plotnew$seedinput,seq(0,1,0.05)),labels=colfunc(20))
summary(plotnew$seedinput)

plot(plotnew,las=1,axes=T,col=colfunc(20)[unclass(colinput)],tck=-0.03,cex.axis=0.55)
box(col="white")
legend(x=617235,y=4115992,title="Seed input",
       c("0-100","100-250","250-550","550-2500"),
       bty="n",cex=0.7,fill=colfunc(4))
scaleBar(x=617240,y=4116010,proj4string(plotnew),bg="transparent",bty="n",
         cex=0.7)
mtext(side=1,"Easting",line=2,cex=0.8)
mtext(side=2,"Northing",line=3.2,cex=0.8)

