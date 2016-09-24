# Entity Extraction
Dianne Waterson  
September 23, 2016  



Set working directory

```r
setwd("~/Twitter Project/Entity Extraction")
```

Check for required packages and install if need be.

```r
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
packages(NLP)
```

```
## Loading required package: NLP
```

```r
packages(openNLP)
```

```
## Loading required package: openNLP
```

```r
packages(magritter)
```

```
## Loading required package: magritter
```

```
## Installing package into 'C:/Users/Dianne/Documents/R/win-library/3.2'
## (as 'lib' is unspecified)
```

```
## Loading required package: magritter
```

The tidyjson package takes an alternate approach to structuring JSON data 
into tidy data.frames. Similar to tidyr, tidyjson builds a grammar for 
manipulating JSON into a tidy table structure. Tidyjson is based on the 
following principles:

* Leverage other libraries for efficiently parsing JSON (jsonlite)
* Integrate with pipelines built on dplyr and the magrittr %>% operator
* Turn arbitrarily complex and nested JSON into tidy data.frames that can be joined later
* Guarantee a deterministic data.frame column structure
* Naturally handle 'ragged' arrays and / or objects (varying lengths by document)
* Allow for extraction of data in values or key names
* Ensure edge cases are handled correctly (especially empty data)

     
The first step in using tidyjson is to convert your JSON into a tbl_json 
object. Almost every function in tidyjson accepts either a tbl_jsonobject or
a character vector of JSON data as it's first parameter, and returns a 
tbl_json object for downstream use. To facilitate integration with dplyr,
tbl_json inherits from dplyr::tbl. The easiest way to construct a tbl_json
object is directly from a character string.

```r
filename <- "WNIT3rdRnd_WomensNIT_UNCvUCLA_12.out"
fname <- "WomensNIT noBOM.txt"
data <- read_json(fname, format = "jsonl")
class(data)
```

```
## [1] "tbl_json"   "tbl"        "data.frame"
```

Similar to gather_array(), gather_keys() takes JSON objects and duplicates 
the rows in the data.frame to correspond to the keys of the object, and puts
the values of the object into the JSON attribute.

```r
library(magrittr)
data1 <- gather_keys(data)
```

Identify JSON structure with json_types(). One of the first steps you will 
want to take is to investigate the structure of your JSON data. The function
json_types() inspects the JSON associated with each row of the data.frame, 
and adds a new column (type by default) that identifies the type according
to the JSON standard. 

```r
data2 <- json_types(data1)
```

The append_values_X() functions let you take the remaining JSON and add it 
as a column X (for X in "string", "number", "logical") insofar as it is of
the JSON type specified.

```r
data3 <- append_values_string(data2)
```

When investigating JSON data it can be helpful to identify the lengths of 
the JSON objects or arrays, especialy when they are 'ragged' across
documents.

```r
data4 <- json_lengths(data3)
```

Adding new columns to your data.frame is accomplished with spread_values(),
which lets you dive into (potentially nested) JSON objects and extract 
specific values. spread_values() takes jstring(), jnumber() or jlogical() 
function calls as arguments in order to specify the type of the data that 
should be captured at each desired key location. We are simply going to 
capture the tweets.

```r
twts <- data %>%
     spread_values(
          txt <- jstring("text")
     ) %>%
tbl_df
```

You can see that there are 255 lines in the file, each contained in a 
character vector. We can combine all of these character vectors into a 
single character vector using the paste() function, adding a space between
each of them.

```r
twt <- paste(twts[2], collapse = " ")
twt
```

```
## [1] "c(\"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \n\"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \"RT @jesse081990: #Michigan, #Villanova, #WestVirginia, #SouthernMiss, #Temple so far in the #Elite8 of the @WomensNIT\", \"Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story coming later tonight\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \n\"\\\"@umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/nurXv8m3On #goblue http://t.co/XvPlLU5CrQ\\\"\", \"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \n\"@MT_WBB will host @TUOWLS_WBB in the #WNIT Quarterfinals on Sunday, March 29 with tip slated for 5 p.m. ET / 4 p.m. CT.\", \"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \n\"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \n\"RT @jesse081990: #Michigan, #Villanova, #WestVirginia, #SouthernMiss, #Temple so far in the #Elite8 of the @WomensNIT\", \"Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story coming later tonight\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"\\\"@umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/nurXv8m3On #goblue http://t.co/XvPlLU5CrQ\\\"\", \n\"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"@MT_WBB will host @TUOWLS_WBB in the #WNIT Quarterfinals on Sunday, March 29 with tip slated for 5 p.m. ET / 4 p.m. CT.\", \n\"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \n\"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \"RT @jesse081990: #Michigan, #Villanova, #WestVirginia, #SouthernMiss, #Temple so far in the #Elite8 of the @WomensNIT\", \"Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story coming later tonight\", \n\"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"\\\"@umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/nurXv8m3On #goblue http://t.co/XvPlLU5CrQ\\\"\", \"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \n\"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"@MT_WBB will host @TUOWLS_WBB in the #WNIT Quarterfinals on Sunday, March 29 with tip slated for 5 p.m. ET / 4 p.m. CT.\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \n\"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \"RT @jesse081990: #Michigan, #Villanova, #WestVirginia, #SouthernMiss, #Temple so far in the #Elite8 of the @WomensNIT\", \n\"Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story coming later tonight\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"\\\"@umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/nurXv8m3On #goblue http://t.co/XvPlLU5CrQ\\\"\", \"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \n\"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \n\"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \"RT @jesse081990: #Michigan, #Villanova, #WestVirginia, #SouthernMiss, #Temple so far in the #Elite8 of the @WomensNIT\", \n\"Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story coming later tonight\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"\\\"@umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/nurXv8m3On #goblue http://t.co/XvPlLU5CrQ\\\"\", \"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \n\"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \n\"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \"RT @jesse081990: #Michigan, #Villanova, #WestVirginia, #SouthernMiss, #Temple so far in the #Elite8 of the @WomensNIT\", \"Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story coming later tonight\", \n\"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"\\\"@umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/nurXv8m3On #goblue http://t.co/XvPlLU5CrQ\\\"\", \"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \n\"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \n\"RT @jesse081990: #Michigan, #Villanova, #WestVirginia, #SouthernMiss, #Temple so far in the #Elite8 of the @WomensNIT\", \"Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story coming later tonight\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"\\\"@umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/nurXv8m3On #goblue http://t.co/XvPlLU5CrQ\\\"\", \n\"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \n\"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \"RT @jesse081990: #Michigan, #Villanova, #WestVirginia, #SouthernMiss, #Temple so far in the #Elite8 of the @WomensNIT\", \"Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story coming later tonight\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \n\"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \n\"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \"RT @jesse081990: #Michigan, #Villanova, #WestVirginia, #SouthernMiss, #Temple so far in the #Elite8 of the @WomensNIT\", \"Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story coming later tonight\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \n\"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \n\"RT @jesse081990: #Michigan, #Villanova, #WestVirginia, #SouthernMiss, #Temple so far in the #Elite8 of the @WomensNIT\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \n\"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \"Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @novawbasketball\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \n\"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @michaelniziolek: Great photos by @adougall of @umichwbball 65-55 win over Missouri in @WomensNIT Sweet 16 http://t.co/m2jII8PFdP story â<U+0080>¦\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \n\"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \"RT @WCChoops: WBB | At the top of the hour, @smcgaels takes on Sacramento State with the winner advancing to the @WomensNIT Elite Eight. #Wâ<U+0080>¦\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \n\"RT @WomensNIT: Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @â<U+0080>¦\", \"Waiting for #XAVvsAZ checking out @UCLAWBB v Northern Colorado in @WomensNIT Round of 16 on @Pac12Networks #BackThePac\", \"RT @WomensNIT: Game recaps &amp; scores from 1st 5 games tonight are posted &gt; http://t.co/kDbcxugGpr @umichwbball @MT_WBB @TUOWLS_WBB @WVUWBB @â<U+0080>¦\", \"Update: @TUOWLS_WBB takes on Middle Tennessee State in Quarterfinals of @WomensNIT on Sunday at 4PM at Middle Tennessee State #Temple #WNIT\", \n\"RT @CindyBrunsonAZ: Waiting for #XAVvsAZ checking out @UCLAWBB v Northern Colorado in @WomensNIT Round of 16 on @Pac12Networks #BackThePac\", \"Congratulations to @MT_WBB on advancing to the Elite 8 of the @WomensNIT. Keep up the the great work @CoachInsell @MTCoachKim #TrueFanAtUT\", \"Asked @novawbasketball Coach Harry Perretta after win over St John's in 3rd RD @WomensNIT \\nhttps://t.co/nPzJZzdiLi\\n#Villanova #StJohns #WNIT\", \"After the #OleMiss loss to #MTSU in the @WomensNIT The @SouthernMissWBB is the only team still playing hoops in #Mississippi! #Elite8\", \n\"RT @jesse081990: After the #OleMiss loss to #MTSU in the @WomensNIT The @SouthernMissWBB is the only team still playing hoops in #Mississipâ<U+0080>¦\", \"RT @USMGoldenEagles: #Operation5K set for Sunday as @SouthernMissWBB hosts Michigan in WNIT Quarterfinals! - http://t.co/xEmpIMVoWm http://â<U+0080>¦\", \"RT @MTAthletics: .@MT_WBB to host Temple at 4 PM Sunday. #BlueRaiders #WNIT http://t.co/L35zrQCuE3\", \"RT @jesse081990: After the #OleMiss loss to #MTSU in the @WomensNIT The @SouthernMissWBB is the only team still playing hoops in #Mississipâ<U+0080>¦\", \n\"Asked @novawbasketball Alex Louin after 63-55 win over St John's in @WomensNIT \\nhttps://t.co/ZrVAAZtd0p\\n#Villanova #StJohns #WNIT\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @jesse081990: After the #OleMiss loss to #MTSU in the @WomensNIT The @SouthernMissWBB is the only team still playing hoops in #Mississipâ<U+0080>¦\", \"Katherine Coyer scored 5 treys for Villanova. Now, it's a battle between the Wildcats and West Virginia in @WomensNIT Quarterfinals.\", \n\"RT @jesse081990: After the #OleMiss loss to #MTSU in the @WomensNIT The @SouthernMissWBB is the only team still playing hoops in #Mississipâ<U+0080>¦\", \"Katherine Coyer scored 5 treys for Villanova. Now, it's a battle between the Wildcats and West Virginia in @WomensNIT Quarterfinals.\", \"RT @jesse081990: After the #OleMiss loss to #MTSU in the @WomensNIT The @SouthernMissWBB is the only team still playing hoops in #Mississipâ<U+0080>¦\", \"Asked @novawbasketball Katherine Coyer after 63-55 win over St John's in @WomensNIT\\nhttps://t.co/NbocuTWhLv\\n#Villanova #StJohns #WNIT\", \n\"RT @jesse081990: After the #OleMiss loss to #MTSU in the @WomensNIT The @SouthernMissWBB is the only team still playing hoops in #Mississipâ<U+0080>¦\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"RT @NovaAthletics: Survive and advance! The Cats will face WVU in quarterfinal action of the @WomensNIT on Sunday! #NovaNation #NovaWBB httâ<U+0080>¦\", \"RT @jesse081990: After the #OleMiss loss to #MTSU in the @WomensNIT The @SouthernMissWBB is the only team still playing hoops in #Mississipâ<U+0080>¦\", \n\"RT @jesse081990: After the #OleMiss loss to #MTSU in the @WomensNIT The @SouthernMissWBB is the only team still playing hoops in #Mississipâ<U+0080>¦\", \"RT @jesse081990: After the #OleMiss loss to #MTSU in the @WomensNIT The @SouthernMissWBB is the only team still playing hoops in #Mississipâ<U+0080>¦\", \"RT @PackWomensBball: .@WomensNIT Third Round - Pack Edged 80-79 in OT at Temple: http://t.co/LIc7fLnL4i // #GoPack #WNIT http://t.co/2Ql4p3â<U+0080>¦\", \".@WomensNIT Third Round - Pack Edged 80-79 in OT at Temple: http://t.co/LIc7fLnL4i // #GoPack #WNIT http://t.co/2Ql4p3naIX\", \n\"RT @PackWomensBball: .@WomensNIT Third Round - Pack Edged 80-79 in OT at Temple: http://t.co/LIc7fLnL4i // #GoPack #WNIT http://t.co/2Ql4p3â<U+0080>¦\", \"Good Night from Villanova following @novawbasketball 63-55 win over St John's in @WomensNIT\\n#Villanova #StJohns #WNIT http://t.co/PG9thXlgEu\", \"Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \"RT @MTAthletics: Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \n\"RT @umichwbball: Get all the details on tonight's 65-55 @WomensNIT win over Missouri http://t.co/99QarR82qd #goblue http://t.co/TTcS6eXhyO\", \"RT @MTAthletics: Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \"Your @MT_WBB team scored a 82-70 win vs. Ole Miss 2night. Recap: http://t.co/UVZsEgeOBl @CoachInsell It's on to @WomensNIT quarterfinals\", \"RT @MTAthletics: Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \n\"Your @MT_WBB team scored a 82-70 win vs. Ole Miss 2night. Recap: http://t.co/UVZsEgeOBl @CoachInsell It's on to @WomensNIT quarterfinals\", \"RT @MT_WBB: Your @MT_WBB team scored a 82-70 win vs. Ole Miss 2night. Recap: http://t.co/UVZsEgeOBl @CoachInsell It's on to @WomensNIT quarâ<U+0080>¦\", \"RT @MTAthletics: Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \"RT @MT_WBB: Your @MT_WBB team scored a 82-70 win vs. Ole Miss 2night. Recap: http://t.co/UVZsEgeOBl @CoachInsell It's on to @WomensNIT quarâ<U+0080>¦\", \n\"RT @MT_WBB: Your @MT_WBB team scored a 82-70 win vs. Ole Miss 2night. Recap: http://t.co/UVZsEgeOBl @CoachInsell It's on to @WomensNIT quarâ<U+0080>¦\", \"RT @MTAthletics: Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \"RT @MT_WBB: Your @MT_WBB team scored a 82-70 win vs. Ole Miss 2night. Recap: http://t.co/UVZsEgeOBl @CoachInsell It's on to @WomensNIT quarâ<U+0080>¦\", \"RT @MT_WBB: Your @MT_WBB team scored a 82-70 win vs. Ole Miss 2night. Recap: http://t.co/UVZsEgeOBl @CoachInsell It's on to @WomensNIT quarâ<U+0080>¦\", \n\"Congrats to @CoachInsell &amp; @MT_WBB on their 82-70 win vs. Ole @OleMissWBB in the @WomensNIT tonight Story: http://t.co/gP91vmRusF\", \"RT @tstinnett3: Congrats to @CoachInsell &amp; @MT_WBB on their 82-70 win vs. Ole @OleMissWBB in the @WomensNIT tonight Story: http://t.co/gP91â<U+0080>¦\", \".@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @MurphyCenter\", \"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \n\"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \"THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.co/jgP8cceyke\", \"RT @PackWomensBball: .@WomensNIT Third Round - Pack Edged 80-79 in OT at Temple: http://t.co/LIc7fLnL4i // #GoPack #WNIT http://t.co/2Ql4p3â<U+0080>¦\", \n\"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \"THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.co/jgP8cceyke\", \"RT @PackWomensBball: .@WomensNIT Third Round - Pack Edged 80-79 in OT at Temple: http://t.co/LIc7fLnL4i // #GoPack #WNIT http://t.co/2Ql4p3â<U+0080>¦\", \n\"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \"THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.co/jgP8cceyke\", \"RT @PackWomensBball: .@WomensNIT Third Round - Pack Edged 80-79 in OT at Temple: http://t.co/LIc7fLnL4i // #GoPack #WNIT http://t.co/2Ql4p3â<U+0080>¦\", \"THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.co/jgP8cceyke\", \n\"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \n\"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \n\"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \n\"@CoachTomHodges @WomensNIT @MT_WBB I'm right behind that someone has not been in tune with southern miss attendance\", \"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"@CoachTomHodges @WomensNIT @MT_WBB I'm right behind that someone has not been in tune with southern miss attendance\", \n\"RT @tstinnett3: .@MT_WBB improved to 4-0 at home in the @WomensNIT under @CoachInsell Next up: Quarterfinals vs. Temple Sunday, 4 PM, @Murpâ<U+0080>¦\", \"@CoachTomHodges @WomensNIT @MT_WBB I'm right behind that someone has not been in tune with southern miss attendance\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \n\"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"RT @tstinnett3: Congrats to @CoachInsell &amp; @MT_WBB on their 82-70 win vs. Ole @OleMissWBB in the @WomensNIT tonight Story: http://t.co/gP91â<U+0080>¦\", \"RT @MTAthletics: Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \"#WVU RT \\\" THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown withâ<U+0080>¦ \\\" #SportsRoadhouse\", \n\"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"OTA! BlueRaiderDJ said: RT tstinnett3: .MT_WBB improved to 4-0 at home in the WomensNIT under CoachInsell Next up: Quarterfinals vs. Templeâ<U+0080>¦\", \"@MTAthletics @WomensNIT @MT_WBB I wonder what the refs were like...\", \"RT @umichwbball: Michigan is moving on in the @womensnit! U-M 65, Mizzou 55 FINAL #goblue http://t.co/S1urSAQTay\", \"@MTAthletics @WomensNIT @MT_WBB I wonder what the refs were like...\", \n\"@WomensNIT    Bwonder if the refs were any good. Better yet, did they call the game fairly?\", \"RT @tstinnett3: Congrats to @CoachInsell &amp; @MT_WBB on their 82-70 win vs. Ole @OleMissWBB in the @WomensNIT tonight Story: http://t.co/gP91â<U+0080>¦\", \"@WomensNIT    Bwonder if the refs were any good. Better yet, did they call the game fairly?\", \"@WomensNIT    Go Sac State!! Be prepared. You're playing against 8\", \"RT @MTAthletics: Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \n\"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"RT @WVUWBB: THANKS to all our fans that came out tonight! We need YOU this Sunday for a huge @WomensNIT showdown with Villanova. http://t.câ<U+0080>¦\", \"RT @PackWomensBball: .@WomensNIT Third Round - Pack Edged 80-79 in OT at Temple: http://t.co/LIc7fLnL4i // #GoPack #WNIT http://t.co/2Ql4p3â<U+0080>¦\", \"RT @MTAthletics: Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \n\"RT @MTAthletics: Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \"RT @MTAthletics: Father got the best of son as @MT_WBB turned back @OleMissWBB in the @WomensNIT Story: http://t.co/CwidIvSriw\", \"Brava @UCLAWBB! Beat Northern Colorado &amp; now in @WomensNIT rd of 8 led by @loveandbball24 season high tying 26 pts! #Pac12Hoops #BackThePac\", \"FINAL: @UCLAWBB moves on to the #WNIT Quarterfinals after a 74-60 win over @UNCBearsWBB.\", \"FINAL: @GaelsWBB advances to the #WNIT Quarterfinals with a 77-69 road win over @SacStateWbb.\", \n\"@UCLAWBB will host @GaelsWBB in the #WNIT Quarterfinals on Sunday, March 29 at 5 p.m. ET / 2 p.m. PT.\", \"RT @CindyBrunsonAZ: Brava @UCLAWBB! Beat Northern Colorado &amp; now in @WomensNIT rd of 8 led by @loveandbball24 season high tying 26 pts! #Paâ<U+0080>¦\")"
```

For many kinds of text processing it is sufficient, even preferable to use 
base R classes. But for NLP we are obligated to use the String class. 

```r
library(NLP)
library(openNLP)
twtg <- as.String(twt)
```

Next we need to create annotators for words and sentences. Annotators are
created by functions which load the underlying Java libraries. These 
functions then mark the places in the string where words and sentences start
and end. The annotation functions are themselves created by functions.

```r
word_ann <- Maxent_Word_Token_Annotator()
sent_ann <- Maxent_Sent_Token_Annotator()
```

These annotators form a "pipeline" for annotating the text in our twtg 
variable. First we have to determine where the sentences are, then we can
determine where the words are. We can apply these annotator functions to our
data using the annotate() function.

```r
bio_annotations <- annotate(twtg, list(sent_ann, word_ann))
```

The result is a annotation object. Looking at first few items contained in 
the object, we can see the kind of information contained in the annotations 
object.

```r
class(bio_annotations)
```

```
## [1] "Annotation" "Span"
```

```r
head(bio_annotations)
```

```
##  id type     start end features
##   1 sentence     1 282 constituents=<<integer,53>>
##   2 sentence   284 349 constituents=<<integer,15>>
##   3 sentence   351 406 constituents=<<integer,10>>
##   4 sentence   408 540 constituents=<<integer,19>>
##   5 sentence   542 643 constituents=<<integer,20>>
##   6 sentence   645 937 constituents=<<integer,50>>
```

We see that the annotation object contains a list of sentences (and also 
words) identified by position. That is, the first sentence in the document 
begins at character 1 and ends at character 282. The sentences also contain
information about the positions of the words that comprise them. We can 
combine the tweets and the annotations to create what the NLP package calls
an AnnotatedPlainTextDocument. If we wished we could also associate metadata
with the object using the meta = argument.

```r
bio_doc <- AnnotatedPlainTextDocument(twtg, bio_annotations)
```
     
Now we can extract information from our document using accessor functions
like sents() to get the sentences and words() to get the words. We could get just the plain text with as.character(bio_doc).

```r
sents(bio_doc) %>% head(2)
```

```
## [[1]]
##  [1] "c("            "\"Update"      ":"             "@TUOWLS_WBB"  
##  [5] "takes"         "on"            "Middle"        "Tennessee"    
##  [9] "State"         "in"            "Quarterfinals" "of"           
## [13] "@WomensNIT"    "on"            "Sunday"        "at"           
## [17] "4PM"           "at"            "Middle"        "Tennessee"    
## [21] "State"         "#"             "Temple"        "#"            
## [25] "WNIT\""        ","             "\"RT"          "@WCChoops"    
## [29] ":"             "WBB"           "|"             "At"           
## [33] "the"           "top"           "of"            "the"          
## [37] "hour"          ","             "@smcgaels"     "takes"        
## [41] "on"            "Sacramento"    "State"         "with"         
## [45] "the"           "winner"        "advancing"     "to"           
## [49] "the"           "@WomensNIT"    "Elite"         "Eight"        
## [53] "."            
## 
## [[2]]
##  [1] "#"            "Wâ<U+0080>"          "¦\""          ","           
##  [5] "\"RT"         "@umichwbball" ":"            "Michigan"    
##  [9] "is"           "moving"       "on"           "in"          
## [13] "the"          "@womensnit"   "!"
```

```r
words(bio_doc) %>% head(10)
```

```
##  [1] "c("          "\"Update"    ":"           "@TUOWLS_WBB" "takes"      
##  [6] "on"          "Middle"      "Tennessee"   "State"       "in"
```
     
Among the several kinds of annotators provided by the openNLP package is an
entity annotator. An entity is basically a proper noun, such as a person or
place name. Using a technique called named entity recognition (NER), we can
extract various kinds of names from a document. In English, OpenNLP can find
dates, locations, money, organizations, percentages, people, and times. 
(Acceptable values are "date", "location", "money", "organization", 
"percentage", "person", "misc".) We will use it to find people, places, and
organizations since all three are mentioned in our sample paragraph. These
kinds of annotator functions are created using the same kinds of constructor
functions that we used for word_ann() and sent_ann().

```r
person_ann <- Maxent_Entity_Annotator(kind = "person")
location_ann <- Maxent_Entity_Annotator(kind = "location")
organization_ann <- Maxent_Entity_Annotator(kind = "organization")
date_ann <- Maxent_Entity_Annotator(kind = "date")
money_ann <- Maxent_Entity_Annotator(kind = "money")
percentage_ann <- Maxent_Entity_Annotator(kind = "percentage")
```
     
Recall that we earlier passed a list of annotator functions to the
annotate() function to indicate which kinds of annotations we wanted to
make. We will create a new pipeline list to hold our annotators in the order
we want to apply them, then apply it to the twtg variable. Then, as before, 
we can create an AnnotatedPlainTextDocument.

```r
pipeline <- list(sent_ann,
                 word_ann,
                 person_ann,
                 location_ann,
                 organization_ann,
                 date_ann,
                 money_ann,
                 percentage_ann)
bio_annotations <- annotate(twtg, pipeline)
bio_doc <- AnnotatedPlainTextDocument(twtg, bio_annotations)
```
     
As before we could extract words and sentences using the getter methods
words() and sents(). Unfortunately there is no comparably easy way to
extract names entities from documents. But the function below will do the 
trick.
     
Extract entities from an AnnotatedPlainTextDocument

```r
entities <- function(doc, kind) {
     s <- doc$content
     a <- annotations(doc)[[1]]
     if(hasArg(kind)) {
          k <- sapply(a$features, `[[`, "kind")
          s[a[k == kind]]
     } else {
          s[a[a$type == "entity"]]
     }
}
```
     
Now we can extract all of the named entities using entities(bio_doc), and 
specific kinds of entities using the kind = argument. Let's get all the 
people, places, organizations, dates, money, and percentages.

```r
entities(bio_doc, kind = "person")
```

```
##  [1] "WNIT\""          "WNIT\""          "WNIT\""         
##  [4] "WNIT\""          "WNIT\""          "WNIT\""         
##  [7] "WNIT\""          "WNIT\""          "WNIT\""         
## [10] "WNIT\""          "WNIT\""          "WNIT\""         
## [13] "WNIT\""          "WNIT\""          "WNIT\""         
## [16] "WNIT\""          "Coach"           "Harry Perretta" 
## [19] "Alex Louin"      "Katherine Coyer" "Katherine Coyer"
## [22] "Katherine Coyer" "Ole Miss"        "Ole Miss"       
## [25] "Ole Miss"        "Ole Miss"        "Ole Miss"       
## [28] "Ole Miss"        "Ole Miss"
```

```r
entities(bio_doc, kind = "location")
```

```
##   [1] "Middle Tennessee State" "Middle Tennessee State"
##   [3] "Temple"                 "Sacramento State"      
##   [5] "Michigan"               "Missouri"              
##   [7] "Michigan"               "Temple"                
##   [9] "Missouri"               "Michigan"              
##  [11] "Missouri"               "://t.co/XvPlLU5CrQ"    
##  [13] "Missouri"               "Missouri"              
##  [15] "Michigan"               "Missouri"              
##  [17] "Missouri"               "Middle Tennessee State"
##  [19] "Middle Tennessee State" "Temple"                
##  [21] "Sacramento State"       "Michigan"              
##  [23] "Missouri"               "Michigan"              
##  [25] "Temple"                 "Missouri"              
##  [27] "Michigan"               "Missouri"              
##  [29] "://t.co/XvPlLU5CrQ"     "Missouri"              
##  [31] "Missouri"               "Michigan"              
##  [33] "Missouri"               "Middle Tennessee State"
##  [35] "Middle Tennessee State" "Temple"                
##  [37] "Sacramento State"       "Michigan"              
##  [39] "Missouri"               "Michigan"              
##  [41] "Temple"                 "Missouri"              
##  [43] "Michigan"               "Missouri"              
##  [45] "://t.co/XvPlLU5CrQ"     "Missouri"              
##  [47] "Missouri"               "Michigan"              
##  [49] "Middle Tennessee State" "Middle Tennessee State"
##  [51] "Temple"                 "Sacramento State"      
##  [53] "Michigan"               "Missouri"              
##  [55] "Michigan"               "Temple"                
##  [57] "Missouri"               "Michigan"              
##  [59] "Missouri"               "://t.co/XvPlLU5CrQ"    
##  [61] "Missouri"               "Missouri"              
##  [63] "Michigan"               "Middle Tennessee State"
##  [65] "Middle Tennessee State" "Temple"                
##  [67] "Sacramento State"       "Michigan"              
##  [69] "Missouri"               "Michigan"              
##  [71] "Temple"                 "Missouri"              
##  [73] "Michigan"               "Missouri"              
##  [75] "://t.co/XvPlLU5CrQ"     "Missouri"              
##  [77] "Missouri"               "Middle Tennessee State"
##  [79] "Middle Tennessee State" "Temple"                
##  [81] "Sacramento State"       "Michigan"              
##  [83] "Missouri"               "Michigan"              
##  [85] "Temple"                 "Missouri"              
##  [87] "Michigan"               "Missouri"              
##  [89] "://t.co/XvPlLU5CrQ"     "Missouri"              
##  [91] "Middle Tennessee State" "Middle Tennessee State"
##  [93] "Temple"                 "Sacramento State"      
##  [95] "Michigan"               "Missouri"              
##  [97] "Michigan"               "Temple"                
##  [99] "Missouri"               "Michigan"              
## [101] "Missouri"               "://t.co/XvPlLU5CrQ"    
## [103] "Middle Tennessee State" "Middle Tennessee State"
## [105] "Temple"                 "Sacramento State"      
## [107] "Michigan"               "Missouri"              
## [109] "Michigan"               "Temple"                
## [111] "Missouri"               "Michigan"              
## [113] "Middle Tennessee State" "Middle Tennessee State"
## [115] "Temple"                 "Sacramento State"      
## [117] "Michigan"               "Missouri"              
## [119] "Michigan"               "Temple"                
## [121] "Missouri"               "Middle Tennessee State"
## [123] "Middle Tennessee State" "Temple"                
## [125] "Sacramento State"       "Michigan"              
## [127] "Missouri"               "Michigan"              
## [129] "Temple"                 "Middle Tennessee State"
## [131] "Middle Tennessee State" "Temple"                
## [133] "Sacramento State"       "Michigan"              
## [135] "Missouri"               "Middle Tennessee State"
## [137] "Middle Tennessee State" "Temple"                
## [139] "Sacramento State"       "Michigan"              
## [141] "Missouri"               "Middle Tennessee State"
## [143] "Middle Tennessee State" "Temple"                
## [145] "Sacramento State"       "Michigan"              
## [147] "Middle Tennessee State" "Middle Tennessee State"
## [149] "Temple"                 "Sacramento State"      
## [151] "Middle Tennessee State" "Middle Tennessee State"
## [153] "Temple"                 "Middle Tennessee State"
## [155] "Middle Tennessee State" "Temple"                
## [157] "St John"                "Mississippi"           
## [159] "Michigan"               "Temple"                
## [161] "St John"                "Michigan"              
## [163] "West Virginia"          "West Virginia"         
## [165] "St John"                "Michigan"              
## [167] "Temple"                 "Temple"                
## [169] "Temple"                 "St John"               
## [171] "Missouri"               "Temple Sunday"         
## [173] "Temple Sunday"          "Temple Sunday"         
## [175] "Temple Sunday"          "Temple"                
## [177] "Temple Sunday"          "Temple Sunday"         
## [179] "Temple"                 "Temple Sunday"         
## [181] "Temple"                 "Temple Sunday"         
## [183] "Temple Sunday"          "Temple Sunday"         
## [185] "Temple Sunday"          "Temple Sunday"         
## [187] "Michigan"               "Temple"
```

```r
entities(bio_doc, kind = "organization")
```

```
##  [1] "FINAL"     "Villanova" "FINAL"     "FINAL"     "FINAL"    
##  [6] "Villanova" "FINAL"     "FINAL"     "FINAL"     "Villanova"
## [11] "FINAL"     "FINAL"     "FINAL"     "Villanova" "FINAL"    
## [16] "FINAL"     "FINAL"     "Villanova" "FINAL"     "FINAL"    
## [21] "Villanova" "FINAL"     "FINAL"     "Villanova" "FINAL"    
## [26] "FINAL"     "Villanova" "FINAL"     "FINAL"     "Villanova"
## [31] "FINAL"     "Villanova" "FINAL"     "FINAL"     "FINAL"    
## [36] "RD"        "Villanova" "Villanova" "FINAL"     "Villanova"
## [41] "Villanova" "Villanova" "FINAL"     "WVU"       "Villanova"
## [46] "Villanova" "Villanova" "Villanova" "Villanova" "Villanova"
## [51] "Villanova" "Villanova" "Villanova" "Villanova" "Villanova"
## [56] "Villanova" "Villanova" "Villanova" "Villanova" "Villanova"
## [61] "Villanova" "Villanova" "Villanova" "Villanova" "FINAL"    
## [66] "Villanova" "Villanova"
```

```r
entities(bio_doc, kind = "date")
```

```
##   [1] "Sunday"             "://t.co/99QarR82qd" "://t.co/99QarR82qd"
##   [4] "Sunday, March 29"   "://t.co/99QarR82qd" "://t.co/99QarR82qd"
##   [7] "Sunday"             "://t.co/99QarR82qd" "://t.co/99QarR82qd"
##  [10] "Sunday, March 29"   "://t.co/99QarR82qd" "Sunday"            
##  [13] "://t.co/99QarR82qd" "://t.co/99QarR82qd" "Sunday, March 29"  
##  [16] "Sunday"             "://t.co/99QarR82qd" "://t.co/99QarR82qd"
##  [19] "Sunday"             "://t.co/99QarR82qd" "://t.co/99QarR82qd"
##  [22] "Sunday"             "://t.co/99QarR82qd" "Sunday"            
##  [25] "Sunday"             "Sunday"             "Sunday"            
##  [28] "Sunday"             "Sunday"             "Sunday"            
##  [31] "Sunday"             "Sunday"             "Sunday"            
##  [34] "Sunday"             "Sunday"             "63-55"             
##  [37] "63-55"              "Sunday"             "80-79"             
##  [40] "80-79"              "80-79"              "63-55"             
##  [43] "://t.co/99QarR82qd" "82-70"              "82-70"             
##  [46] "82-70"              "82-70"              "82-70"             
##  [49] "82-70"              "82-70"              "82-70"             
##  [52] "82-70"              "Next"               "Sunday"            
##  [55] "Next"               "Sunday"             "Next"              
##  [58] "Sunday"             "Next"               "Sunday"            
##  [61] "Sunday"             "80-79"              "Next"              
##  [64] "Sunday"             "Next"               "Sunday"            
##  [67] "Sunday"             "80-79"              "Next"              
##  [70] "Sunday"             "Sunday"             "80-79"             
##  [73] "Sunday"             "Next"               "Sunday"            
##  [76] "Sunday"             "Sunday"             "Sunday"            
##  [79] "Sunday"             "Next"               "Sunday"            
##  [82] "Sunday"             "Sunday"             "Sunday"            
##  [85] "Next"               "Sunday"             "Sunday"            
##  [88] "Sunday"             "Next"               "Sunday"            
##  [91] "Sunday"             "Next"               "Sunday"            
##  [94] "Sunday"             "Sunday"             "Sunday"            
##  [97] "82-70"              "Sunday"             "Sunday"            
## [100] "82-70"              "Sunday"             "Sunday"            
## [103] "80-79"              "74-60"              "77-69"             
## [106] "Sunday, March 29"
```

```r
entities(bio_doc, kind = "money")
```

```
## character(0)
```

```r
entities(bio_doc, kind = "percentage")
```

```
## character(0)
```

Reference: https://cran.r-project.org/web/packages/tidyjson/vignettes/introduction-to-tidyjson.html
Reference: https://rpubs.com/lmullen/nlp-chapter     
     
     
     
