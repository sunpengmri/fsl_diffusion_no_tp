#!/usr/bin/bash

WorkDir=$1
meas=$2
hemis=$3
smoothing=$4
# WorkDir=/home/dell/data/project1
# meas="DKI_MD DKI_FA DKI_AD DKI_RD DKI_MK DKI_AK DKI_RK DKI_MKT DKI_KFA ISOVF ICVF OD RTOP RTAP RTPP NORM MSD QIV NG NG_PER NG_PAR"
# hemis="lh rh"
# smoothing="5 10 "

export SUBJECTS_DIR=$WorkDir/FS
FsStatsDir=$WorkDir/FS_stats

for para in ${meas}
do
    for hemi in ${hemis}
    do
        for smooth in ${smoothing}
        do
            mri_glmfit \
            --y $FsStatsDir/${hemi}.${smooth}.total.${para}.fsaverage.mgh \
            --fsgd $FsStatsDir/fsgd \
            --C $FsStatsDir/HC-MCI.mtx \
            --surf fsaverage $hemi  \
            --cortex  --eres-save \
            --glmdir $FsStatsDir/$hemi.$para.$smooth.glmdir
        done
    done
done


