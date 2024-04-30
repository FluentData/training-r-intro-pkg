# Writing Functions, Conditionals, and Loops 

This lesson covers how to write your own R functions. It also explains how to automate
your code using `if()` and `ifelse()` functions, for loops, and the `apply`
function.
 

- [Prerequisites](#prerequisites)

- [Writing Functions](#writing-functions)

- [Arguments](#arguments)

- [Default Values](#default-values)

- [Positional Arguments](#positional-arguments)

- [if Functions](#if-functions)

- [For loops](#for-loops)

- [apply function](#apply-function)

## Prerequisites

This lesson assumes you are familiar with the material in the previous lessons:

- [Functions and Importing Data](../2-Functions-and_Importing-Data/readme.md)
- [Subsetting, Sorting, and Combining Data Frames](../3-Subsetting-Sorting-and-Combining/readme.md).

The data for these lessons is available from this package. It is assumed that this package is already installed and loaded into the R session. If you need to refer to the package, simply refer to it as "this package".


```{r ex-8TTHh-1, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Load Data from This Package'}
# Assuming the package is already loaded

data(chicago_air)

```

## Writing Functions

As discussed in the [second lesson on functions](../2-Functions-and_Importing-Data/readme.md),
R can execute a saved chunk of code by running the name of a function, like `mean()`.
The name `mean` is saved like a variable name, but since the name refers to a function,
the thing that's saved is not a data object but lines of R code.

To save your own function, use this construction:


```{r ex-neBnK-1, eval = FALSE, exercise = TRUE, exercise.cap = 'Creating Your Own Function'}
my_function_name <- function() {

  # lines of R code

}

```

We can write a simple function that prints something to the console. Here is a
function named `print_hello`.


```{r ex-mQoqe-2, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Simple Function to Print Hello'}
print_hello <- function() {

  print("Hello")

}

```

```{r ex-7BLAg-3, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Testing the print_hello Function'}
print_hello()

```

## Arguments

Most of the functions we have used in these lessons have had at least one argument
inside of the parentheses. The `print_hello()` function did not have any arguments,
so we could run it without putting anything inside `()`. We could modify the
function to take an argument that pastes some text to the printed message.

Here we recreate the same function, but this time we add an argument `text` inside
of the parentheses.


```{r ex-BgSKl-1, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Function with an Argument'}
print_hello <- function(text) {

  message <- paste("Hello", text)

  print(message)

}

```

```{r ex-Q6vpX-2, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Testing the Modified print_hello Function'}
print_hello(text = "everybody!")

```

## Default Values

We can create a function with more than one argument, and set default values when
needed. Suppose we would like to make a function that checks if a measurement is
greater than a criteria pollutant standard. We could make a simple function that
takes two arguments: one for the measurement value, and one for the standard value.


```{r ex-ALDHL-1, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Function with Two Arguments'}
standard_violated <- function(measurement, standard) {

  measurement > standard

}

```

```{r ex-Omj4G-2, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Testing standard_violated Function'}
standard_violated(measurement = 84, standard = 70)

```

We could write a more specific function for checking a value against the ozone
standard. For this function, we want to keep the `standard` parameter but make sure
the default is `70`. It may be that we typically want to use this function to
check against the current 8-hour ozone standard in parts per billion, but have
the flexibility to use a different value.

To set a default value, we use `= 70` when we create the function.


```{r ex-Aaca0-3, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Function with Default Value'}
standard_violated <- function(measurement, standard = 70) {

  measurement > standard

}

```

```{r ex-iTVv7-4, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Testing standard_violated with Default Value'}
standard_violated(measurement = 50)

```

## Positional Arguments

One final note on functions in R. When a function is created, the order of the
arguments are important. The user can supply values for the arguments in the order
they appeared in the parentheses of the `function( ){}` call, without writing out
the argument names.

For example, we can supply two numbers to the `standard_violated()` function that we
created above, without writing out the `measurement` and `standard` arguments.
When R executes the function, it will assign the numbers to the arguments
based on the position in the parentheses.

Here we show that using two numbers in a different order will return different
outputs.


```{r ex-pXUkw-1, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Testing Positional Arguments'}
standard_violated(60, 70)

```

```{r ex-LmYHt-2, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Testing Positional Arguments in Reverse Order'}
standard_violated(70, 60)

```

## if Functions

Writing custom functions is a good way to standardize some R code that can be reused
on different data sets. It's also helpful to write code that will execute different
lines of code depending on different scenarios. The functions `if()` and `ifelse()`
allow you to control what code is executed based on a logical condition.

The `if()` function takes the logical condition in the parentheses. The code that
will run if the logical expression is `TRUE` is placed inside curly braces. Below
is the outline (not actual R code).


```{r ex-e78TJ-1, eval = FALSE, exercise = TRUE, exercise.cap = 'if Function Outline'}
if(logical expression>) {

  <code that will run if the logical expression is TRUE>

}

```

```{r ex-kqQHu-2, eval = FALSE, exercise = TRUE, exercise.cap = 'if-else Function Outline'}
if(<logical expression>) {

  <code that will run if the logical expression is true>

} else {

  <code that will run if the logical expression is false>

}

```

```{r ex-QmpyS-3, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'if Function Example'}
ozone <- 0.075

if(ozone > 0.065) {

  print("Potential Health Effects")

} else {

  print("All Good")

}

```

```{r ex-4cokn-4, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Another if Function Example'}
ozone <- 0.06

if(ozone > 0.065) {

  print("Potential Health Effects")

} else {

  print("All Good")

}

```

```{r ex-oVA6y-5, eval = FALSE, exercise = TRUE, exercise.cap = 'ifelse Function Outline'}
ifelse(<test>, <yes>, <no>)

```

```{r ex-cxiJ0-6, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'ifelse Function Example'}
ozone_value <- 0.06

message <- ifelse(ozone_value > 0.065, "Potential Health Effects", "All Good")

print(message)

```

## For loops

Like most programming languages, R has for and while loops. This tutorial will
cover just for loops and move on to `apply()` functions, which are more commonly
used in R.

For loops are used to repeat an operation a set number of times. Here is the
basic outline:


```{r ex-dyBCK-1, eval = FALSE, exercise = TRUE, exercise.cap = 'For Loop Outline'}
for(i in sequence){

  <code that will run a set number of times>

}

```

```{r ex-B3TG2-2, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'For Loop Example'}
for(i in c(1, 2, 3)) {

  print(i)

}

```

Typically when we use loops, we want to perform the same operation on different
sets of data and save the results. To do this using the `for()` function in R,
we need to create an empty vector (or list or data frame) and save the results
during each iteration.

Here is an example data frame we will use. It represents a few values from three
monitors.


```{r ex-ZU3OM-3, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'For Loop with Data Frame'}
monitors <- data.frame(monitor1 = c(50, 60, 58, 52),
                       monitor2 = c(55, 59, 65, 61),
                       monitor3 = c(70, 62, 68, 71))

monitors

```

In the code below, we create an empty vector called max_values. As the
for() function loops through the vector c(1, 2, 3), the data frame columns
are accessed using square brackets [ , i]. Each max value is saved to
the max_values vector using square brackets [i].


```{r ex-o8Fn1-4, exercise = TRUE, exercise.eval = FALSE, exercise.cap = 'Finding Maximum Values with For Loop'}
max_values <- c()

for(i in c(1, 2, 3)) {

  max_values[i] <- max(monitors[, i])

}

max_values

```

## apply function

Although the for loop is common in programming languages, it is not the most
efficient way to apply a function to different sets of data in R. The most efficient
way to do loops in R is with the `apply()` family of functions, including `lapply()`,
`tapply()`, and `mapply()`. This section will demonstrate how to use the `apply()`
function.

The `apply()` function takes a data frame (or matrix) as the first argument. The
second argument determines if each loop will apply to the rows (`1`) or columns
(`2`). And the third argument is the function you want to apply to each row or column.
Additional arguments can be used to pass on to the function being applied to each
row or column.

The example below applies the `max()` function to the `monitors` data frame from
the previous section.


```{r ex-HKdx1-1, eval = FALSE, exercise = TRUE, exercise.cap = 'apply Function Example'}
monitors_max <- apply(monitors, MARGIN = 2, FUN = max)

monitors_max

```

The MARGIN argument is set to 2 because we are applying the max() function
to the columns of the data frame. Also notice that we do not need to create
an initial empty vector, as we did with the for() function. The returned
value is a named vector that is as long as the number of columns in the
data frame.

We could also find the mean of each row in the `monitors` data frame.
To do this, we would set the `MARGIN` argument to `1`.


```{r ex-7f5j2-2, eval = FALSE, exercise = TRUE, exercise.cap = 'apply Function Example with MARGIN = 1'}
apply(monitors, MARGIN = 1, FUN = mean)

```


## Exercises


### Exercise 1

Write a function named `ppm_to_ppb` that converts a value from parts per million to parts per billion.

<details><summary>Click for Hint</summary>

> # Define the function `ppm_to_ppb` with one argument for the value you want to convert.

</details>

<details><summary>Click for Hint</summary>

> # Inside the function, multiply the input value by 1000 to convert it to parts per billion.

</details>

<details><summary>Click for Hint</summary>

> # Return the converted value.

</details>

<details><summary>Click for Solution</summary>

#### Solution

The function `ppm_to_ppb` converts a given value from parts per million (ppm) to parts per billion (ppb) by multiplying the value by 1000, since 1 ppm is equal to 1000 ppb.


```r
ppm_to_ppb <- function(value) {
  value * 1000
}

```

</details>

---


### Exercise 2

Write a function named `check_value` that prints "warning" if a value is above a threshold, and "OK" if it's below. Make the threshold an argument in the function.

<details><summary>Click for Hint</summary>

> # Define the function `check_value` with two arguments: `value` and `threshold`.

</details>

<details><summary>Click for Hint</summary>

> # Use an `if` statement to check if `value` is greater than `threshold`.

</details>

<details><summary>Click for Hint</summary>

> # Print "warning" if the value is above the threshold, otherwise print "OK".

</details>

<details><summary>Click for Solution</summary>

#### Solution

The function `check_value` takes two arguments: a value and a threshold. It uses an if-else statement to print "warning" if the value is greater than the threshold, and "OK" if it's not, effectively monitoring values against a set benchmark.


```r
check_value <- function(value, threshold) {
  if(value > threshold) {
    print("warning")
  } else {
    print("OK")
  }
}

```

</details>

---


### Exercise 3

Use the `for()` function to loop through the `temp` column of the data from this package and print any value that is above 90 degrees.

<details><summary>Click for Hint</summary>

> # Access the `temp` column of the data frame within the loop.

</details>

<details><summary>Click for Hint</summary>

> # Use a `for` loop to iterate over each value in the `temp` column.

</details>

<details><summary>Click for Hint</summary>

> # Inside the loop, use an `if` statement to check if the current temperature value is greater than 90.

</details>

<details><summary>Click for Hint</summary>

> # If a value is above 90, use `print()` to display it.

</details>

<details><summary>Click for Solution</summary>

#### Solution

This loop iterates over each value in the `temp` column of the data frame, checking each temperature against the criterion of being greater than 90 degrees. If a temperature exceeds this threshold, it is printed, allowing for a simple scan of unusually high temperatures.


```r
for (i in chicago_air$temp) {
  if(i > 90) {
    print(i)
  }
}

```

</details>

---


### Exercise 4

Use the `apply()` function to create a vector of the mean values from the numeric columns in the data from this package.

<details><summary>Click for Hint</summary>

> # First, subset the data frame to include only the numeric columns you wish to analyze.

</details>

<details><summary>Click for Hint</summary>

> # Use the `apply()` function with the subsetted data frame, specifying `MARGIN = 2` to apply the function across columns.

</details>

<details><summary>Click for Hint</summary>

> # Use the `mean` function as the `FUN` argument, including `na.rm = TRUE` to handle missing values.

</details>

<details><summary>Click for Solution</summary>

#### Solution

To compute the mean values of the numeric columns in the data frame, we first isolate these columns into a new data frame. Then, the `apply()` function is used to calculate the mean of each, ensuring to remove any `NA` values with `na.rm = TRUE`. This produces a vector of mean values for the columns specified.


```r
chicago_numeric <- chicago_air[, c("ozone", "temp", "pressure")]
mean_values <- apply(chicago_numeric, MARGIN = 2, FUN = mean, na.rm = TRUE)
mean_values
```

</details>

---



