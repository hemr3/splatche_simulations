# splatche_simulations
A repository of code for running SPLATCHE3 simulations and producing visualisations

abc.R actually runs the simulations and fits them. 

mod_input.R changes the shifting priors with every simulation. 

template.txt is the toy model, and run_sim2.sh runs this toy in ABC. joint.R produces the jsfs for this code. 

splatche_input.txt is the true model, and run_sim4.sh. arp_to_vcf.py and sfs_on_vcf_dadi_wrapper.py produces JSFS for this code.
