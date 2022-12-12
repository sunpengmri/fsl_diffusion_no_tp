#!/usr/bin/bash


WorkDir=/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang
RawDir=$WorkDir/test
export SUBJECTS_DIR=$WorkDir/FS
# 1. projection the DSI metrics to FS space 
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
    # AlignAnat2Diff
    atlases="wmparc aparc+aseg aparc.a2009s+aseg"
    if [ ! -d  $RawDir/${sub}/dMRI/surf_stats ]; then
        mkdir $RawDir/${sub}/dMRI/surf_stats
    fi
    
    for temp in ${atlases}
    do
        mri_vol2vol --mov ${RawDir}/${sub}/dMRI/dMRI/data.nii.gz \
        --targ  $SUBJECTS_DIR/${sub}/mri/${temp}.mgz --inv --interp nearest \
        --o ${RawDir}/${sub}/dMRI/dMRI/${temp}_diff.mgz \
        --reg ${RawDir}/${sub}/dMRI/dMRI/diff2t1.dat \
        --no-save-reg
        for para in ${meas}
        do
            mri_segstats \
                --seg ${RawDir}/${sub}/dMRI/dMRI/${temp}_diff.mgz \
                --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt \
                --i ${RawDir}/${sub}/dMRI/dMRI/dti_${para}.nii.gz \
                --sum $RawDir/${sub}/dMRI/surf_stats/${para}_${temp}.stats
        done        
    done

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