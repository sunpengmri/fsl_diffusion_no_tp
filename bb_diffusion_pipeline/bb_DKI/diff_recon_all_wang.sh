#!/usr/bin/bash


WorkDir=/home/dell/data/project1
RawDir=$WorkDir/sub_hc

sublist=($(ls ${RawDir}))
cd $RawDir

for sub in ${sublist[@]};  
do  
    python $BB_BIN_DIR/bb_diffusion_pipeline/bb_DKI/reconstruction.py -s ${sub} -t $RawDir
done  
