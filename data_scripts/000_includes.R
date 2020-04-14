library(tidyverse)
library(broom)
library(arrow)
library(gt)
library(sf)

isco_labels <- c('0'='Armed forces and unspecified', 
                 '1'='Managers', 
                 '2'='Academics', 
                 '3'='Technicians and associate professionals', 
                 '4'='clerical support workers',
                 '5'= 'Service and sales workers',
                 '6'='Skilled agricultural, forestry and fishery workers',
                 '7'='Craft and related trades workers',
                 '8'='Plant and machine operators and assemblers',
                 '9'='Elementary Occupations')
