# splatche_simulations
A repository of code for running SPLATCHE3 simulations and producing visualisations

abc.R actually runs the simulations and fits them. 

mod_input.R changes the shifting priors with every simulation. 

template.txt is the toy model, and run_sim2.sh runs this toy in ABC. joint.R produces the jsfs for this code. 

splatche_input.txt is the true model, and run_sim4.sh. arp_to_vcf.py and sfs_on_vcf_dadi_wrapper.py produces JSFS for this code.


Examples of code that work on the IdeaCentre terminal: 

python3 arpToVCF.py template_input_GeneSamples_2.arp template_input_GeneSamples_2.arp.vcf

python3 sfs_on_vcf_dadi_wrapper.py --in_vcf template_input_GeneSamples_2.arp.vcf --in_popfile popfile_arp_vcf.txt --out_sfs jsfs_test3.txt --populations denisovan altai vindija chagyrskaya mezmaiskaya --projections 2 2 2 2 –proportions_out

Where the pop_file.txt = a space-delimited list of the names of populations produced by the arlesumstats VCF files, and then names I want them known by:

1 denisovan

2 altai

3 vindija

4 denisovan

5 chagyrskaya

6 mezmaiskaya
