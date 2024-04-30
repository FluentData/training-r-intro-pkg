# Quality Assurance and Common Pitfalls 

Quality assurance (QA) in R could refer to at least two things: the quality of the code, or the quality of the data. Advanced R users that develop their own functions should follow general best practices for software development. The package [testthat](https://testthat.r-lib.org/) is useful to ensure that functions are working the way they are intended to work. However, this lesson focuses on _data_ quality, and points out a few common mistakes when using R.
 

- [Prerequisites](#prerequisites)

- [Data Quality Assurance](#data-quality-assurance)
  - [Data Types](#data-types)

  - [Unallowed Data](#unallowed-data)

  - [Outliers](#outliers)

- [Common Mistakes](#common-mistakes)

## Prerequisites

This lesson assumes you are familiar with the material in the lesson on [Functions and Importing Data](../2-Functions-and-Importing-Data/readme.md).

The data used throughout these lessons is provided by this package. To access the data, simply use the `data()` function with the name of the dataset provided by this package.


```{r ex-D9BqC-1, eval = TRUE, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Load Example Data Frame'}
# Assuming this package is already loaded into your R session
data("example_dataset")

```

## Data Quality Assurance

## Data Types

Data types are the first thing to consider when using data in R. Many errors can happen if we assume that our data is a certain type, when in reality it is not. After reading data into R, we should look at the data types in RStudio or using the function `str()`.


```{r ex-ymVyW-1, eval = TRUE, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Inspect Example Dataset Data Types'}
str(example_dataset)

```

Here is an example of text that is read into R, and a certain column might be `character` when we expected it to be `Date`.


```{r ex-9bKiT-2, eval = TRUE, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Check Data Types'}
sample_data <- read.csv(text = "
date,value
2022-08-01,100
2022-08-02,110
")

str(sample_data)

```

We can use the `as.Date()` function to transform the column after reading the data, or we can use the `colClasses` argument in the `read.csv` function to ensure it's read correctly.


```{r ex-dNzFU-3, eval = TRUE, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Correcting Data Types with colClasses'}
sample_data <- read.csv(colClasses = c("Date", "numeric"), text = "
date,value
2022-08-01,100
2022-08-02,110
")

str(sample_data)

```

## Unallowed Data

For both character and numeric data types, there may be values that should not be allowed.


```{r ex-Oq8fw-1, eval = TRUE, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Identify and Correct Unallowed Data'}
# Example of correcting unallowed values
values <- c(1, 2, -1, 3, -2, 4)
values[values < 0] <- NA

values

```

## Outliers

Handling outliers is difficult because we do not necessarily want
to remove data that may be uncommon but within the realm of possibility.
The best way to detect extreme values is to look at the summary of
your data and pay attention to min and max values. You can plot the
data to see if you can detect anything weird through visual inspection.
Boxplots with outliers plotted as points are handy for this. Below
is a boxplot of the ozone column in the `chicago_air` data frame.


```{r ex-xH78T-1, eval = TRUE, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Identify and Handle Outliers'}
boxplot(chicago_air$ozone)

```

We can see that two values are printed as points on the high end of the distribution.
We can use the `boxplot.stats()` function to get the values used in the `boxplot()`
function. The `out` values are the outliers.


```{r ex-3nU4U-2, eval = TRUE, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Return Outlier Values from Boxplot'}
boxplot.stats(chicago_air$ozone)$out

```

## Common Mistakes

If you run a command and get an error, then R should print an error message. Common syntax mistakes include missing commas, unmatched parentheses, and the wrong type of closing brace.


```{r ex-qXxiL-1, eval = TRUE, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Examples of Common Syntax Mistakes'}
# Example of a common syntax mistake: missing commas
x <- c("a", "b" "c")

# Example of unmatched parentheses
sum(c(1, 2, 3)

# Example of the wrong type of closing brace
for(i in 1:3) {
  print(x[i))
}

```


## Exercises


### Exercise 1

Find the data types for the built-in `airquality` data frame.

<details><summary>Click for Hint</summary>

> # Use the `data()` function to load built-in datasets in R.

</details>

<details><summary>Click for Hint</summary>

> # After loading, use the `str()` function to see the structure of the data frame, which includes data types of each column.

</details>

<details><summary>Click for Solution</summary>

#### Solution

To understand the structure and data types of the `airquality` data frame, we first load it using `data("airquality")` and then use `str(airquality)`. This command displays the data types for each column, helping us understand the dataset's structure.


```r
data("airquality")

str(airquality)

```

</details>

---


### Exercise 2

Create the vector `monitors <- c("site 1", "site two", "site 2", "site one")`. Use logical expressions to standardize the character values.

<details><summary>Click for Hint</summary>

> # Start by creating the vector with `c()`. Then, use logical indexing to identify and replace values.

</details>

<details><summary>Click for Hint</summary>

> # To standardize, identify each unique format and decide on a standard form. Use logical expressions like `monitors[monitors == "site one"] <- "site 1"` to make replacements.

</details>

<details><summary>Click for Solution</summary>

#### Solution

The goal is to standardize the naming convention within the vector `monitors`. We achieve this by identifying non-standard names and replacing them using logical expressions combined with the assignment operator `<-`. This ensures all site names follow a consistent format, enhancing data uniformity.


```r
monitors <- c("site 1", "site two", "site 2", "site one")

monitors[monitors == "site one"] <- "site 1"

monitors[monitors == "site two"] <- "site 2"

monitors

```

</details>

---


### Exercise 3

Use a boxplot to check for outliers in the ozone column of the built-in `airquality` data frame.

<details><summary>Click for Hint</summary>

> # First, load the `airquality` data frame using `data("airquality")`.

</details>

<details><summary>Click for Hint</summary>

> # Use the `boxplot()` function and specify `airquality$Ozone` as the argument to plot the ozone column.

</details>

<details><summary>Click for Solution</summary>

#### Solution

The boxplot is a convenient tool to visualize the distribution of the `Ozone` column in the `airquality` dataset, including any outliers. By using `boxplot(airquality$Ozone)`, we generate a plot that clearly shows the central tendency, dispersion, and outliers of the ozone measurements.


```r
data("airquality")

boxplot(airquality$Ozone)
```

</details>

---



