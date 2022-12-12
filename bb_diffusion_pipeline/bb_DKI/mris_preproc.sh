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
            mris_preproc --fsgd $FsStatsDir/MD.fsgd/md.fsgd \
                --cache-in ${smooth}.mean.${para}.fsaverage \
                --target fsaverage \
                --hemi ${hemi} \
                --out $FsStatsDir/${hemi}.${smooth}.total.${para}.fsaverage.mgh
        done
    done
done


