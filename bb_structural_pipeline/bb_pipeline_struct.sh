subject=demo001
logDir=demo001/logs
numVols=102
b0_threshold=100
projectDir=/home/peng/00_github/00_MR_Analysis/01_FSL/11_ukbiobank/UK_biobank_pipeline_v_1
${FSLDIR}/bin/fsl_sub -T 5  -N "bb_get_b0s_1_ + ${subject}" -l  $projectDir/$logDir \
 python $BB_BIN_DIR/bb_structural_pipeline/bb_get_b0s.py -i $projectDir/${subject}/dMRI/raw/AP.nii.gz \
 -o $projectDir/${subject}/dMRI/fieldmap/total_B0_AP.nii.gz \
 -n 102 -l 100