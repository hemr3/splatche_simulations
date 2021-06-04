#!/bin/bash
#pwd
#this version of run_sim.sh currently works. 
rm -fr /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput
Rscript /home/guy/splatche3/template/mod.input.R
until [ -f /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/arl_output ]; do
pushd /home/guy/splatche3/template/
/home/guy/splatche3/template/SPLATCHE3-Linux-64b /home/guy/splatche3/template/template_input.txt
popd
pushd /home/guy/splatche3/template/arlsumstat_linux/
/home/guy/splatche3/template/arlsumstat_linux/arlsumstat3522_64bit /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/template_input_GeneSamples_1.arp /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/arl_output 1 0 #run_silent
#popd #
#pushd /home/guy/splatche3/template/ #
#Rscript /home/guy/splatche3/template/joint.R #
popd
done
pwd
cat /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/arl_output > output
#cat /home/guy/splatche3/template/datasets_2layers-ver3/GeneticsOutput/arl_output /home/guy/splatche3/template/jsfs_output > /home/guy/splatche3/template/output_arlejsfs #
#will need to b on same line. 

