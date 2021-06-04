library(coala)
library(purrr, include.only = 'flatten')
line = readLines("~/splatche3/template/datasets_2layers-ver3/GeneticsOutput/template_input_GeneSamples_1.arp")

id = grep("1_[1|2].*", line) 
  #creates vector that isolates the line wanted
line1 = line[id]
line1 = gsub("1_1\t1\t", "" , line1)
line1 = gsub("1_2\t1\t", "" , line1)
line1 = gsub("\t", "" , line1)
  #removes the undesirable things from the line
line1 = line1[[1]]
  #includes only the first chr
samples = as.data.frame(strsplit(line1, ""),
                        col.names = "samp1") #split string
  #splits string, converts to df

id = grep("2_[1|2].*", line)
line2 = line[id]
line2 = gsub("2_1\t1\t", "" , line2)
line2 = gsub("2_2\t1\t", "" , line2)
line2 = gsub("\t", "" , line2)
line2 = line2[[1]]
samples$samp2 = as.data.frame(strsplit(line2, ""),
                              col.names = " ")

id = grep("3_[3|4].*", line)
line3 = line[id]
line3 = gsub("3_3\t1\t", "" , line3)
line3 = gsub("3_4\t1\t", "" , line3)
line3 = gsub("\t", "" , line3)
line3 = line3[[1]]
samples$samp3 = as.data.frame(strsplit(line3, ""),
                              col.names = " ")
                              
id = grep("4_[3|4].*", line)
line4 = line[id]
line4 = gsub("4_3\t1\t", "" , line4)
line4 = gsub("4_4\t1\t", "" , line4)
line4 = gsub("\t", "" , line4)
line4 = line4[[1]]
samples$samp4 = as.data.frame(strsplit(line4, ""),
                              col.names = " ")
                              
id = grep("5_[5|6].*", line)
line5 = line[id]
line5 = gsub("5_5\t1\t", "" , line5)
line5 = gsub("5_6\t1\t", "" , line5)
line5 = gsub("\t", "" , line5)
line5 = line5[[1]]
samples$samp5 = as.data.frame(strsplit(line5, ""))
  #issue with the samples df: cols 2-5 register as dfs, col names aren't what they should b

#comparisons
vector = as.data.frame(samples$samp1 == samples$samp1)
  #vector is new df with the T/F matrix in it
  #above compares 1=1 so it should all be T 
colnames(vector)[1] = "1=1"
  #renaming this col bc its being difficult

vector$`2=1` = samples$samp2 == samples$samp1
  #this adds new col which compares 2=1
  #must always be the bigger no. compared to first, no info lost
colnames(vector)[2] = "2=1"

vector$`3=1` = samples$samp3 == samples$samp1
colnames(vector)[3] = "3=1"

vector$`4=1` = samples$samp4 == samples$samp1
colnames(vector)[4] = "4=1"

vector$`5=1` = samples$samp5 == samples$samp1
colnames(vector)[5] = "5=1"

#conversion
for(i in 1:ncol(vector)) {
  if(is.logical(vector[, i]) == TRUE) 
    vector[, i] <- as.numeric(vector[, i])
}
  #this converts T to 1 and F to 0 - binarised  

vector = as.matrix(vector)
  #converts vector df to a matrix

segsites = create_segsites(vector,
                           c(.20,.40, .60, .80, 1.0)) #seq(0, 1, length.out = length(vector))
#0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.10, 0.11, 0.12, 0.13, 0.14, 0.15, 0.16, 0.17,
#0.18, 0.19, 0.20, 0.21, 0.22, 0.23, 0.24, 0.25, 0.26, 0.27, 0.28, 0.29, 0.30, 0.31, 0.32, 0.33, 0.34,
#0.35, 0.36, 0.37, 0.38, 0.39, 0.40, 0.41, 0.42, 0.43, 0.44, 0.45, 0.46, 0.47, 0.48, 0.49, 0.50, 0.51,
#0.52, 0.53, 0.54, 0.55, 0.56, 0.57, 0.58, 0.59, 0.60, 0.61, 0.62, 0.63, 0.64, 0.65, 0.66, 0.67, 0.68,
#0.69, 0.70, 0.71, 0.72, 0.73, 0.74, 0.75, 0.76, 0.77, 0.78, 0.79, 0.80, 0.81, 0.82, 0.83, 0.84, 0.85,
#0.86, 0.87, 0.88, 0.89, 0.90, 0.91, 0.92, 0.93, 0.94, 0.95, 0.96, 0.97, 0.98, 0.99, 1.00
  #not entirely sure how to create a viable segsites obj
  #c() relates to equally spaced loci along the seg
  #even tho rows/cols are bigger, the obj only registers 3x2

model <- coal_model(c(1,1,1,1,1),1, ploidy = 1) + 
  sumstat_jsfs("jsfs_12345", populations = c(1, 2, 3, 4, 5))
  #this creates coal model
  #it has 1 loci - still kinda unsure

sumstats <- calc_sumstats_from_data(model, list(segsites))
    #cals sumstats

flat = flatten(sumstats)
  #flattens array using purrr

flat = as.numeric(unlist(flat))
  #unlists + makes numeric  

flat = as.data.frame(t(flat))
#makes it a df  

flat_sum = flat / sum(flat)

write.table(flat_sum, file = "~/splatche3/template/jsfs_output", col.names = F, row.names = F)
  #col.names=F removes the header, but the first number is still wrapped in ""
