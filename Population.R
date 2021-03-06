# CMAP | Mary Weber | 12/4/2020

#POPULATION DATA AVAILABLE VIA API FOR 2000 and 2010; excel file for 1990
#look into using get_estimates for 1995, 2005, 2015 populations
library(tidycensus)
library(tidyverse)
library(readxl)

Pop1990 <- read_excel("Pop1990.xlsx")
df_2000 <- load_variables(2000, "sf1")
df_2010 <- load_variables(2010, "sf1")
year <- 2010
year2 <- 2000
counties = list(IL=c(31, 43, 89, 93, 97, 111, 197, 7, 37, 63, 91, 99, 103, 141, 201), IN=c(89,91,127), WI=c(59, 101, 127)) 

#2000 HH POP DATA 
pop_tables2 <- c("PCT0130")
var_list2 <- vector()

for (i in 1:length(pop_tables2)){
  y <- grep(pop_tables2[i], df_2000$name)
  var_list2 <- c(var_list2, y)
} 
pop_2000 <- df_2000[var_list2,]

pop_2000$Category <- gsub("!!.*?"," ",pop_2000$label)
pop_2000$Category <- sub(".*? ", "", pop_2000$Category)

a <- tibble()
for (i in 1:length(names(counties))) {
  b <- map_dfr(
    year2,
    ~ get_decennial(geography = "county", variables = pop_2000$name,county = counties[[i]],state = names(counties[i]),year2 = .x,survey = "sf1", cache_table = TRUE),
    .id = "year2")
  a = rbind(a, b)
}

pop_2000 <- merge(a, pop_2000, by.x = "variable", by.y = "name")


#2010 HH POP DATA
pop_tables1 <- c("P0120")
var_list1 <- vector()

for (i in 1:length(pop_tables1)){
  x <- grep(pop_tables1[i], df_2010$name)
  var_list1 <- c(var_list1, x)
} 
pop_2010 <- df_2010[var_list1,]

pop_2010$Category <- gsub(".*)!!","",pop_2010$label)
pop_2010$Category <- gsub("!!", " ", pop_2010$Category)
pop_2010$Category <- sub(".*? ", "", pop_2010$Category)


n <- tibble()
for (i in 1:length(names(counties))) {
  p <- map_dfr(
    year,
    ~ get_decennial(geography = "county", variables = pop_2010$name,county = counties[[i]],state = names(counties[i]),year = .x,survey = "sf1", cache_table = TRUE),
    .id = "year")
    n = rbind(n, p)
  }

pop_2010 <- merge(n, pop_2010, by.x = "variable", by.y = "name")

#clean up
df <- list(pop_2000, pop_2010)

for (i in 1:length(df)){
  df[[i]][["Category"]][substr(df[[i]][["Category"]], 1, 5) == "Total"] <- "County Total"
  df[[i]][["Category"]][df[[i]][["Category"]] == "Male"] <- "County Male Total"
  df[[i]][["Category"]][df[[i]][["Category"]] == "Female"] <- "County Female Total"
  df[[i]] <- separate(data = df[[i]], col = NAME, into = c("County", "State"), sep = "\\,")
  df[[i]] <- subset(df[[i]], select = -c(1:3,7:8))
}

pop_2000 <- df[[1]]
pop_2000$Year <- 2000
pop_2010 <- df[[2]]
pop_2010$Year <- 2010

#rm(list = ls())

