#!/usr/bin/bash


WorkDir=/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang
RawDir=$WorkDir/test
export SUBJECTS_DIR=$WorkDir/FS

sublist="con002"
sublist=($(ls $RawDir))
meas="MD"
hemis="lh rh"
smoothing="5 10 "
for sub in ${sublist[@]};  
# for sub in ${sublist};
do  
    cd $RawDir/${sub}/dMRI/dMRI
    # # get registration files diff2t1.dat 
    if [ ! -f  $RawDir/${sub}/dMRI/dMRI/diff2t1.dat ]; then
        bbregister --s ${sub} --mov ${RawDir}/${sub}/dMRI/dMRI/data.nii.gz --dti --reg diff2t1.dat \
        --o diff2t1.nii.gz --fslmat diff2t1.mat --frame 0
    fi

    for para in ${meas}
    do
        for hemi in ${hemis}
        do
            for smooth in ${smoothing}
            do
                mri_vol2surf --mov $RawDir/$sub/dMRI/dMRI/dti_${para}.nii.gz \
                --ref $SUBJECTS_DIR/${sub}/mri/orig.mgz \
                --reg $RawDir/${sub}/dMRI/dMRI/diff2t1.dat \
                --fwhm 0 --surf-fwhm ${smooth} --hemi ${hemi} --trgsubject fsaverage --projfrac 0.25 \
                --o $SUBJECTS_DIR/${sub}/surf/${hemi}.25.${para}.fsaverage.mgh

                mri_vol2surf --mov $RawDir/$sub/dMRI/dMRI/dti_${para}.nii.gz \
                --ref $SUBJECTS_DIR/${sub}/mri/orig.mgz \
                --reg $RawDir/${sub}/dMRI/dMRI/diff2t1.dat \
                --fwhm 0 --surf-fwhm ${smooth} --hemi ${hemi} --trgsubject fsaverage --projfrac 0.5 \
                --o $SUBJECTS_DIR/${sub}/surf/${hemi}.50.${para}.fsaverage.mgh

                mri_vol2surf --mov $RawDir/$sub/dMRI/dMRI/dti_${para}.nii.gz \
                --ref $SUBJECTS_DIR/${sub}/mri/orig.mgz \
                --reg $RawDir/${sub}/dMRI/dMRI/diff2t1.dat \
                --fwhm 0 --surf-fwhm ${smooth} --hemi ${hemi} --trgsubject fsaverage --projfrac 0.75 \
                --o $SUBJECTS_DIR/${sub}/surf/${hemi}.75.${para}.fsaverage.mgh

                mris_calc --output $SUBJECTS_DIR/${sub}/surf/${hemi}.temp.${para}.fsaverage.mgh \
                $SUBJECTS_DIR/${sub}/surf/${hemi}.25.${para}.fsaverage.mgh add \
                $SUBJECTS_DIR/${sub}/surf/${hemi}.50.${para}.fsaverage.mgh 
                
                mris_calc --output $SUBJECTS_DIR/${sub}/surf/${hemi}.temp1.${para}.fsaverage.mgh \
                $SUBJECTS_DIR/${sub}/surf/${hemi}.temp.${para}.fsaverage.mgh add \
                $SUBJECTS_DIR/${sub}/surf/${hemi}.75.${para}.fsaverage.mgh 
                
                mris_calc --output $SUBJECTS_DIR/${sub}/surf/${hemi}.${smooth}.mean.${para}.fsaverage.mgh \
                $SUBJECTS_DIR/${sub}/surf/${hemi}.temp1.${para}.fsaverage.mgh div 3
                cd $SUBJECTS_DIR/${sub}/surf
                rm ${hemi}.temp.* ${hemi}.25.${para}.* ${hemi}.50.${para}.* ${hemi}.75.${para}.* ${hemi}.temp1.${para}.*
            done
        done
    done
done  

# mris_preproc --fsgd MD.fsgd/md.fsgd \
#     --cache-in mean.MD.fsaverage \
#     --target fsaverage \
#     --hemi lh \
#     --out lh.total.mgh


# cd $SUBJECTS_DIR 
# metrics="FA MD"
# for para in ${metrics}
# do
#     mri_vol2surf --mov 

    
#     mris_preproc --target fsaverage --hemi lh \
#     --iv  $RawDir/con002/dMRI/dMRI/dti_${para}.nii.gz $RawDir/con002/dMRI/dMRI/diff2t1.dat \
#     --projfrac 0.5 \
#     --out lh.dti_${para}.mgh
# done




# freeview -v $SUBJECTS_DIR/fbirn-anat-101.v6/mri/orig.mgz:visible=0 \
#     fbirn-101/template.nii:reg=fbirn-101/register.lta -f \
#     $SUBJECTS_DIR/fbirn-anat-101.v6/surf/lh.white \
#     $SUBJECTS_DIR/fbirn-anat-101.v6/surf/rh.white \
#     -viewport cor