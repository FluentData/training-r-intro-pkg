### Example #1

YAML Input:
```yaml
- type: code
  language: r
  options:
    exercise: true
    exercise.lines: 5
  code: |
    #Two steps
    x <- seq(from=1, to=10, by=3)
    mean(x)
```

Rmarkdown Output:
````
```{r example1, exercise = TRUE, exercise.lines = 5}
  #Two steps
  x <- seq(from=1, to=10, by=3)
  mean(x)
```
````

### Example #2

YAML Input:
```yaml
  - type: code
    language: r
    options:
      exercise: true
      exercise.eval: false
    code: |
      x <- c(1.3, 3.5, 2.6, 3.4, 6.4)
      serialCorrelationTest(x)
```

Rmarkdown Output:
````
```{r example2, exercise = TRUE, exercise.eval = TRUE}
  x <- c(1.3, 3.5, 2.6, 3.4, 6.4)
  serialCorrelationTest(x)
```
````
