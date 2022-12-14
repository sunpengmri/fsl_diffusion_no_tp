#!/usr/bin/bash


WorkDir=/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang
RawDir=$WorkDir/raw

sublist=($(ls ${RawDir}))
cd $RawDir

for sub in ${sublist[@]};  
do  
    python $BB_BIN_DIR/bb_diffusion_pipeline/bb_DKI/reconstruction.py -s ${sub} -t $RawDir
done  
