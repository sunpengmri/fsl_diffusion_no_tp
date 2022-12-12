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
            mri_glmfit-sim \
            --glmdir $FsStatsDir/$hemi.$meas.$smooth.glmdir \
            --perm 1000 3.0 pos \
            # --a2009s \
            --cwp 0.05  \
            --2spaces
        done
    done
done


