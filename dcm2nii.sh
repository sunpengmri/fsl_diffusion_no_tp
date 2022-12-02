#!/usr/bin/bash

WorkingDir=/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang/test
sublist="con003"
# echo 'ls -l'
# sublist= echo 'ls /home/peng/Documents/00_github/01_mri/03_freesurfer/T1Raw'



for sub in ${sublist};  
do   
# 1. raw data tranformation
    cd ${WorkingDir}/${sub}
    mkdir T1
    mkdir dMRI
    mkdir dMRI/raw
    dcm2niix -f AP_raw -z y -o dMRI/raw SMS_PA* 
    dcm2niix -f T1_tmp -z y -o T1 T1_MPR*
    cd T1
    3dresample -dxyz 1 1 1 -prefix T1.nii.gz -inset T1_tmp.nii.gz
    rm T1_tmp.nii.gz
    cd ../dMRI/raw
    dwidenoise AP_raw.nii.gz AP_denoise.nii.gz -noise noiselevel.nii.gz -force
    mrdegibbs AP_denoise.nii.gz AP.nii.gz -force
    mv AP_raw.bval AP.bval
    mv AP_raw.bvec AP.bvec
    mv AP_raw.json AP.json

    cd ${WorkingDir}
    # 2. structure pipeline
    python '/media/peng/data/00_github/00_MR_Analysis/01_FSL/11_ukbiobank/fsl_diffusion_no_tp/bb_structural_pipeline/bb_pipeline_struct.py' \
    -s ${sub}
    # 3. diffusion pipeline
    python '/media/peng/data/00_github/00_MR_Analysis/01_FSL/11_ukbiobank/fsl_diffusion_no_tp/bb_diffusion_pipeline/bb_pipeline_diff.py' \
    -s ${sub}
done  