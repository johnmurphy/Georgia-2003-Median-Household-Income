'****************************************************************************************************************

Small script to scrape infoplease website to obtain 2003 Georgia median household income data.
2003 data is not 100% available from the American Community Survey (ACS). This 3rd party website provides data for 
all counties in Georgia for 2003.

****************************************************************************************************************'

# Check if package are installed, if not install them
if("rvest" %in% rownames(installed.packages()) == FALSE) {install.packages("rvest")}
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
if("stringr" %in% rownames(installed.packages()) == FALSE) {install.packages("stringr")}

# attach necessary libraries
library(rvest)
library(dplyr)
library(stringr)

# create an empty list to store dataframes in below loop
dfList = list()

# 1 to 176
for (i in 1:176)# 176 pages
{
  url <- str_c("https://www.infoplease.com/us/georgia/quickfacts-us-census-bureau-", i)
  
  # read the url html data assign to mhi
  mhi <-read_html(url)
  
  # narrow down to the location where the data is stored
  county_col <- mhi %>%
    html_nodes(xpath = '//td[@class="title"]/text()') 
  
  value_col <- mhi %>%
    html_nodes(xpath = '//td[@headers="rp29 p1"]/text()') 
  
  measure_col <- mhi %>%
    html_nodes("#rp29")
  
  # Place values into a dataframe
  df_mhi <- data_frame(county = html_text(county_col),
                       measure_year = html_text(measure_col),
                       value = html_text(value_col))
  
  # Separate county attribute into county and state
  # Separate measure_year attributre into measure year
  df_mhi <- df_mhi %>%
    separate(county, sep = ",", into = c('county', 'state')) %>%
    separate(measure_year, sep = ",", into = c('measure', 'year')) %>%
    filter(measure == 'Median household income') # filter on this measure. 
  
  # Clean up all the 'white spaces' in the dataframe
  df_mhi <- data.frame(lapply(df_mhi, trimws), stringsAsFactors = FALSE)
  
  # Add df to list
  dfList[[i]] <- df_mhi
  
}

# Clean up remove df2 from memory
rm(df_mhi)

df_mhi_2003 <- bind_rows(dfList) # bind dataframes together into single dataframe

# write output to csv file. Do once..
# write.csv(df_mhi_2003, file = "median_household_income_2003.csv")

# Done
