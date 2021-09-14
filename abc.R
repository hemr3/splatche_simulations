library(EasyABC) #needed for sims
library(abc) #needed for fitting
library(reshape2) #plotting tot sims against selected
library(lsr) #cohen's d (one samp)
library(coala) #for joint site freq spec
library(tidyverse) #for plots
library(patchwork) #for plots
library(formattable) #for tables

#this is the last step before running the sim
#before this, make sure that mod.input.R file is correct
#and that run_sim.sh looks right 

#sum_stat_obs = c(0.000016, 0.000016, 0.000014, 0.000018) # add jsfs at the end
  #this sum_stat_obs is made with hets drawn from VCFs. 
  #in order: Alt, Vind, Mez, Chag, D3, D8
  
sum_stat_obs = c(8, 8, 6, 9, 0.1220, 0.5138, 0.0441, 0.0004, 0.0072, 
                 0.0154, 0.0001, 0.0025, 0.0512, 0.0006, 0.0071, 0.0128, 0.0003, 
                 0.0033, 0.0102, 0.0001, 0.0166, 0.0002, 0.0025, 0.0083, 0.0001, 
                 0.0088, 0.0531, 0.0010, 0.0212, 0.0096, 0.0003, 0.0033, 0.0045, 
                 0.0000, 0.0078, 0.0003, 0.0023, 0.0043, 0.0002, 0.0023, 0.0052, 
                 0.0000, 0.0033, 0.0258, 0.0007, 0.0088, 0.0046, 0.0001, 0.0025, 
                 0.0056, 0.0001, 0.0033, 0.0025)

#sum_stat_obs = c(8, 8, 6, 9)

#sum_stat_obs = sum_stat_obs * 1000 * 500 #calc is what did to get the first four no above.
  #tell multi to only do first 4 for hi cov, first 6 for low cov
  #this creates expectancies of the thing tested for

prior = list(c("unif",0.11,0.8), #RiverCarCapChangeFactor
             c("unif", 0,0.005), #MigrationRate P1
             c("unif", 0,0.005), #MigrationRate P2
             c("unif", 0,0.02), #Admix P1-P2
             c("unif", 0,0.02), #Admix P2-P1
             c("unif", 0,0.54), #GrowthRate P1
             c("unif", 0,0.54)) #GrowthRate P2
  #this creates the prior expectation for the sim to draw no.s from 
  #'unif' shows a uniform dist, and 0,10000 gives the limits


abc_sim8 = ABC_rejection(
  model = binary_model('/home/guy/splatche3/template/run_sim4.sh'),
  prior = prior,
  nb_simul = 100000,
  summary_stat_target = sum_stat_obs,
  tol = 1.0 #could save all and do rej later
#  n_cluster = 6,
#  use_seed = T
# verbose = T
)
  #above performs abc sim-but remember that tol needs to be somewhat high, and nb above 1

rej = abc(target = sum_stat_obs, 
          abc_sim8$param, 
          abc_sim8$stats, 
          tol = 0.005, #proportion accepted
          method = "rejection")
  #methods that can be used: rejection, loclinear and neuralnet (latter two produces plots)
  #rejection method produces which are best 
  #this is estimate of the posterior

rej #just doing this can tell u how many of these sims were acceptable

rej$unadj.values #sims selected
vals = as.data.frame(subset(rej$unadj.values))
vals1 = vals[,1] #RiverCarCapChangeFactor
vals2 = vals[,2] #MigRate P1
vals3 = vals[,3] #MigRate P2
vals4 = vals[,4] #AdmixP1-P2
vals5 = vals[,5] #AdmixP2-P1
vals6 = vals[,6] #Growthrate P1
vals7 = vals[,7] #Growthrate P2

rej$ss #their associated summary statistics

rej$dist #their norm-ed euclidean dist to data sum stats

##plotting the uniform histograms v the selected ones ####
c1 <- rgb(173,216,230,max = 255, alpha = 80, names = "lt.blue")
c2 <- rgb(255,192,203, max = 255, alpha = 80, names = "lt.pink")

par(mfrow=c(2,1))

hist(param1, col = c1, main = "Ancestral Size", xlab = " ")
hist(vals1, col = c2, main = " ", xlab = "Size")



#plotting (EastABC) params against stat averages ####
params = subset(abc_sim$param)
  #make the param into df

param1 = params[,1] #Anc pop size
  #separating out sim-ed params

aver = rowMeans(abc_sim3$stats)
aver1 = rowMeans(rej$ss)
  #average of rows of stats of sims

param1 = as.data.frame(param1)
vals1 = as.data.frame(vals1)
vals2 = as.data.frame(vals2)
vals3 = as.data.frame(vals3)
vals4 = as.data.frame(vals4)
vals5 = as.data.frame(vals5)
vals6 = as.data.frame(vals6)
vals7 = as.data.frame(vals7)
  #for ggplot, must be coerced to df

par(mfrow=c(2,1))
  #allowing two to be plotted same frame
  #this doesn't work when using ggplot

p1 = ggplot(param1, aes(y=param1, x = aver)) +
  geom_point(shape = 18, size = 3, 
             alpha = 0.5, color = 'darksalmon') +
  xlab('All Simulations') +
  ylab("Carrying Capacity Change Factor") +
  theme_minimal()

p2 = ggplot(vals1, aes(y=vals1, x = aver1))+
  geom_point(shape = 18, size = 3,
             alpha = 0.5, color = 'darksalmon')+
  xlab('Selected simulations')+
  ylab(" ")+
  theme_minimal()
p1+p2
p2
  #this is a little scatterplot comparison
  #might be useful for the results

#p3 = 
#  ggplot(vals1, aes(y=vals1))+
#  geom_boxplot(notch = T, outlier.colour = "black", color = "salmon")+
#  ylab("Ancestral Population Size")+
#  ggtitle('Selected Simulations')+
#  theme_minimal()
#p3

  p4 = 
  ggplot(vals2, aes(y=vals1))+
  geom_boxplot(notch = T, outlier.colour = "black", color = "purple")+
  ylab("Denisovan Migration Rate")+
#  ggtitle('Selected Simulations')+
  theme_minimal()

#boxplot of selected sims below
p5 =
  ggplot(vals3, aes(y=vals2))+
  geom_boxplot(notch = T, outlier.colour = "black", color = "bisque")+
  ylab("Neanderthal Migration Rate")+
#  ggtitle('Selected Simulations')+
  theme_minimal()
p6= 
  ggplot(vals4, aes(y=vals3))+
  geom_boxplot(notch = T, outlier.colour = "black")+
  ylab("Denisovan Admixture")+
#  ggtitle('Selected Simulations')+
  theme_minimal()
p7 = 
  ggplot(vals5, aes(y=vals4, color = "darkgreen"))+
  geom_boxplot(notch = T, outlier.colour = "black", color = "darkgoldenrod")+
  ylab("Neanderthal Admixture")+
#  ggtitle('Selected Simulations')+
  theme_minimal()
p8 =
  ggplot(vals6, aes(y=vals5))+
  geom_boxplot(notch = T, outlier.colour = "black", color = "aquamarine")+
  ylab("Denisovan Population Growth Rate")+
#  ggtitle('Selected Simulations')+
  theme_minimal()
p9 = 
  ggplot(vals7, aes(y=vals6))+
  geom_boxplot(notch = T, outlier.colour = "black", color = "red")+
  ylab("Neanderthal Population Growth Rate")+
#  ggtitle('Selected Simulations')+
  theme_minimal()
p3+p4+p5+p6+p7+p8+p9


#histograms of selected simulations ####
p10 = ggplot(vals1, aes(x=vals1))+
  geom_histogram(fill = c1, alpha = 0.7)+
  xlab(" ")+
  ylab("Frequency")+
  ggtitle("a: Carrying Capacity Change Factor")+
  theme_minimal()

p11 = ggplot(vals2, aes(x=vals2))+
  geom_histogram(fill = c1, alpha = 0.7, bins = 10)+
  xlab(" ")+
  ylab("Frequency")+
  xlim(0, 0.005)+
  ggtitle("b: Neanderthal migration rate")+
  theme_minimal()

p12 =ggplot(vals3, aes(x=vals3))+
  geom_histogram(fill = c1, alpha = 0.7, bins = 10)+
  xlab(" ")+
  ylab("Frequency")+
  xlim(0, 0.005)+
  ggtitle("c: Denisovan migration rate")+
  theme_minimal()

p13 =ggplot(vals4, aes(x=vals4))+
  geom_histogram(fill = c1, alpha = 0.7, bins = 10)+
  xlab(" ")+
  ylab("Frequency")+
  xlim(0, 0.02)+
  ggtitle("d: Neanderthal-to-Denisovan admixture rate")+
  theme_minimal()

p14 =ggplot(vals5, aes(x=vals5))+
  geom_histogram(fill = c1, alpha = 0.7, bins = 10)+
  xlab(" ")+
  ylab("Frequency")+
  xlim(0, 0.02)+
  ggtitle("e: Denisovan-to-Neanderthal admixture rate")+
  theme_minimal()

p15 =ggplot(vals6, aes(x=vals6))+
  geom_histogram(fill = c1, alpha = 0.7, bins = 10)+
  xlab(" ")+
  ylab("Frequency")+
  xlim(0, 0.54)+
  ggtitle("f: Neanderthal population growth rate")+
  theme_minimal()

p16 =ggplot(vals7, aes(x=vals7))+
  geom_histogram(fill = c1, alpha = 0.7, bins = 10)+
  xlab(" ")+
  ylab("Frequency")+
  xlim(0, 0.54)+
  ggtitle("g: Denisovan population growth rate")+
  theme_minimal()

p11 + p12 + p13 + p14 + p15 + p16

ggsave("~/Pictures/Visualisations/splatche/100k_selected_distributions005.png", p10 + p11 + p12 + 
         p13 + p14 + p15 + p16, width = 15, height = 10)

#analysing the selected sims ####
sel = read_csv("selected_sims.csv")

formattable(sel, align = c("l", "l", "l", "l", "l", "l", "l"))
    #making a little table for the results to include

corel = rcorr(as.matrix(vals), type = "spearman")
  #test for correlation     

test = wilcox.test(vals1, param1)
test$p.value
  #this tests whether the two samps are signif diff
  #they are - is because of huge diff in samp size?

  
