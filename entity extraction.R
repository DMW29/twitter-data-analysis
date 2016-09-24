## Set working directory
setwd("~/Twitter Project/Entity Extraction")

## Check for required packages and install if need be.
packages<-function(x){
     x<-as.character(match.call()[[2]])
     if (!require(x,character.only=TRUE)){
          install.packages(pkgs=x,repos="http://cran.r-project.org", dependencies = TRUE)
          require(x,character.only=TRUE)
     }
}

## To install rJava ensure the bit version of R and Java match, i.e., if
## running a 64 bit version of R, then make sure the system is running a 64 bit
## version of Java. Go to the Windows command prompt and type 
## 'java -XshowSettings:all' and hit enter. Scroll up to find 
## 'sun.arch.data.model'. If it is set equal to 64, the system is running the
## 64 bit version.

packages(rJava)
packages(NLP)
packages(openNLP)
packages(RWeka)
packages(qdap)

## openNLPmodels.en is for entity extraction
install.packages("openNLPmodels.en",
                 repos = "http://datacube.wu.ac.at/",
                 type = "source")

## Reference: https://rpubs.com/lmullen/nlp-chapter
## First, we will tokenize the paragraph into words and sentences. Next we will
## extract the names of people and places from the documents to see which 
## people they mention in common and which places they visited.
library(NLP)
library(openNLP)
library(RWeka)

## Determine size of text file
cat("File size (Bytes):", file.info("WNIT3rdRnd_WomensNIT_UNCvUCLA_12.out")$size)
cat("File size (MegaBytes):", (file.info("WNIT3rdRnd_WomensNIT_UNCvUCLA_12.out")$size/1024/1024))

## Clean up the Twitter data and read it in as 
fname <- "WomensNIT noBOM.txt"
## library(rjson)
## json_file <- fname
## json_data <- fromJSON(paste(readLines(json_file), collapse=""))



