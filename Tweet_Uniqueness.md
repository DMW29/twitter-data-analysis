# Tweet Uniqueness
Dianne Waterson  
October 28, 2016  



## Hypothesis

The expectation of Twitter Tweets within a dataset may be that a retweet is not an original post and therefore can be duplicated within the dataset. The expectation of Twitter Tweets may also be tweets not identified as a retweet will be an original tweet and therefore will not be duplicated elsewhere in the dataset. This is the hypothesis of this study.

## Housekeeping

Retweets are identified in the dataset by the presence of child 'retweet status' or 'is quote status' nodes. Tweets are uniquely identified using the text attribute that contains the tweet. The documentation describing tweet attributes is referenced here --> https://dev.twitter.com/overview/api/tweets. The non-presence of the 'retweet status' attribute in conjunction with the 'is quote status' attribute set to FALSE defines an original tweet. Unique tweets are tweets whose specific text is not duplicated within the dataset. 

## Analysis

Based upon the criteria that 'retweet status' is not present and 'is quote status' is FALSE, a tweet is defined as an 'original tweet'. Otherwise, it is defined as a 'retweet'. Based upon the criteria that the specific tweet text is undulpicated within the dataset, a tweet is defined as a 'unique tweet'. Otherwise, the tweet is defined as 'not unique'. A function is written to analyze each of thirteen datasets out of the 24 found here --> https://drive.google.com/drive/folders/0B7-RjEk83fGlYXRNcGJOY1ZjcVU. A contigency analysis is preformed to determine percentages of tweet categories. There are four tweet categories, (1) original and unique, (2) an original retweet, (3) original but duplicated, and (4) a duplicated retweet. The expectation is categories 2 and 3 do not exist.

## Summary of Findings

Congruent with the idea of 'messy data', the findings of this study is that original tweets are not always unique within a dataset and retweets are not always duplicated within a dataset. In all but three of the datasets, each of the four categories defined for this study contain tweets. Three of the datasets contain only retweets. 

Out of the ten datasets that report tweets in each of the four categories, an average 24.43% are duplicate original tweets, an average 16.07% are unique original tweets, an average 55.97% are duplicate retweets, and an average 3.54% are unique retweets. Unique tweets make up an average of only 19.35% of each dataset.

It is thought original tweets (category 2) that are not unique within a dataset can be attributed to two mechanisms. The first considers a tweeter actually posting the exact same text more that once without using any retweet options. Something like a copy and paste. The second mechanism considers the how tweets are queried from the Twitter API. It is the case that downloading tweets through the API may temporarily stop and create a backlog of tweets matching the user defined criteria. When the downloader re-engages, it plays catch-up. During catch-up phase is when it is thought duplicate tweets are downloaded.

Tweets designated as a retweet but are unique (category 3) within the dataset may be associated with timing. The extraction of tweets may begin at such a time to capture the last retweet of a particular message. 

Regardless of the causes of duplication or uniqueness, based on this analysis, it seems the best method of identifying a unique set of tweets within a particular dataset is to extract them through a comparison of the actual text. This method will result in a dataset of unique tweets that can be either original tweets or retweets.


```r
## Set working directory
setwd("~/Twitter Project/Data")

## Check for required packages and install if need be.
packages<-function(x){
     x<-as.character(match.call()[[2]])
     if (!require(x,character.only=TRUE)){
          install.packages(pkgs=x,repos="http://cran.r-project.org", dependencies = TRUE)
          require(x,character.only=TRUE)
     }
}
packages(tidyjson)
```

```
## Loading required package: tidyjson
```

```r
packages(twitteR)
```

```
## Loading required package: twitteR
```

```r
packages(RCurl)
```

```
## Loading required package: RCurl
```

```
## Loading required package: bitops
```

```r
packages(plyr)
```

```
## Loading required package: plyr
```

```
## 
## Attaching package: 'plyr'
```

```
## The following object is masked from 'package:twitteR':
## 
##     id
```

```r
packages(dplyr)
```

```
## Loading required package: dplyr
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:plyr':
## 
##     arrange, count, desc, failwith, id, mutate, rename, summarise,
##     summarize
```

```
## The following objects are masked from 'package:twitteR':
## 
##     id, location
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
packages(gmodels)
```

```
## Loading required package: gmodels
```

```r
## Create file list
filenames <- c("AtlantaDream052916.out",
               "WomensNIT noBOM.txt",
               "ChampionshipWeek1.out",
               "ChampionshipWeek2.out",
               "ChicagoSky052916.out",
               "ConnecticutSun052916.out",
               "DWingsHoops052916.out",
               "IndianaFever052916.out",
               "LA_Sparks052616.out",
               "MinnesotaLynx052716.out",
               "PhoenixHashtag.out",
               "SAStars052716.out",
               "WashMystics052916.out")

## Read in each file in the file list and calculate category percentages
for(i in filenames) {
     print(i)
     data <- read_json(i, format = "jsonl")
     class(data)

## Adding new columns to your data.frame is accomplished with spread_values(),
## which lets you dive into (potentially nested) JSON objects and extract 
## specific values. spread_values() takes jstring(), jnumber() or jlogical() 
## function calls as arguments in order to specify the type of the data that 
## should be captured at each desired key location. Here we are capturing the 
## tweet id, the tweet text, retweet status and quote status.
     twts <- data %>%
      spread_values(
               id <- jstring("id_str"),
               text <- jstring("text"),
               retwt_st <- jstring("retweeted_status"),
               qute_st <- jstring("is_quote_status")
      ) %>%
     tbl_df

## Change column names of data frame
     colnames(twts) <- c("doc.id", "tweet.id", "tweet", "retweet_status", "quote_status")

## Get tweets from data frame into a character vector
     st <- statusFactory$new(text = twts$tweet)
     twt <- st$getText()

## Create a list of tweets from character vector in order to determine uniqueness
## of each tweet
     ltwt <- as.list(twt)

## Gather statistics on whether a tweet is unique, original versus a retweet, 
## whether an original tweet is unique, or whether a retweet is unique using a
## contingency table. 
     twts$unique <- ifelse((!ltwt %in% ltwt[duplicated(ltwt)])==TRUE,
                      "Unique", "Not_Unique")
     twts$orig <- ifelse(is.na(twts$retweet_status) & twts$quote_status == "FALSE",
                    "Orig_Tweet", "Retweet")
     CrossTable(twts$unique,twts$orig, digits=3, max.width = 5, expected=TRUE, 
           prop.r=TRUE, prop.c=TRUE, prop.t=TRUE, prop.chisq=TRUE, 
           chisq = TRUE, fisher=FALSE, mcnemar=FALSE, resid=FALSE, 
           sresid=FALSE, asresid=FALSE, missing.include=FALSE,
           format=c("SAS","SPSS"), dnn = NULL)
}
```

```
## [1] "AtlantaDream052916.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |              Expected N |
## | Chi-square contribution |
## |           N / Row Total |
## |           N / Col Total |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  898 
## 
##  
##              | twts$orig 
##  twts$unique | Orig_Tweet |    Retweet |  Row Total | 
## -------------|------------|------------|------------|
##   Not_Unique |        234 |        503 |        737 | 
##              |    302.843 |    434.157 |            | 
##              |     15.650 |     10.916 |            | 
##              |      0.318 |      0.682 |      0.821 | 
##              |      0.634 |      0.951 |            | 
##              |      0.261 |      0.560 |            | 
## -------------|------------|------------|------------|
##       Unique |        135 |         26 |        161 | 
##              |     66.157 |     94.843 |            | 
##              |     71.638 |     49.971 |            | 
##              |      0.839 |      0.161 |      0.179 | 
##              |      0.366 |      0.049 |            | 
##              |      0.150 |      0.029 |            | 
## -------------|------------|------------|------------|
## Column Total |        369 |        529 |        898 | 
##              |      0.411 |      0.589 |            | 
## -------------|------------|------------|------------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  148.1743     d.f. =  1     p =  4.345327e-34 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  146.0298     d.f. =  1     p =  1.278871e-33 
## 
##  
## [1] "WomensNIT noBOM.txt"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  146 
## 
##  
##              | twts$orig 
##  twts$unique |   Retweet | Row Total | 
## -------------|-----------|-----------|
##   Not_Unique |       141 |       141 | 
##              |     0.966 |           | 
## -------------|-----------|-----------|
##       Unique |         5 |         5 | 
##              |     0.034 |           | 
## -------------|-----------|-----------|
## Column Total |       146 |       146 | 
## -------------|-----------|-----------|
## 
##  
## [1] "ChampionshipWeek1.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  61 
## 
##  
##              | twts$orig 
##  twts$unique |   Retweet | Row Total | 
## -------------|-----------|-----------|
##   Not_Unique |        40 |        40 | 
##              |     0.656 |           | 
## -------------|-----------|-----------|
##       Unique |        21 |        21 | 
##              |     0.344 |           | 
## -------------|-----------|-----------|
## Column Total |        61 |        61 | 
## -------------|-----------|-----------|
## 
##  
## [1] "ChampionshipWeek2.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  131 
## 
##  
##              | twts$orig 
##  twts$unique |   Retweet | Row Total | 
## -------------|-----------|-----------|
##   Not_Unique |        88 |        88 | 
##              |     0.672 |           | 
## -------------|-----------|-----------|
##       Unique |        43 |        43 | 
##              |     0.328 |           | 
## -------------|-----------|-----------|
## Column Total |       131 |       131 | 
## -------------|-----------|-----------|
## 
##  
## [1] "ChicagoSky052916.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |              Expected N |
## | Chi-square contribution |
## |           N / Row Total |
## |           N / Col Total |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  357 
## 
##  
##              | twts$orig 
##  twts$unique | Orig_Tweet |    Retweet |  Row Total | 
## -------------|------------|------------|------------|
##   Not_Unique |         80 |        197 |        277 | 
##              |    101.644 |    175.356 |            | 
##              |      4.609 |      2.672 |            | 
##              |      0.289 |      0.711 |      0.776 | 
##              |      0.611 |      0.872 |            | 
##              |      0.224 |      0.552 |            | 
## -------------|------------|------------|------------|
##       Unique |         51 |         29 |         80 | 
##              |     29.356 |     50.644 |            | 
##              |     15.959 |      9.250 |            | 
##              |      0.637 |      0.362 |      0.224 | 
##              |      0.389 |      0.128 |            | 
##              |      0.143 |      0.081 |            | 
## -------------|------------|------------|------------|
## Column Total |        131 |        226 |        357 | 
##              |      0.367 |      0.633 |            | 
## -------------|------------|------------|------------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  32.48931     d.f. =  1     p =  1.198497e-08 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  31.00559     d.f. =  1     p =  2.572859e-08 
## 
##  
## [1] "ConnecticutSun052916.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |              Expected N |
## | Chi-square contribution |
## |           N / Row Total |
## |           N / Col Total |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  402 
## 
##  
##              | twts$orig 
##  twts$unique | Orig_Tweet |    Retweet |  Row Total | 
## -------------|------------|------------|------------|
##   Not_Unique |        100 |        180 |        280 | 
##              |    152.537 |    127.463 |            | 
##              |     18.095 |     21.655 |            | 
##              |      0.357 |      0.643 |      0.697 | 
##              |      0.457 |      0.984 |            | 
##              |      0.249 |      0.448 |            | 
## -------------|------------|------------|------------|
##       Unique |        119 |          3 |        122 | 
##              |     66.463 |     55.537 |            | 
##              |     41.530 |     49.699 |            | 
##              |      0.975 |      0.025 |      0.303 | 
##              |      0.543 |      0.016 |            | 
##              |      0.296 |      0.007 |            | 
## -------------|------------|------------|------------|
## Column Total |        219 |        183 |        402 | 
##              |      0.545 |      0.455 |            | 
## -------------|------------|------------|------------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  130.9787     d.f. =  1     p =  2.502721e-30 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  128.4975     d.f. =  1     p =  8.735527e-30 
## 
##  
## [1] "DWingsHoops052916.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |              Expected N |
## | Chi-square contribution |
## |           N / Row Total |
## |           N / Col Total |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  287 
## 
##  
##              | twts$orig 
##  twts$unique | Orig_Tweet |    Retweet |  Row Total | 
## -------------|------------|------------|------------|
##   Not_Unique |        107 |        124 |        231 | 
##              |    123.951 |    107.049 |            | 
##              |      2.318 |      2.684 |            | 
##              |      0.463 |      0.537 |      0.805 | 
##              |      0.695 |      0.932 |            | 
##              |      0.373 |      0.432 |            | 
## -------------|------------|------------|------------|
##       Unique |         47 |          9 |         56 | 
##              |     30.049 |     25.951 |            | 
##              |      9.563 |     11.072 |            | 
##              |      0.839 |      0.161 |      0.195 | 
##              |      0.305 |      0.068 |            | 
##              |      0.164 |      0.031 |            | 
## -------------|------------|------------|------------|
## Column Total |        154 |        133 |        287 | 
##              |      0.537 |      0.463 |            | 
## -------------|------------|------------|------------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  25.63747     d.f. =  1     p =  4.119611e-07 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  24.14735     d.f. =  1     p =  8.923878e-07 
## 
##  
## [1] "IndianaFever052916.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |              Expected N |
## | Chi-square contribution |
## |           N / Row Total |
## |           N / Col Total |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  1101 
## 
##  
##              | twts$orig 
##  twts$unique | Orig_Tweet |    Retweet |  Row Total | 
## -------------|------------|------------|------------|
##   Not_Unique |        199 |        741 |        940 | 
##              |    283.451 |    656.549 |            | 
##              |     25.161 |     10.863 |            | 
##              |      0.212 |      0.788 |      0.854 | 
##              |      0.599 |      0.964 |            | 
##              |      0.181 |      0.673 |            | 
## -------------|------------|------------|------------|
##       Unique |        133 |         28 |        161 | 
##              |     48.549 |    112.451 |            | 
##              |    146.905 |     63.423 |            | 
##              |      0.826 |      0.174 |      0.146 | 
##              |      0.401 |      0.036 |            | 
##              |      0.121 |      0.025 |            | 
## -------------|------------|------------|------------|
## Column Total |        332 |        769 |       1101 | 
##              |      0.302 |      0.698 |            | 
## -------------|------------|------------|------------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  246.3529     d.f. =  1     p =  1.620221e-55 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  243.4444     d.f. =  1     p =  6.977448e-55 
## 
##  
## [1] "LA_Sparks052616.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |              Expected N |
## | Chi-square contribution |
## |           N / Row Total |
## |           N / Col Total |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  704 
## 
##  
##              | twts$orig 
##  twts$unique | Orig_Tweet |    Retweet |  Row Total | 
## -------------|------------|------------|------------|
##   Not_Unique |        238 |        286 |        524 | 
##              |    290.284 |    233.716 |            | 
##              |      9.417 |     11.696 |            | 
##              |      0.454 |      0.546 |      0.744 | 
##              |      0.610 |      0.911 |            | 
##              |      0.338 |      0.406 |            | 
## -------------|------------|------------|------------|
##       Unique |        152 |         28 |        180 | 
##              |     99.716 |     80.284 |            | 
##              |     27.414 |     34.049 |            | 
##              |      0.844 |      0.156 |      0.256 | 
##              |      0.390 |      0.089 |            | 
##              |      0.216 |      0.040 |            | 
## -------------|------------|------------|------------|
## Column Total |        390 |        314 |        704 | 
##              |      0.554 |      0.446 |            | 
## -------------|------------|------------|------------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  82.57699     d.f. =  1     p =  1.016333e-19 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  81.00515     d.f. =  1     p =  2.251299e-19 
## 
##  
## [1] "MinnesotaLynx052716.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |              Expected N |
## | Chi-square contribution |
## |           N / Row Total |
## |           N / Col Total |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  704 
## 
##  
##              | twts$orig 
##  twts$unique | Orig_Tweet |    Retweet |  Row Total | 
## -------------|------------|------------|------------|
##   Not_Unique |        119 |        418 |        537 | 
##              |    191.459 |    345.541 |            | 
##              |     27.422 |     15.194 |            | 
##              |      0.222 |      0.778 |      0.763 | 
##              |      0.474 |      0.923 |            | 
##              |      0.169 |      0.594 |            | 
## -------------|------------|------------|------------|
##       Unique |        132 |         35 |        167 | 
##              |     59.541 |    107.459 |            | 
##              |     88.179 |     48.859 |            | 
##              |      0.790 |      0.210 |      0.237 | 
##              |      0.526 |      0.077 |            | 
##              |      0.188 |      0.050 |            | 
## -------------|------------|------------|------------|
## Column Total |        251 |        453 |        704 | 
##              |      0.357 |      0.643 |            | 
## -------------|------------|------------|------------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  179.6543     d.f. =  1     p =  5.766306e-41 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  177.1835     d.f. =  1     p =  1.997143e-40 
## 
##  
## [1] "PhoenixHashtag.out"
```

```
## Warning in chisq.test(t, correct = TRUE, ...): Chi-squared approximation
## may be incorrect
```

```
## Warning in chisq.test(t, correct = FALSE, ...): Chi-squared approximation
## may be incorrect
```

```
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |              Expected N |
## | Chi-square contribution |
## |           N / Row Total |
## |           N / Col Total |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  279 
## 
##  
##              | twts$orig 
##  twts$unique | Orig_Tweet |    Retweet |  Row Total | 
## -------------|------------|------------|------------|
##   Not_Unique |         70 |        202 |        272 | 
##              |     75.068 |    196.932 |            | 
##              |      0.342 |      0.130 |            | 
##              |      0.257 |      0.743 |      0.975 | 
##              |      0.909 |      1.000 |            | 
##              |      0.251 |      0.724 |            | 
## -------------|------------|------------|------------|
##       Unique |          7 |          0 |          7 | 
##              |      1.932 |      5.068 |            | 
##              |     13.296 |      5.068 |            | 
##              |      1.000 |      0.000 |      0.025 | 
##              |      0.091 |      0.000 |            | 
##              |      0.025 |      0.000 |            | 
## -------------|------------|------------|------------|
## Column Total |         77 |        202 |        279 | 
##              |      0.276 |      0.724 |            | 
## -------------|------------|------------|------------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  18.83623     d.f. =  1     p =  1.424357e-05 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  15.30294     d.f. =  1     p =  9.157393e-05 
## 
##  
## [1] "SAStars052716.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |              Expected N |
## | Chi-square contribution |
## |           N / Row Total |
## |           N / Col Total |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  534 
## 
##  
##              | twts$orig 
##  twts$unique | Orig_Tweet |    Retweet |  Row Total | 
## -------------|------------|------------|------------|
##   Not_Unique |        151 |        259 |        410 | 
##              |    187.341 |    222.659 |            | 
##              |      7.049 |      5.931 |            | 
##              |      0.368 |      0.632 |      0.768 | 
##              |      0.619 |      0.893 |            | 
##              |      0.283 |      0.485 |            | 
## -------------|------------|------------|------------|
##       Unique |         93 |         31 |        124 | 
##              |     56.659 |     67.341 |            | 
##              |     23.309 |     19.612 |            | 
##              |      0.750 |      0.250 |      0.232 | 
##              |      0.381 |      0.107 |            | 
##              |      0.174 |      0.058 |            | 
## -------------|------------|------------|------------|
## Column Total |        244 |        290 |        534 | 
##              |      0.457 |      0.543 |            | 
## -------------|------------|------------|------------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  55.90105     d.f. =  1     p =  7.621195e-14 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  54.37339     d.f. =  1     p =  1.657932e-13 
## 
##  
## [1] "WashMystics052916.out"
## 
##  
##    Cell Contents
## |-------------------------|
## |                       N |
## |              Expected N |
## | Chi-square contribution |
## |           N / Row Total |
## |           N / Col Total |
## |         N / Table Total |
## |-------------------------|
## 
##  
## Total Observations in Table:  307 
## 
##  
##              | twts$orig 
##  twts$unique | Orig_Tweet |    Retweet |  Row Total | 
## -------------|------------|------------|------------|
##   Not_Unique |         35 |        222 |        257 | 
##              |     62.785 |    194.215 |            | 
##              |     12.296 |      3.975 |            | 
##              |      0.136 |      0.864 |      0.837 | 
##              |      0.467 |      0.957 |            | 
##              |      0.114 |      0.723 |            | 
## -------------|------------|------------|------------|
##       Unique |         40 |         10 |         50 | 
##              |     12.215 |     37.785 |            | 
##              |     63.202 |     20.432 |            | 
##              |      0.800 |      0.200 |      0.163 | 
##              |      0.533 |      0.043 |            | 
##              |      0.130 |      0.033 |            | 
## -------------|------------|------------|------------|
## Column Total |         75 |        232 |        307 | 
##              |      0.244 |      0.756 |            | 
## -------------|------------|------------|------------|
## 
##  
## Statistics for All Table Factors
## 
## 
## Pearson's Chi-squared test 
## ------------------------------------------------------------
## Chi^2 =  99.90427     d.f. =  1     p =  1.599438e-23 
## 
## Pearson's Chi-squared test with Yates' continuity correction 
## ------------------------------------------------------------
## Chi^2 =  96.34101     d.f. =  1     p =  9.670611e-23 
## 
## 
```
