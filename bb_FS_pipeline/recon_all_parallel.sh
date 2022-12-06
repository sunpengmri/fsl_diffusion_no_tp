#!/usr/bin/bash


WorkDir=/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang
RawDir=$WorkDir/test
export SUBJECTS_DIR=$WorkDir/FS
# mkdir -p $SUBJECTS_DIR

sublist="con002 con003"
cd $RawDir
mkdir temp
cd temp
for sub in ${sublist};  
do  
    cp ${RawDir}/${sub}/T1/T1_unbiased.nii.gz ./${sub}.nii.gz
    gunzip ./${sub}.nii.gz
done  
cd $RawDir/temp
ls *.nii | parallel --jobs 8 recon-all -s {.} -i {} -all -qcache
cd ..
rm -R temp/




