#!/usr/bin/bash

WorkDir=$1
meas=$2
hemis=$3
smoothing=$4
# WorkDir=/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang
# meas="DKI_MD DKI_FA DKI_AD DKI_RD DKI_MK DKI_AK DKI_RK DKI_MKT DKI_KFA ISOVF ICVF OD RTOP RTAP RTPP NORM MSD QIV NG NG_PER NG_PAR"
# hemis="lh rh"
# smoothing="5 10 "

RawDir=$WorkDir/raw
export SUBJECTS_DIR=$WorkDir/FS
FsStatsDir=$WorkDir/FS_stats

if [ ! -d  $FsStatsDir ]; then
    mkdir $FsStatsDir
fi
for para in ${meas}
do
    for hemi in ${hemis}
    do
        for smooth in ${smoothing}
        do
            mris_preproc --fsgd $FsStatsDir/fsgd \
                --cache-in ${smooth}.mean.${para}.fsaverage \
                --target fsaverage \
                --hemi ${hemi} \
                --out $FsStatsDir/${hemi}.${smooth}.total.${para}.fsaverage.mgh
        done
    done
done


