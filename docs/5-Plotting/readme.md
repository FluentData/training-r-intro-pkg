# Plotting in R 

In this lesson you will first learn how to quickly visualize data using a few base
plotting functions. The rest of the material explains how to use the `ggplot2` package
to build more complicated, multi-faceted plots. The `ggplot2` package is a powerful
 

- [Prerequisites](#prerequisites)

- [Base Plots](#base-plots)

- [Histogram](#histogram)

- [Box Plot](#box-plot)

- [ggplot2](#ggplot2)

- [Facets](#facets)

- [Fitted Lines](#fitted-lines)

- [Saving Plots](#saving-plots)

- [Factors](#factors)

## Prerequisites

This lesson assumes you are familiar with the material in the lesson on
[Subsetting, Sorting, and Combining Data Frames](../3-Subsetting-Sorting-and-Combining/readme.md).
It also uses functions from the `ggplot2` package which needs to be installed.


```{r ex-fe84dd83d8bf, eval = FALSE}
install.packages("ggplot2")

```

The example data for the exercises is available from this package. To load the `chicago_air` data frame we will be using in the lesson, simply use the `data()` function.


```{r ex-197ea48ccfae, exercise = FALSE, exercise.eval = FALSE, eval = TRUE, exercise.cap = 'Loading Data'}
data(chicago_air)

```

## Base Plots

The most basic way to visualize data in R is the `plot()` function. A numeric vector
will be displayed on the y-axis of a coordinate graph, with the index number of the
vector taking the x-axis values.


```{r ex-f7be4804cbeb, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Basic Plot'}
benzene <- c(1.3, 4.5, 2.6, 3.4, 6.4)

plot(benzene)

```

A second vector can be supplied for the scatter plot, and you can control which
vector is printed on the x-axis and which is printed on the y-axis. Below we use
the `chicago_air` data frame to create a scatterplot of temperature on the x-axis
and ozone on the y-axis.


```{r ex-192bbeef29ed, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Scatter Plot'}
plot(x = chicago_air$temp, y = chicago_air$ozone)

```

To see data plotted over time, we need to convert the `date` column to a `Date`
data type.


```{r ex-6fede1ac6070, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Converting Date Column'}
chicago_air$date <- as.Date(chicago_air$date)

```

Here is ozone plotted by day as a line graph.


```{r ex-93de3e61b5c3, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Line Graph'}
plot(x = chicago_air$date, y = chicago_air$ozone, type = 'l')

```

The `type` argument controls the type of plot, and there are many other arguments
to control the look of the graph. The plot below demonstrates a few of these
options. Run `?plot` to see a list of all the arguments in the help file.


```{r ex-9816a083742e, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Customized Plot'}
plot(x = chicago_air$date, y = chicago_air$ozone,
     type='l',
     pch = 16,
     col = "purple",
     lwd = 2.5,
     xlab = "Date",
     ylab = 'Ozone (ppm)',
     main = 'Chicago Ozone Data')

```

## Histogram

Another base plot function is `hist()`. It's used to visualize the distribution
of a data set as a histogram. Below is the default output of the ozone data
from the `chicago_air` data frame.


```{r ex-e60a5f4fde4a, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Default Histogram'}
hist(chicago_air$ozone)

```

We can control the number of bars in the plot, or where the breakpoints are for
each bar, with the `breaks` argument. For example, supplying `breaks = 20` will
make a histogram with 20 bars. Other arguments allow you to control the titles and colors of the plot. Run `?hist` to see a complete list of arguments on the help page.


```{r ex-54629f1909e8, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Customized Histogram'}
hist(chicago_air$ozone,
     breaks = 20,
     main = "Histogram of Ozone",
     xlab = "ppm",
     col = "steelblue")

```

## Box Plot

Another good way to visualize the distribution of a data set is the box plot. The
base function `boxplot()` takes either a vector or a data frame in the `data`
argument. If a data frame is used, then the columns can be referenced without the
`$` operator, and a formula must be used.


```{r ex-f80582ca4a03, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Simple Box Plot'}
boxplot(chicago_air$ozone)

```

The box shows the interquartile range (IQR), with the bold line indicating the
median of the ozone values. The horizontal lines at the end of the dotted lines
are the min and max ozone values within a certain range from the box (specifically,
1.5 times the IQR). If a value falls outside that range, it will be represented by
a point (the default point type is a circle). Overall, the plot gives an idea of
where the middle half of the values are, and if there are extreme values
on either side of the distribution.


The benefit of supplying a data frame to the `data` argument is to break the data
up into groups and display each group in a box plot. If a data frame is used, then
the `x` argument must be a _formula_. In R, a formula is a data type that represents
an equation like y = x. The way to represent this relationship in R is with the
`~` character: `y ~ x`. The `boxplot()` function needs a formula to know which
column in the data frame is being plotted, and which column is used to do the
grouping.

We can make a plot of ozone by month using the `chicag_air` data frame
and the formula `ozone ~ month`.


```{r ex-bcee057f0acc, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Box Plot by Month'}
boxplot(ozone ~ month, data = chicago_air)

```

## ggplot2

`ggplot2` is a popular data visualization package in R. It uses a layered approach
to build plots which allows you to add, remove, or change components in a modular
way.


To use `ggplot2`, we typically follow this sequence of steps:

1. Start with the `ggplot()` function where we specify the dataset, and then we
   map variables to "aesthetics" (i.e. visual properties of objects in the
   plot like shapes or colors).
2. Add `geoms` which are geometric objects like points (`geom_point` for
   scatter plots), bars (`geom_bar` for bar plots), or lines
   (`geom_line` for line plots) that determine the type of the plot.
3. Finally, customize and refine the plot with additional layers like
   labels, themes, facets etc.

Let's begin by loading the `ggplot2` package.


```{r ex-31b6f0232203, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Loading ggplot2 Package'}
library(ggplot2)

```

First we recreate the base scatter plot of ozone and temperature from the previous
section, starting with the `ggplot( )` function. The first argument `data` takes
the data frame. The `mapping` argument takes a function named `aes()`, which
is short for aesthetic. The primary arguments in the `aes( )` function are `x`
and `y`. These determine which columns from the data frame are displayed
on the graph.


```{r ex-db0216e33b3c, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Base ggplot'}
ggplot(chicago_air, aes(x = temp, y = ozone))

```

The code above creates the base plot, which is a coordinate system in the scale
of ozone and temperature, but is empty. The next step is to add more information
to the plot, which is done by adding a function using the `+` sign. For a point
plot, we add the `geom_point()` function.


```{r ex-4eee51b7b3ab, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'ggplot Scatter Plot'}
ggplot(chicago_air, aes(x = temp, y = ozone)) + geom_point()

```

Additional modifications can be made. Customize it by adding color, title, and labels.

```{r ex-b2e5db405405, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Customized ggplot Scatter Plot'}
ggplot(chicago_air, aes(x = temp, y = ozone)) +
  geom_point(color = "forestgreen") +
  ggtitle('Relationship between Ozone and Temperature') +
  xlab('Temperature (°F)') +
  ylab('Ozone (ppm)')

```

The `aes()` function can also map aesthetic properties like color based on other
columns in the data frame. We might want each point to have a different color based
on the month. To do this, we need to make the month column a factor and use the
argument `color` in the `aes( )` function.


```{r ex-38a6ad376582, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Color Coded Scatter Plot'}
ggplot(chicago_air, aes(x = temp, y = ozone, color = factor(month))) +
  geom_point() +
  ggtitle('Relationship between Ozone and Temperature') +
  xlab('Temperature (°F)') +
  ylab('Ozone (ppm)')

```

The `factor()` function converts the data type of the month column to a `factor`
class. This class represents categorical variables in R. See the section
on Factors in this lesson for more details.


To create a line plot of ozone over time, we use the `as.Date()` function on the date
column and replace the `geom_point( )` function with the `geom_line( )` function.


```{r ex-955612bbedea, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Line Plot Over Time'}
ggplot(chicago_air, aes(x = as.Date(date), y = ozone)) + geom_line()

```

The `geom_histogram()` function will create a histogram. The `bin` argument controls
the width of each bar, the `fill` argument the color of the bars, and the `color`
argument the outline of the bars.


```{r ex-11e85b5629db, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'ggplot Histogram'}
ggplot(chicago_air, aes(ozone)) +
  geom_histogram(binwidth=0.005, fill='darkorange', color='black')

```

The `geom_boxplot()` function will create a box plot.


```{r ex-e2f47ce72649, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Simple ggplot Box Plot'}
ggplot(chicago_air, aes(ozone)) + geom_boxplot()

```

Using the `y` argument can split the data into groups. Here we use the `factor()`
function on the month column to create 12 box plots on the graph.


```{r ex-b0535b4587a0, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Grouped Box Plot'}
ggplot(chicago_air, aes(x = ozone, y = factor(month))) + geom_boxplot()

```

See the [documentation site for ggplot2](https://ggplot2.tidyverse.org/reference/index.html#geoms)
for a complete list of `geom_` functions available.


## Facets

Another way to modify `ggplot2` plots is to break up the data into groups and make
multiple plots or facets. The `facet_wrap()` function allows you to use a column
to choose the facets. Below is a faceted histogram of ozone values.


```{r ex-ed09dc6a3248, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Faceted Histogram'}
ggplot(chicago_air, aes(ozone)) +
  geom_histogram() +
  facet_wrap("month")

```

## Fitted Lines

`ggplot2` also makes it easy to plot fitted lines and shaded confidence intervals
on graphs. The function `geom_smooth()` will create a line representing the relationship
between the x and y variables. The 95% confidence interval of that line will be
represented as a shaded area. Below, the argument `method` is given the value
`lm` which stands for a linear model.


```{r ex-196815e5d160, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Linear Model Fitted Line', message = FALSE, warning = FALSE}
ggplot(chicago_air, aes(temp, ozone) ) +
  geom_point() +
  geom_smooth(method=lm)

```

You can also fit curves to the data. For example, choosing `loess` for the `method`
argument will draw a nonlinear curve which represents localized relationships between
the x and y variables.


```{r ex-792cff92bc72, exercise = FALSE, exercise.eval = TRUE, exercise.cap = 'Nonlinear Curve Fitting', message = FALSE, warning = FALSE}
ggplot(chicago_air, aes(temp, ozone) ) +
  geom_point() +
  geom_smooth(method=loess)

```

## Saving Plots

Plots can be saved in RStudio using the "Export" button at the top of the "Plots"
pane.


![Screenshot showing how to save plots in RStudio.](./images/save_plot.png)

You can also save a plot made by `ggplot2` using the `ggsave()` function.


```{r ex-57c8e49d0178, eval = FALSE}
my_plot <- ggplot(chicago_air, aes(temp, ozone) ) +
  geom_point() +
  geom_smooth(method=loess)

ggsave(filename = "my_plot.png", plot = my_plot)

```

## Factors

Factors are a data structure used in R for categorizing data into a set of levels,
which is particularly useful in statistical modeling and visualizations that involve
categorical variables. They are important in R because they influence how data is
represented and analyzed in statistical models, ensuring the data is treated as
nominal or ordinal rather than continuous.

To create a factor in R, you use the `factor()` function. This function takes a
vector of alphanumeric values and converts it into a factor, which stores the data
as integers internally while maintaining labels for these integers. Here is an
example of converting a character vector into a factor:


```{r ex-1404f2ed1096, eval = TRUE}
months <- c("January", "February", "March", "January", "February")
months_factor <- factor(months)

months_factor

```

When you print the `months_factor` object, you will see the levels of
the factor and the integer values that represent each level. The levels
are ordered alphabetically by default, but you can specify the order of
the levels with the `levels` argument.


```{r ex-30416ba64388, eval = TRUE}
months_factor_ordered <- factor(months, levels = c("January", "February", "March"))

months_factor_ordered

```

Factors are particularly useful in data analysis for a few reasons:

- __Statistical Analysis__: Many statistical models require categorical data to
  be provided as factors in order to correctly analyze it.
- __Control Order__: Factors can be ordered or unordered, and you can specify the
  order of levels to influence data analysis and visual representation.
- __Efficiency__: Factors store data as integers, which can be more memory efficient
  than storing strings, especially for large datasets.



## Exercises


### Exercise 1

Make a scatter plot of barometric pressure and ozone from the `chicago_air` data frame. Use the `plot()` function with ozone on the y-axis, and provide helpful labels to the axes.

<details><summary>Click for Hint</summary>

> # To make a scatter plot, use the `plot()` function and specify the x and y arguments.

</details>

<details><summary>Click for Hint</summary>

> # For the x-axis, use `chicago_air$pressure` and for the y-axis, use `chicago_air$ozone`.

</details>

<details><summary>Click for Hint</summary>

> # To add labels to the axes, use the `xlab` and `ylab` parameters inside the `plot()` function.

</details>

<details><summary>Click for Solution</summary>

#### Solution

To make a scatter plot in R, the `plot()` function can be used by specifying the x-axis and y-axis variables. Here, barometric pressure is set as the x-axis and ozone as the y-axis. The `xlab` and `ylab` parameters are used to provide descriptive labels for the axes, making the plot easier to understand.


```r
plot(x = chicago_air$pressure, y = chicago_air$ozone,
     xlab = "Barometric Pressure",
     ylab = "Ozone")

```

</details>

---


### Exercise 2

Use the `plot()` function to make a line plot of temperature over time from the `chicago_air` data frame. Make sure the `date` column has the `Date` class and the line is red.

<details><summary>Click for Hint</summary>

> # First, check if the `date` column is of the `Date` class using `class(chicago_air$date)`. If it's not, convert it using `as.Date()`.

</details>

<details><summary>Click for Hint</summary>

> # To make a line plot, set the `type` parameter in the `plot()` function to `'l'` for line.

</details>

<details><summary>Click for Hint</summary>

> # Use the `col` parameter to set the color of the line to red.

</details>

<details><summary>Click for Solution</summary>

#### Solution

To make a line plot of temperature over time, it's crucial to ensure that the date column is correctly formatted as a `Date` class. If it's not, we can convert it using `as.Date()`. In the `plot()` function, setting `type` to `"l"` creates a line plot, and `col` to "red" specifies the color of the line. This plot helps in visualizing temperature changes over time.


```r
# if date column is not a Date class
chicago_air$date <- as.Date(chicago_air$date)

plot(x = chicago_air$date, y = chicago_air$temp, type = "l", col = "red")

```

</details>

---


### Exercise 3

With `ggplot2`, make box plots of ozone from the `chicago_air` data frame. Use the `weekday` column as a factor on the y-axis.

<details><summary>Click for Hint</summary>

> # Load the `ggplot2` package using `library(ggplot2)`.

</details>

<details><summary>Click for Hint</summary>

> # Use `aes(x = ozone, y = factor(weekday))` inside `ggplot()` to set the aesthetics for the box plot.

</details>

<details><summary>Click for Hint</summary>

> # Add `geom_boxplot()` to create the box plot.

</details>

<details><summary>Click for Hint</summary>

> # To separate plots by month, use `facet_wrap(~month)`.

</details>

<details><summary>Click for Solution</summary>

#### Solution

To create box plots of ozone levels by weekday using `ggplot2`, we utilize the `weekday` column as a factor for the y-axis and ozone for the x-axis. `geom_boxplot()` is used to generate the box plots, and `facet_wrap()` with `month` as the argument allows us to see the distribution of ozone levels across different weekdays for each month. This approach gives a comprehensive view of the ozone levels variation throughout the week and across months.


```r
ggplot(chicago_air, aes(x = ozone, y = factor(weekday))) +
  geom_boxplot() +
  facet_wrap(~month)

```

</details>

---


### Exercise 4

Use `ggplot2` to plot histograms of barometric pressure values for each month from the `chicago_air` data frame.

<details><summary>Click for Hint</summary>

> # Load the `ggplot2` package with `library(ggplot2)` if you haven't already.

</details>

<details><summary>Click for Hint</summary>

> # Use `aes(pressure)` inside `ggplot()` to set the aesthetic mapping for the histogram.

</details>

<details><summary>Click for Hint</summary>

> # Add `geom_histogram()` to create the histogram.

</details>

<details><summary>Click for Hint</summary>

> # Use `facet_wrap(~month)` to generate separate histograms for each month.

</details>

<details><summary>Click for Solution</summary>

#### Solution

By utilizing `ggplot2` to create histograms of barometric pressure values, we can analyze the distribution of these values across different months. The `aes()` function sets the aesthetic mapping for barometric pressure, and `geom_histogram()` is used to generate the histograms. With `facet_wrap(~month)`, the data is separated into individual histograms for each month, allowing for a clear comparison of barometric pressure distributions throughout the year.


```r
ggplot(chicago_air, aes(pressure)) +
  geom_histogram() +
  facet_wrap(~month)

```

</details>

---


### Exercise 5

__CHALLENGING EXERCISE!__ Use `ggplot2` and the data frame `ertac_egu_projections` from the `region5air` package to make a map of facility locations in the CONUS ERTAC region. 

<details><summary>Click for Hint</summary>

> # Use the `data()` function to load the `ertac_egu_projections` data frame and ?ertac_egu_projections to see the documentation. Which columns would be useful for the x and y coordinates?

</details>

<details><summary>Click for Hint</summary>

> # Use the `filter()` function from the `dplyr` package to filter down to the 'CONUS' region and look at the documentation for the `geom_polygon()` function: https://ggplot2.tidyverse.org/reference/geom_polygon.html.

</details>

<details><summary>Click for Hint</summary>

> # Use the `map_data()` function from the `maps` package to create a base map variable to use as the `data` parameter in the `geom_polygon()` function.

</details>

<details><summary>Click for Solution</summary>

#### Solution

This exercise involves creating a map of facility locations in the CONUS ERTAC region using `ggplot2` and the `ertac_egu_projections` data frame from the `region5air` package. By filtering the data to the "CONUS" region and using the `geom_polygon()` function with a base map variable, we can visualize the facility locations effectively. This exercise provides a challenging opportunity to practice plotting geospatial data in R.


```r
library(region5air)
library(ggplot2)
library(dplyr)
library(maps)

data(ertac_egu_projections)
# filter to CONUS region
conus <- filter(ertac_egu_projections, ertac_region == "CONUS")
states_map <- map_data("state")

ggplot() +
  geom_polygon(data = states_map, aes(x = long, y = lat, group = group),
               fill = "white", color = "black") +
  geom_point(data = conus, aes(x = longitude, y = latitude), color = "red",
             size = 3) +
  coord_fixed(1.3) +
  labs(title = "Map of the US with Points", x = "Longitude", y = "Latitude") +
  theme_minimal()

```

</details>

---



