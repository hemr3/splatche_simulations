library(EasyABC) #needed for sims
library(abc) #needed for fitting
library(reshape2) #plotting tot sims against selected
library(lsr) #cohen's d (one samp)
library(coala) #for joint site freq spec
library(tidyverse) #for plots
library(patchwork) #for plots

  #this is the last step before running the sim
#before this, make sure that mod.input.R file is correct
#and that run_sim.sh looks right 

sum_stat_obs = c(0.000018, 0.000017, 0.000016, 0.000018, 0.000016)# 0.000017)
sum_stat_obs = c(0.000169, 0.000160, 0.000169, 0.000150, 0.000180)#, 0.000180 )
  #this sum_stat_obs is made with hets drawn from VCFs. 
  #in order: Alt, Vind, Mez, Chag, D4, D8
  
sum_stat_obs = sum_stat_obs * 1000 * 500
  #this creates expectancies of the thing tested for

prior = list(#c("unif",250,252), #AncSize
             c("unif", 0,0.5), #MigrationRate P1
             c("unif", 0,0.5), #MigrationRate P2
             c("unif", 0,0.5), #Admix P1-P2
             c("unif", 0,0.5), #Admix P2-P1
             c("unif", 0,0.025), #GrowthRate P1
             c("unif", 0,0.025)) #GrowthRate P2
  #this creates the prior expectation for the sim to draw no.s from 
  # currently has AncSize, MigraRate (for P1,P2)
  #'unif' shows a uniform dist, and 0,500 gives the limits

abc_sim = ABC_rejection(
  model = binary_model('/home/guy/splatche3/template/run_sim4.sh'),
  prior = prior,
  nb_simul = 5,
  summary_stat_target = sum_stat_obs,
  tol = 1.0 #could save all and do rej later
#  verbose = T
  )
      #above performs abc sim-but remember that tol needs to be somewhat high, and nb above 1

par(mfrow=c(2,2))
hist(abc_sim$param[,1], main = 'AncSize')
hist(abc_sim$param[,2], main = 'MigRate P1')
hist(abc_sim$param[,3], main = 'MigRate P2')
  #this shows (i think) which params were selected for the sims
  #acc - i think these are the accepted sims

params = subset(abc_sim$param)
param1 = params[,1] #Anc pop size
param2 = params[,2] #MigRate P1
param3 = params[,3] #MigRate P2
  #this splits the abc_sim$param into the three diff ones sim-ed

rej = abc(target = sum_stat_obs, 
          abc_sim$param, 
          abc_sim$stats, 
          tol = 0.05, #could do rej right now
          method = "rejection")
    #methods that can be used: rejection, loclinear and neuralnet (produces plots)
  #rejection method produces which are best 
  #this is estimate of the posterior

rej #just doing this can tell u how many of these sims were acceptable

rej$unadj.values #sims selected
vals = as.data.frame(subset(rej$unadj.values))
vals1 = vals[,1] #Anc pop size
vals2 = vals[,2] #MigRate P1
vals3 = vals[,3] #MigRate P2
vals4 = vals[,4] #AdmixP1-P2
vals5 = vals[,5] #AdmixP2-P1
vals6 = vals[,6] #Growthrate P1
vals7 = vals[,7] #Growthrate P2

rej$ss #their associated summary statistics

rej$dist #their norm-ed euclidean dist to data sum stats

#plotting (EastABC) params against stat averages ####
params = subset(abc_sim$param)
  #make the param into df

param1 = params[,1] #Anc pop size
  #separating out sim-ed params

aver = rowMeans(abc_sim$stats)
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
  ylab("Ancestral Population Size") +
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

p3 = 
  ggplot(vals1, aes(y=vals1, color = "darkpink"))+
  geom_boxplot(notch = T, outlier.colour = "black")+
  ylab("Ancestral Population Size")+
  ggtitle('Selected Simulations')+
  theme_minimal()
p3
  p4 = 
  ggplot(vals2, aes(y=vals2, color = "lavender"))+
  geom_boxplot(notch = T, outlier.colour = "black")+
  ylab("Denisovan Migration Rate")+
#  ggtitle('Selected Simulations')+
  theme_minimal()

p5 =
  ggplot(vals3, aes(y=vals3, color = "bisque"))+
  geom_boxplot(notch = T, outlier.colour = "black")+
  ylab("Neanderthal Migration Rate")+
#  ggtitle('Selected Simulations')+
  theme_minimal()
p6= 
  ggplot(vals4, aes(y=vals4, color = "darkgoldenrod"))+
  geom_boxplot(notch = T, outlier.colour = "black")+
  ylab("Denisovan Admixture")+
#  ggtitle('Selected Simulations')+
  theme_minimal()
p7 = 
  ggplot(vals5, aes(y=vals5, color = "darkgreen"))+
  geom_boxplot(notch = T, outlier.colour = "black")+
  ylab("Neanderthal Admixture")+
#  ggtitle('Selected Simulations')+
  theme_minimal()
p8 =
  ggplot(vals6, aes(y=vals6, color = "aquamarine"))+
  geom_boxplot(notch = T, outlier.colour = "black")+
  ylab("Denisovan Population Growth Rate")+
#  ggtitle('Selected Simulations')+
  theme_minimal()
p9 = 
  ggplot(vals7, aes(y=vals7, color = "red"))+
  geom_boxplot(notch = T, outlier.colour = "black")+
  ylab("Neanderthal Population Growth Rate")+
#  ggtitle('Selected Simulations')+
  theme_minimal()
p3+p4+p5+p6+p7+p8+p9


        #boxplot of the selected sims


p5 = ggplot(vals1, aes(x=vals1))+
  geom_histogram(aes(y=..density..), color= "black", fill = "aquamarine",
                 binwidth = 30)+
  geom_density(alpha=.3, fill = "brown")+
  #geom_vline(aes(yintercept = prior))+ #adds a unif dist to hist?   
  xlab('Ancestral Population Size')+
  ylab("Density")+
  ggtitle("Selected Simulations")+
  theme_minimal()
p4
    #this makes a nice hist of the selected sims for AncSize.     

test = wilcox.test(vals1, param1)
test$p.value
  #this tests whether the two samps are signif diff
  #they are - is because of huge diff in samp size?

vals1[nrow(vals1)+9500,] = NA

colnames(df3) = colnames(vals1)
anc = merge(param1, vals1)

#plotting total sims against accepted ####
param1 = as.list(param1)
vals1 = as.list(vals1)
  #this solution only works when its as a list
p = do.call(cbind, param1) 
p.melt = melt(p) #makes the list into a df for abc_sim
p.melt = p.melt %>% 
  mutate(Var1 = 1:length(Var1))
  #adds a length vector with the row number (makes it easier to plot)

v = do.call(cbind, vals1)
v.melt = melt(v) #makes the list into a df for rej$unadj.values
v.melt = v.melt %>% 
  mutate(Var1 = 1:length(Var1))
  #adds a length vector with the row number (makes it easier to plot)

ggplot()+
  geom_line(data = v.melt, aes(y=v.melt$Var1, x=v.melt$value), 
            color = "red")+
  geom_point(data = p.melt, aes(y=p.melt$Var1, x=p.melt$value))+
  theme_minimal()
  #plots the two df on the same plot, smaller df as the line

#posterior and prior hist plots (lansing et al 2017) ####
par(mfrow=c(2,3))

hist(param1,
     main = "Ancestral Size",
     border = "black",
     col = "red")
hist(param2,
     main = "Mig rates P1",
     border = "black",
     col = "red")
hist(param3,
     main = "Mig rates P2",
     border = "black",
     col = "red",)
  #hists above are all sims (prior)
hist(vals1,
     main = "Ancestral Size",
     border = "black",
     col = "darkorchid1",
     breaks = 6)
hist(vals2,
     main = "Mig rates P1",
     border = "black",
     col = "darkorchid1",
     breaks = 6)
hist(vals3,
     main = "Mig rates P2",
     border = "black",
     col = "darkorchid1",
     breaks = 6)
  #above are the selected sims (prior)
#fitting ####
gf = gfit(target = sum_stat_obs, 
          sumstat = abc_sim$stats, 
          nb.replicate = 10,
          tol = 0.05
          )
gf
  #this fits it - unsure how to interpret the results. 

#d-stats ####
mean(vals$V1)
cohensD(vals$V1, mu = 248.5389)

#abc_mcmc sims ####

abc_sim2 = ABC_mcmc(
  model = binary_model('/home/guy/splatche3/template/run_sim.sh'),
  prior = prior,
  summary_stat_target = sum_stat_obs,
  n_rec = 100,
  method = "Marjoram_original"
)

rej2 = abc(target = sum_stat_obs, 
          abc_sim2$param, 
          abc_sim2$stats, 
          tol = 0.09, #could do rej right now
          method = "rejection")

#joint site freq spectrum ####
  
