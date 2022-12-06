#!/usr/bin/bash


WorkDir=/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang
RawDir=$WorkDir/test
export SUBJECTS_DIR=$WorkDir/FS
# mkdir -p $SUBJECTS_DIR

sublist="con002 con003"

# for sub in ${sublist};  
# do  
#     cd $RawDir/${sub}/dMRI/dMRI
#     # # get registration files diff2t1.dat 
#     bbregister --s ${sub} --mov ${RawDir}/${sub}/dMRI/dMRI/data.nii.gz --dti --reg diff2t1.dat \
#     --o diff2t1.nii.gz --fslmat diff2t1.mat --frame 0
# done  

cd $SUBJECTS_DIR 
metrics="FA MD"
for para in ${metrics}
do
    mris_preproc --target fsaverage --hemi lh \
    --iv  $RawDir/con002/dMRI/dMRI/dti_${para}.nii.gz $RawDir/con002/dMRI/dMRI/diff2t1.dat \
    --projfrac 0.5 \
    --out lh.dti_${para}.mgh
done




# freeview -v $SUBJECTS_DIR/fbirn-anat-101.v6/mri/orig.mgz:visible=0 \
#     fbirn-101/template.nii:reg=fbirn-101/register.lta -f \
#     $SUBJECTS_DIR/fbirn-anat-101.v6/surf/lh.white \
#     $SUBJECTS_DIR/fbirn-anat-101.v6/surf/rh.white \
#     -viewport cor