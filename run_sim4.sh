#!/bin/bash
#pwd
#This run_sim file contains the arp_to_vcf and JSFS calculations
rm -fr /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput
Rscript /home/guy/splatche3/template/mod.input.R
until [ -f /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/arl_output ]; do
pushd /home/guy/splatche3/template/
/home/guy/splatche3/template/SPLATCHE3-Linux-64b /home/guy/splatche3/template/template_input.txt
popd
pushd /home/guy/splatche3/template/arlsumstat_linux/
/home/guy/splatche3/template/arlsumstat_linux/arlsumstat3522_64bit /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/template_input_GeneSamples_1.arp /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/arl_output 1 0 #run_silent
popd
pushd /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/ #
python3 ~/splatche3/template/arp_to_vcfs/arpToVCF.py '/home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/template_input_GeneSamples_2.arp' '/home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/template_input_GeneSamples_2.arp.vcf' #
popd #
python3 /home/guy/splatche3/template/arp_to_vcfs/sfs_on_vcf_dadi_wrapper.py --in_vcf /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/template_input_GeneSamples_2.arp.vcf --in_popfile /home/guy/splatche3/template/arp_to_vcfs/popfile_arp_vcf.txt --out_sfs /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/jsfs_test4.txt --populations denisovan altai vindija chagyrskaya mezmaiskaya --projections 2 2 2 2 2 --proportions_out #
done
pwd
cat /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/arl_output > output
#cat /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/arl_output /home/guy/splatche3/template/jsfs_output > /home/guy/splatche3/template/output_arlejsfs #
#will need to b on same line. 
