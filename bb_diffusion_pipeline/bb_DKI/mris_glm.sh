#!/usr/bin/bash


WorkDir=/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang
RawDir=$WorkDir/test
export SUBJECTS_DIR=$WorkDir/FS
FsStatsDir=$WorkDir/FS_stats
meas="MD"
hemis="lh rh"
smoothing="5 10 "
for para in ${meas}
do
    for hemi in ${hemis}
    do
        for smooth in ${smoothing}
        do
            mri_glmfit \
            --y $WorkDir/FS_stats/${hemi}.${smooth}.total.${para}.fsaverage.mgh \
            --fsgd $FsStatsDir/MD.fsgd/md.fsgd \
            --C $FsStatsDir/Contrasts/HC-MCI.mtx \
            --C $FsStatsDir/Contrasts/MCI-HC.mtx \
            --surf fsaverage $hemi  \
            --cortex  --eres-save \
            --glmdir $FsStatsDir/$hemi.$meas.$smooth.glmdir
        done
    done
done


