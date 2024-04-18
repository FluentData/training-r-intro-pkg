
build_all_lessons <- function() {
  
  lessons <- c(
    "./inst/tutorials/1-Introduction/lesson1.yaml",
    "./inst/tutorials/2-Functions-and-Importing-Data/lesson2.yaml",
    "./inst/tutorials/3-Subsetting-Sorting-and-Combining/lesson3.yaml",
    "./inst/tutorials/4-Writing-Functions-Conditionals-and-Loops/lesson4.yaml",
    "./inst/tutorials/5-Plotting/lesson5.yaml",
    "./inst/tutorials/6-Basic-Statistics/lesson6.yaml",
    "./inst/tutorials/7-Quality-Assurance/lesson7.yaml"
  )  
  
  for(lesson in lessons) {
    print(lesson)
    build_learnr(lesson, save = TRUE)
  }
  
  
}


