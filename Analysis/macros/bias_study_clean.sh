#!/bin/bash

inputdir=${1}

## makes datasets
# 2017
#./templates_maker.py --load templates_maker_bias.json,templates_maker_prepare_bias.json --selection cic2 --input-dir $inputdir -o $inputdir/bias_study_input_nopureweight.root --only-subset cic2 --prepare-data

##lumi_factor is kfactor*lumi 1.5*10/fb


##################
###  EBEB 2017 ###
##################

for model in "pow4" "expow2" "invpow" "moddijet" "invpowlin"
do

    www=~/www/exo/spring17/$1/bias_study_data_EBEB/${model}/

    # ./bkg_bias.py --throw-toys --lumi-factor=1. --n-toys=-1 --components "" --models $model --fit-name cic2 --read-ws $inputdir/bias_study_input_nopureweight.root -o $inputdir/bias_study_toys_from_mc_unbinned_nopureweight_${model}_asimov_EBEB.root --observable 'mgg[1954,230,10000]' --test-categories EBEB --use-data

    # ./bkg_bias.py --read-ws $inputdir/bias_study_toys_from_mc_unbinned_nopureweight_${model}_asimov_EBEB.root  -o $inputdir/bias_study_toys_from_mc_unbinned_EBEB_asimov_fit_nopureweight_${model}.root --observable 'mgg[1954,230,10000]' --n-toys -1 -O $www --fit-range 230,3000 --use-data --models $model --fit-toys --fit-name cic2 --plot-binning 94,230,2110  --saveas root,png,pdf --verbose --components ""  --plot-toys-fits

    # ./bkg_bias.py --throw-toys --lumi-factor=1. --n-toys=1000 --components "" --models $model --fit-name cic2 --read-ws $inputdir/bias_study_input_nopureweight.root -o $inputdir/bias_study_toys_from_mc_unbinned_${model}_EBEB.root  -O $www --observable 'mgg[1954,230,10000]' --test-categories EBEB --use-data --fit-range 230,10000 --throw-from-model
    
    # ./submit_toys.sh 8nm $inputdir/bias_study_toys_from_mc_unbinned_${model}_EBEB.root  $inputdir/bias_study_toys_from_mc_unbinned_${model}/EBEB 1000 10 --observable 'mgg[1954,230,10000]' --fit-range 230,5000 

    # ./hadd_toys.sh $inputdir/bias_study_toys_from_mc_unbinned_${model}/EBEB
    # ./bkg_bias.py --analyze-bias --bias-files $inputdir/bias_study_toys_from_mc_unbinned_${model}/EBEB/toys.root --dont-draw --analyze-categories dijet --bias-labels ${model} -O $www --legend-labels --saveas pdf,convert_png,root 

    echo
done

# www=~/www/exo/spring17/$1/bias_study_data_EBEB/
# ./bkg_bias.py --analyze-bias --bias-files $inputdir/bias_study_toys_from_mc_unbinned_expow2/EBEB/toys.root --bias-labels expow2 --bias-files $inputdir/bias_study_toys_from_mc_unbinned_pow4/EBEB/toys.root --bias-labels pow4 --bias-files $inputdir/bias_study_toys_from_mc_unbinned_invpow/EBEB/toys.root --bias-labels invpow --bias-files $inputdir/bias_study_toys_from_mc_unbinned_invpowlin/EBEB/toys.root --bias-labels invpowlin --bias-files $inputdir/bias_study_toys_from_mc_unbinned_moddijet/EBEB/toys.root --bias-labels moddijet -O $www --legend-labels --saveas pdf,convert_png,root --dont-draw --analyze-categories dijet --alternative-bias
              
##################
###  EBEE 2017 ###
##################

#"expow2" "invpow2" "moddijet3" "invpowlin"
for model in "pow4"
do

    www=~/www/exo/spring17/$1/bias_study_data_EBEE/${model}/

    # ./bkg_bias.py --throw-toys --lumi-factor=1. --n-toys=-1 --components "" --models $model --fit-name cic2 --read-ws $inputdir/bias_study_input_nopureweight.root -o $inputdir/bias_study_toys_from_mc_unbinned_nopureweight_${model}_asimov_EBEE.root --observable 'mgg[1934,330,10000]' --test-categories EBEE --use-data

    # ./bkg_bias.py --read-ws $inputdir/bias_study_toys_from_mc_unbinned_nopureweight_${model}_asimov_EBEE.root  -o $inputdir/bias_study_toys_from_mc_unbinned_EBEE_asimov_fit_nopureweight_${model}.root --observable 'mgg[1934,330,10000]' --n-toys -1 -O $www --fit-range 330,3000 --use-data --models $model --fit-toys --fit-name cic2 --plot-binning 89,330,2110  --saveas root,png,pdf --verbose --components ""  --plot-toys-fits

    # ./bkg_bias.py --throw-toys --lumi-factor=1. --n-toys=1000 --components "" --models $model --fit-name cic2 --read-ws $inputdir/bias_study_input_nopureweight.root -o $inputdir/bias_study_toys_from_mc_unbinned_${model}_EBEE.root  -O $www --observable 'mgg[1934,330,10000]' --test-categories EBEE --use-data --fit-range 330,10000 --throw-from-model
    
    # ./submit_toys.sh 8nm $inputdir/bias_study_toys_from_mc_unbinned_${model}_EBEE.root  $inputdir/bias_study_toys_from_mc_unbinned_${model}/EBEE 1000 10 --observable 'mgg[1934,330,10000]' --fit-range 330,5000 

    # ./hadd_toys.sh $inputdir/bias_study_toys_from_mc_unbinned_${model}/EBEE
    # ./bkg_bias.py --analyze-bias --bias-files $inputdir/bias_study_toys_from_mc_unbinned_${model}/EBEE/toys.root --dont-draw --analyze-categories dijet --bias-labels ${model} -O $www --legend-labels --saveas pdf,convert_png,root 
    
done

# exit

www=~/www/exo/spring17/$1/bias_study_data_EBEE/
./bkg_bias.py --analyze-bias --bias-files $inputdir/bias_study_toys_from_mc_unbinned_expow2/EBEE/toys.root --bias-labels expow2 --bias-files $inputdir/bias_study_toys_from_mc_unbinned_pow4/EBEE/toys.root --bias-labels pow4 --bias-files $inputdir/bias_study_toys_from_mc_unbinned_invpow2/EBEE/toys.root --bias-labels invpow2 --bias-files $inputdir/bias_study_toys_from_mc_unbinned_invpowlin/EBEE/toys.root --bias-labels invpowlin --bias-files $inputdir/bias_study_toys_from_mc_unbinned_moddijet3/EBEE/toys.root --bias-labels moddijet3 -O $www --legend-labels --saveas pdf,convert_png,root --dont-draw --analyze-categories dijet --alternative-bias


#94,2110
#189,4010



##################### NON PLUS ULTRA ###################################
 
#./bkg_bias.py --read-ws $inputdir/bias_study_toys_from_mc_unbinned_dijet_asimov_EBEE.root  -o $inputdir/bias_study_toys_from_mc_unbinned_EBEE_asimov_fit_dijet.root --observable 'mgg[1936,320,10000]' --plot-toys-fits --n-toys -1 -O /afs/cern.ch/user/m/mquittna/www/diphoton/spring16/full_analysis_spring16v1_sync_v1/bias_study_10fb_dijet/  --fit-range 320,10000 --store-new-only --components pp --models dijet --fit-toys --fit-name cic2 --plot-binning 184,320,4000  --saveas root,png
## throw toys for EBEB
#89,2100
#184,4000


### Create and run toys
# 2017
# ./bkg_bias.py --throw-toys --lumi-factor=1. --n-toys=1000 --components "" --models $model --fit-name cic2 --read-ws $inputdir/bias_study_toys_from_mc_unbinned_EBEB_asimov_fit_nopureweight_${model}.root -o $inputdir/bias_study_toys_from_mc_unbinned_${model}_EBEB.root  -O $www --observable 'mgg[4000,230,10000]' --test-categories EBEB --use-data --use-asimov --fit-range 230,10000 --throw-from-model 

# ./submit_toys.sh 1nh $inputdir/bias_study_toys_from_mc_unbinned_${model}_EBEB.root  $inputdir/bias_study_toys_from_mc_unbinned_${model}/EBEB 10000 100 --observable 'mgg[1954,230,10000]' --fit-range 230,5000 

#./submit_toys.sh short.q $inputdir/bias_study_toys_from_mc_unbinned_dijet_minuskfactor_EBEE.root  $inputdir/bias_study_toys_from_mc_unbinned_dijet_minuskfactor/EBEE 1000 20 --observable 'mgg[1936,320,10000]' --fit-range 320,10000 & 


##if you need to tune bias: look at profile_bias.root 
##define TF1 for fit with SetParameters according to old function
## see if fit defines bias well, for tail addition of constant can be usefu;
##if tail is overcorrected -lower order in power law
## try also two different function for both ends and try to interpolate


##./hadd_toys.sh $inputdir/bias_study_toys_from_mc_unbinned/EBEE

#./bkg_bias.py --analyze-bias --bias-files $inputdir/bias_study_toys_from_mc_unbinned_k01/toys.root --bias-files $inputdir/bias_study_toys_from_mc_unbinned_pluskfactor_k01/toys.root --dont-draw --scale-bias 10.07 --bias-labels default --bias-labels pNNLO --bias-files $inputdir/bias_study_toys_from_mc_unbinned_minuskfactor_k01/toys.root --bias-labels mNNLO --bias-files $inputdir/bias_study_toys_from_mc_unbinned_plusQCD_k01/toys.root --bias-labels pFakes -O /afs/cern.ch/user/m/mquittna/www/diphoton/spring16/full_analysis_spring16v1_sync_v1/bias_study_k01 --legend-labels --alternative-bias --saveas pdf,convert_png,root --analyze-categories EBEB 
