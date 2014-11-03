---
title: 'Examining Data With Base R'
date: '2014-11-02'
author: LCHansson
layout: post
tags: [R, analytics, basics]
comments: yes
lang: en
---

This is the first in a series of posts about using basic tools for data analysis in R. I've put it together as much for my own pleasure as for anyone else to read. If you read this and like it, don't hesitate to give me a thumbs up in the comments below!


<section id="table-of-contents" class="toc">
  <header>
    <h3>Overview</h3>
  </header>
<div id="drawer" markdown="1">
*  Auto generated table of contents
{:toc}
</div>
</section><!-- /#table-of-contents -->


Usually, any analyst will want to start her endeavour by diving into data. When I first started learning my way around R I used to believe that the best way of looking at data is by passing it to `View()` or something similar, to be able to inspect data the Excel way. After all, this is how many analysts usually look at data using software like SPSS, SAS, or most other commercial "statistical packages" out there.

However, I quickly came to realise that this method is often highly subpar when it comes to gaining any deeper insights into data, and might sometimes even give you a false picture of what data _actually_ looks like. Instead I have found that there are a multitude of ways of describing data that presents a more accurate view of the data at hand, and quickly presents you with a couple of crucial pieces of metadata.

In the sections below I describe four common techniques used for examining data; _Inspection_, _Summarization_, _Aggregation_, and _Handling of missing values_.


## Inspection

The first commands any analyst will want to learn are used for simply _inspecting_ data, i.e. just looking at it without any preprocessing. Here, I have found `str()` and `head()/tail()` particularly good. Below you'll see them used on three built-in R datasets.


{% highlight r %}
str(iris)
{% endhighlight %}



{% highlight text %}
> 'data.frame':	150 obs. of  5 variables:
>  $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
>  $ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
>  $ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
>  $ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
>  $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
{% endhighlight %}


{% highlight r %}
head(airquality)
{% endhighlight %}



{% highlight text %}
>   Ozone Solar.R Wind Temp Month Day
> 1    41     190  7.4   67     5   1
> 2    36     118  8.0   72     5   2
> 3    12     149 12.6   74     5   3
> 4    18     313 11.5   62     5   4
> 5    NA      NA 14.3   56     5   5
> 6    28      NA 14.9   66     5   6
{% endhighlight %}


{% highlight r %}
tail(cars, n = 3)
{% endhighlight %}



{% highlight text %}
>    speed dist
> 48    24   93
> 49    24  120
> 50    25   85
{% endhighlight %}

*To summarize:* `str()` and `head()/tail()` are useful commands for simply displaying parts of your data and some metadata about it.


## Summarization

The step following inspection usually consists of carrying out some kind of summarization of variables contained within your data. As you might already have guessed, the `summary()` command is usually an excellent starting point for this kind of examination. It can be used to describe vectors...


{% highlight r %}
summary(letters) # This is a character() vector
{% endhighlight %}



{% highlight text %}
>    Length     Class      Mode 
>        26 character character
{% endhighlight %}

...of different kinds...

{% highlight r %}
summary(iris$Species) # a factor() vector
{% endhighlight %}



{% highlight text %}
>     setosa versicolor  virginica 
>         50         50         50
{% endhighlight %}

...displaying information relevant to the data at hand.

{% highlight r %}
summary(iris$Sepal.Length) # a numeric() vector
{% endhighlight %}



{% highlight text %}
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
>   4.300   5.100   5.800   5.843   6.400   7.900
{% endhighlight %}

`summary()` can, of course, also be used to describe tabular data. Note that the first four columns of the `iris` dataset are all of the `numeric()` type whereas the last column, Species, is a `factor()`. `summary()` adjusts its output accordingly.

{% highlight r %}
summary(iris)
{% endhighlight %}



{% highlight text %}
>   Sepal.Length    Sepal.Width     Petal.Length    Petal.Width   
>  Min.   :4.300   Min.   :2.000   Min.   :1.000   Min.   :0.100  
>  1st Qu.:5.100   1st Qu.:2.800   1st Qu.:1.600   1st Qu.:0.300  
>  Median :5.800   Median :3.000   Median :4.350   Median :1.300  
>  Mean   :5.843   Mean   :3.057   Mean   :3.758   Mean   :1.199  
>  3rd Qu.:6.400   3rd Qu.:3.300   3rd Qu.:5.100   3rd Qu.:1.800  
>  Max.   :7.900   Max.   :4.400   Max.   :6.900   Max.   :2.500  
>        Species  
>  setosa    :50  
>  versicolor:50  
>  virginica :50  
>                 
>                 
> 
{% endhighlight %}

*To summarize (pun intended):* `summary()` is useful for describing your data in an automated way, providing you with more metadata than pure inspection will generate.


## Aggregation

Many insights can be gained from aggregation of data. Especially when dealing with data that comprises both categorical variables (a.k.a. background variables) and measurement variables (i.e. outcomes) the analyst can often learn much from aggregating data in different fashions. Unsurprisingly, `aggregate()` is the function you'll need most of the time. It makes extensive use of R's `formula()` interface (activated by the `~` operator). This is a slightly more complex way of looking at data, but can be a very efficient tool to gain more advanced insights, e.g. about any significant within-data differences or which variables are potential predictors and which might be outcomes.


{% highlight r %}
aggregate(. ~ Species, data = iris, FUN = mean)
{% endhighlight %}



{% highlight text %}
>      Species Sepal.Length Sepal.Width Petal.Length Petal.Width
> 1     setosa        5.006       3.428        1.462       0.246
> 2 versicolor        5.936       2.770        4.260       1.326
> 3  virginica        6.588       2.974        5.552       2.026
{% endhighlight %}

Here we see the result of aggregating the `iris` dataset and taking the mean value for all values in each column, and each species (there are three species of iris flowers recorded in the dataset).

`aggregate()` takes a FUN argument which is the function applied to the aggregated groups.

{% highlight r %}
# Calculate the sum of all values within each group
aggregate(. ~ Species, data = iris, FUN = sum)
{% endhighlight %}



{% highlight text %}
>      Species Sepal.Length Sepal.Width Petal.Length Petal.Width
> 1     setosa        250.3       171.4         73.1        12.3
> 2 versicolor        296.8       138.5        213.0        66.3
> 3  virginica        329.4       148.7        277.6       101.3
{% endhighlight %}

FUN can be any function, even a user defined one.

{% highlight r %}
# Create a user-defined function to determine the Coefficient of Variation
coeff_of_var <- function(x) { sd(x) / mean(x) }
aggregate(. ~ Species, data = iris, FUN = coeff_of_var)
{% endhighlight %}



{% highlight text %}
>      Species Sepal.Length Sepal.Width Petal.Length Petal.Width
> 1     setosa   0.07041344   0.1105789   0.11878522   0.4283967
> 2 versicolor   0.08695606   0.1132846   0.11030774   0.1491348
> 3  virginica   0.09652089   0.1084387   0.09940466   0.1355627
{% endhighlight %}

Another useful tool is the `table()` function which is used to create frequency tables, and its nephew `prop.table()`, used to create relative frequency tables. The most basic usage is to use it to tabulate frequencies in vectors:


{% highlight r %}
table(Nile)
{% endhighlight %}



{% highlight text %}
> Nile
>  456  649  676  692  694  698  701  702  714  718  726  740  742  744  746 
>    1    1    1    1    1    1    1    1    1    1    1    1    1    2    1 
>  749  759  764  768  771  774  781  796  797  799  801  812  813  815  821 
>    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1 
>  822  824  831  832  833  838  840  845  846  848  860  862  864  865  874 
>    1    1    1    1    1    1    1    3    1    1    1    1    1    1    2 
>  890  897  901  906  912  916  918  919  923  935  940  944  958  960  963 
>    1    1    1    1    1    1    1    1    1    1    1    1    1    1    1 
>  969  975  984  986  994  995 1010 1020 1030 1040 1050 1100 1110 1120 1140 
>    1    1    1    1    1    1    1    3    1    2    2    3    1    2    2 
> 1150 1160 1170 1180 1210 1220 1230 1250 1260 1370 
>    1    3    1    1    2    1    1    1    1    1
{% endhighlight %}

However, there are more useful ways of putting `table()` to work, since it can be applied to any kind of tabular data. However be warned: **DO NOT** pass an entire data frame containing many variables and/or rows to `table()` since this will cause it to tabulate all possible combinations of variables in the data set. If you really want to try doing this to obtain a better understanding of how `table()` works, make sure to try it on a _really_ small dataset, like `table(cars)` (`cars` has the dimensions 2x50).


{% highlight r %}
table(iris[,c("Species", "Petal.Width")])
{% endhighlight %}



{% highlight text %}
>             Petal.Width
> Species      0.1 0.2 0.3 0.4 0.5 0.6  1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8
>   setosa       5  29   7   7   1   1  0   0   0   0   0   0   0   0   0
>   versicolor   0   0   0   0   0   0  7   3   5  13   7  10   3   1   1
>   virginica    0   0   0   0   0   0  0   0   0   0   1   2   1   1  11
>             Petal.Width
> Species      1.9  2 2.1 2.2 2.3 2.4 2.5
>   setosa       0  0   0   0   0   0   0
>   versicolor   0  0   0   0   0   0   0
>   virginica    5  6   6   3   8   3   3
{% endhighlight %}

`table()` can also be combined with the `with()` function to create local measurement variables and categories.

{% highlight r %}
with(iris, table(Species, Large.Petals = Petal.Width > 1.5))
{% endhighlight %}



{% highlight text %}
>             Large.Petals
> Species      FALSE TRUE
>   setosa        50    0
>   versicolor    45    5
>   virginica      3   47
{% endhighlight %}

`table()` returns a table object that can be used as input in other functions, like `prop.table()` to return a list of proportions.

{% highlight r %}
myTable <- with(iris, table(Species, Large.Petals = Petal.Width > 1.5))
prop.table(myTable)
{% endhighlight %}



{% highlight text %}
>             Large.Petals
> Species           FALSE       TRUE
>   setosa     0.33333333 0.00000000
>   versicolor 0.30000000 0.03333333
>   virginica  0.02000000 0.31333333
{% endhighlight %}

If we want frequencies to sum up only row or column wise, we can pass a 1 (for rows) or 2 (columns) as an additional argument to prop.table()

{% highlight r %}
prop.table(myTable, 1) # Rowwise relative frequencies
{% endhighlight %}



{% highlight text %}
>             Large.Petals
> Species      FALSE TRUE
>   setosa      1.00 0.00
>   versicolor  0.90 0.10
>   virginica   0.06 0.94
{% endhighlight %}



{% highlight r %}
prop.table(myTable, 2) # Column-wise relative frequencies
{% endhighlight %}



{% highlight text %}
>             Large.Petals
> Species           FALSE       TRUE
>   setosa     0.51020408 0.00000000
>   versicolor 0.45918367 0.09615385
>   virginica  0.03061224 0.90384615
{% endhighlight %}

*To summarize:* `aggregate()` and `table()` are methods used for categorizing data and understanding what values are more common and which are rare. `prop.table()` helps you put the output from `table()` in perspective. `with()` can be used to make`table()` compute new variables when creating frequency tables.


## Handling missing values

Sometimes (well actually, most of the time when working with _real-world data_) data will have missing values in it. In R this is usually represented by the `NA` value. This is problematic, e.g. since many base functions like `sum()` will return `NA` if there is a single `NA` among the input values.

To find out whether there are any missing values in a vector (or column, if you will) we turn to the `summary()` function yet again:


{% highlight r %}
summary(airquality$Solar.R)
{% endhighlight %}



{% highlight text %}
>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
>     7.0   115.8   205.0   185.9   258.8   334.0       7
{% endhighlight %}

So the column `Solar.R` in the `airquality` dataset contains 7 NA values. We can locate the positions of NA values using `is.na()` and then passing the output to `which()`...

{% highlight r %}
which(is.na(airquality$Solar.R))
{% endhighlight %}



{% highlight text %}
> [1]  5  6 11 27 96 97 98
{% endhighlight %}

...which returns a vector of positions within the vector. These are the row numbers in the `airquality` dataset that have NAs in them. We can now print these rows to learn what other data these rows contain:

{% highlight r %}
airquality[which(is.na(airquality$Solar.R)),]
{% endhighlight %}



{% highlight text %}
>    Ozone Solar.R Wind Temp Month Day
> 5     NA      NA 14.3   56     5   5
> 6     28      NA 14.9   66     5   6
> 11     7      NA  6.9   74     5  11
> 27    NA      NA  8.0   57     5  27
> 96    78      NA  6.9   86     8   4
> 97    35      NA  7.4   85     8   5
> 98    66      NA  4.6   87     8   6
{% endhighlight %}

Missing values can be handled in several ways. We can remove them from a vector...

{% highlight r %}
myVec <- airquality$Solar.R
length(myVec) # The length before removal of NA values
{% endhighlight %}



{% highlight text %}
> [1] 153
{% endhighlight %}



{% highlight r %}
myVec <- myVec[!is.na(myVec)]
length(myVec) # The post-removal length
{% endhighlight %}



{% highlight text %}
> [1] 146
{% endhighlight %}

...or from a data frame...

{% highlight r %}
myDF <- airquality
dim(myDF) # Dimensions of the data.frame() before removal of rows containing NA values
{% endhighlight %}



{% highlight text %}
> [1] 153   6
{% endhighlight %}



{% highlight r %}
myDF <- myDF[!is.na(airquality$Solar.R),]
dim(myDF) # Post-removal dimensions. Note that there are now fewer rows.
{% endhighlight %}



{% highlight text %}
> [1] 146   6
{% endhighlight %}

More importantly, we can also impute missing values using `impute()` from the `Hmisc` package.

{% highlight r %}
myDF <- airquality
suppressMessages(require(Hmisc))
myDF$Solar.R <- impute(myDF$Solar.R, fun = median)
{% endhighlight %}

*To summarize:* `is.na()` and `which()` are useful commands for locating missing values and displaying them in some context (using tabular data). `impute()` can be used to impute values in place of the missing values if needed.


## Moving on

This article introduces a subset of the tools I find myself using recurrently for data examination. The last thing you saw in the article was how to _impute_ missing values, which is actually not about _learning_ about data but _modifying_ it, in this case using a technique often referred to as Feature Engineering. This will be the topic of future posts.

Seasoned R programmers might also object that many staple R packages, like `Hmisc`, `psych`, `dplyr`, `data.table`, `stats`, and many others have functions for data inspection that are vastly superior to base-R functionality. I tend to agree on this, but I thought it'd be nice to provide R beginners (as well as myself) with a basic set of tools that one can easily learn without having to familiarize yourself with the API of any particular package (as anyone familiar with both the dplyr and data.table packages will tell you, the differences in how data is handled can vary substantially between packages!). Also, I constantly find myself returning to the base-R functions for the occasions when there is a particular task that my favorite dplyr or Hmisc function doesn't handle as well as it should.

All the source code on display here can be found in a separate Github repository here: [LCHansson/rTutorials](https://github.com/LCHansson/rTutorials). If you think anything in the code should be improved, please consider making a pull request to that repository and I will update this page accordingly.

I hope this has been of some help to you if you made it this far into the article. Any feedback is more than welcome!
