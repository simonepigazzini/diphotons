#!/bin/bash

inputdir=${1}

## makes datasets
# 2017
#./templates_maker.py --load templates_maker_bias.json,templates_maker_prepare_bias.json --selection cic2 --input-dir $inputdir -o $inputdir/bias_study_input_nopureweight.root --only-subset cic2 --prepare-data

##lumi_factor is kfactor*lumi 1.5*10/fb

##EBEB and EBEE separate because of different fit ranges
##### throw asimov toy to check fit

model=pow4
www=~/www/exo/spring17/$1/bias_study_data/${model}/

# 2017
# for model in "pow4" "expow2" "invpow" "moddijet" "invpowlin"
# do
# ./bkg_bias.py --throw-toys --lumi-factor=1. --n-toys=-1 --components "" --models $model --fit-name cic2 --store-new-only --read-ws $inputdir/bias_study_input_nopureweight.root -o $inputdir/bias_study_toys_from_mc_unbinned_nopureweight_${model}_asimov_EBEB.root --observable 'mgg[1954,230,10000]' --test-categories EBEB --use-data
# done

# # 2017
# for model in "pow4" "expow2" "moddijet" "invpowlin"
# do
# ./bkg_bias.py --read-ws $inputdir/bias_study_toys_from_mc_unbinned_nopureweight_${model}_asimov_EBEB.root  -o $inputdir/bias_study_toys_from_mc_unbinned_EBEB_asimov_fit_nopureweight_${model}.root --observable 'mgg[1954,230,10000]' --plot-toys-fits --n-toys -1 -O $www --fit-range 230,3000 --store-new-only --use-data --models $model --fit-toys --fit-name cic2 --plot-binning 94,230,2110  --saveas root,png,pdf --verbose --components ""
# done

# ./bkg_bias.py --read-ws $inputdir/bias_study_toys_from_mc_unbinned_asimov_EBEB.root  -o $inputdir/bias_study_toys_from_mc_unbinned_EBEB_asimov_fit.root --observable 'mgg[1954,230,10000]' --plot-toys-fits --n-toys -1 -O /afs/cern.ch/user/m/mquittna/www/diphoton/spring16/full_analysis_spring16v1_sync_v1/bias_study_10fb_v2/  --fit-range 230,10000 --store-new-only --components pp --models dijet --fit-toys --fit-name cic2 --plot-binning 189,230,4010  --saveas root,png --verbose
#94,2110
#189,4010


#./bkg_bias.py --read-ws $inputdir/bias_study_toys_from_mc_unbinned_dijet_asimov_EBEE.root  -o $inputdir/bias_study_toys_from_mc_unbinned_EBEE_asimov_fit_dijet.root --observable 'mgg[1936,320,10000]' --plot-toys-fits --n-toys -1 -O /afs/cern.ch/user/m/mquittna/www/diphoton/spring16/full_analysis_spring16v1_sync_v1/bias_study_10fb_dijet/  --fit-range 320,10000 --store-new-only --components pp --models dijet --fit-toys --fit-name cic2 --plot-binning 184,320,4000  --saveas root,png
## throw toys for EBEB
#89,2100
#184,4000


#create toys
# 2017
./bkg_bias.py --throw-toys --lumi-factor=1. --n-toys=1000 --components "" --models $model --fit-name cic2 --store-new-only --read-ws $inputdir/bias_study_input_nopureweight.root -o $inputdir/bias_study_toys_from_mc_unbinned_${model}_EBEB.root  -O $www --observable 'mgg[4000,230,10000]' --test-categories EBEB --use-data --fit-range 230,10000 --throw-from-model 

#./bkg_bias.py --throw-toys --lumi-factor=15. --n-toys=10000 --components pp --models dijet --fit-name cic2 --store-new-only --read-ws $inputdir/bias_study_input_minuskfactor.root -o $inputdir/bias_study_toys_from_mc_unbinned_dijet_minuskfactor_EBEE.root  -O /afs/cern.ch/user/m/mquittna/www/diphoton/spring16/$inputdir/bias_study_10fb_dijet_minuskfactor   --observable 'mgg[3400,320,10000]' --test-categories EBEE &
#### fit the toys


# 2017
./submit_toys.sh 1nh $inputdir/bias_study_toys_from_mc_unbinned_pow4_EBEB.root  $inputdir/bias_study_toys_from_mc_unbinned_pow4/EBEB 10000 100 --observable 'mgg[1954,230,10000]' --fit-range 230,5000 

#./submit_toys.sh short.q $inputdir/bias_study_toys_from_mc_unbinned_dijet_minuskfactor_EBEE.root  $inputdir/bias_study_toys_from_mc_unbinned_dijet_minuskfactor/EBEE 1000 20 --observable 'mgg[1936,320,10000]' --fit-range 320,10000 & 


##if you need to tune bias: look at profile_bias.root 
##define TF1 for fit with SetParameters according to old function
## see if fit defines bias well, for tail addition of constant can be usefu;
##if tail is overcorrected -lower order in power law
## try also two different function for both ends and try to interpolate

# 2017
# ./hadd_toys.sh $inputdir/bias_study_toys_from_mc_unbinned_${model}/EBEB
# ./bkg_bias.py --analyze-bias --bias-files $inputdir/bias_study_toys_from_mc_unbinned_${model}/EBEB/toys.root --dont-draw --analyze-categories dijet --bias-labels ${model} -O $www --legend-labels --saveas pdf,convert_png,root

## 

##./hadd_toys.sh $inputdir/bias_study_toys_from_mc_unbinned/EBEE

#./bkg_bias.py --analyze-bias --bias-files $inputdir/bias_study_toys_from_mc_unbinned_k01/toys.root --bias-files $inputdir/bias_study_toys_from_mc_unbinned_pluskfactor_k01/toys.root --dont-draw --scale-bias 10.07 --bias-labels default --bias-labels pNNLO --bias-files $inputdir/bias_study_toys_from_mc_unbinned_minuskfactor_k01/toys.root --bias-labels mNNLO --bias-files $inputdir/bias_study_toys_from_mc_unbinned_plusQCD_k01/toys.root --bias-labels pFakes -O /afs/cern.ch/user/m/mquittna/www/diphoton/spring16/full_analysis_spring16v1_sync_v1/bias_study_k01 --legend-labels --alternative-bias --saveas pdf,convert_png,root --analyze-categories EBEB 
