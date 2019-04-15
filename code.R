library(readxl)      #for excel, csv sheets manipulation
library(sdcMicro)    #sdcMicro package with functions for the SDC process 
library(tidyverse)   #for data cleaning

#Import data
setwd("C:/Users/LENOVO T46OS/Desktop/dra-geopoll-mozambique-cyclone-dataset")
data <- read_excel("data.xlsx")

#GeoPoll dataset
selectedKeyVarsI <- c('Country', 'Gender', 'Age', 'adm1', 'adm2',
                     'HouseholdStatements', 'HouseholdNumber'
)

#Convert variables into factors
cols =  c('Country', 'Gender','HouseholdStatements', 'adm1', 'adm2')
data[,cols] <- lapply(data[,cols], factor)

# Convert the sub file into dataframe
fileRes<-data[,selectedKeyVarsI]
fileRes <- as.data.frame(fileRes)

#Assess the disclosure risk
objSDCin <- createSdcObj(dat = fileRes, keyVars = selectedKeyVarsI)
#print(objSDCin, "risk")

#Anonymization methods
selectedKeyVarsF <- c( 'Gender',
                     'HouseholdStatements','adm1', 'adm2')

subVars <- c('id',selectedKeyVarsF)
fileResF<-data[,subVars]
fileResF <- as.data.frame(fileResF)
objSDCfin <- createSdcObj(dat = fileResF, keyVars = selectedKeyVarsF)

#Local suppression
objSDCfin <- localSuppression(objSDCfin, k=10)
print(objSDCfin, 'ls')

# Extract and store anonymized data
dataAnon <- extractManipData(objSDCfin)
fileUnanonymized <-data
fileUnanonymized[,c('id','Gender',
                    'HouseholdStatements',
                    'adm1', 'adm2')]<-list(NULL)
fileCombined <- bind_cols(x=dataAnon, y=fileUnanonymized)
write.csv(fileCombined,'geopoll_mozambique_cyclone_data_round1_final_anonymized_dataset.csv') 
#Generating an internal (extensive) report
print(objSDCfin, 'risk')
report(objSDCfin, filename = "index", internal = TRUE) 


