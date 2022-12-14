#!/usr/bin/bash

WorkDir=$1
meas=$2
hemis=$3
smoothing=$4
# WorkDir=/home/dell/data/project1
# meas="ISOVF ICVF OD "
# hemis="lh rh"
# smoothing="5 10"


export SUBJECTS_DIR=$WorkDir/FS
FsStatsDir=$WorkDir/FS_stats

for para in ${meas}
do
    for hemi in ${hemis}
    do
        for smooth in ${smoothing}
        do
            mri_glmfit-sim \
            --glmdir $FsStatsDir/$hemi.$para.$smooth.glmdir \
            --perm 100 1.0 pos \
            # --a2009s \
            --cwp 0.35  \
            --2spaces
        done
    done
done

# freeview -f /home/dell/data/project1/FS/fsaverage/surf/lh.inflated:overlay=lh.MD.5.glmdir/HC-MCI/perm.th30.pos.sig.cluster.mgh:overlay_threshold=0.5,5:annot=lh.MD.5.glmdir/HC-MCI/perm.th30.pos.sig.ocn.annot -viewport 3d -layout 1