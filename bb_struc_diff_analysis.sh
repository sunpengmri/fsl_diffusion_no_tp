#!/usr/bin/bash
WorkDir=/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang

RawDir=$WorkDir/raw
sublist=($(ls $RawDir))

# 1. fsl analysis: TBSS and Xtract, and DKI,NODDI, and MAP recon
for sub in ${sublist[@]};
#for sub in ${sublist};
do   
#   1.1 raw data tranformation
    cd ${RawDir}/${sub}
    if [ ! -d  ${RawDir}/${sub}/dMRI ]; then
        mkdir T1
        mkdir dMRI 
        mkdir dMRI/raw
        dcm2niix -f AP_raw -z y -o dMRI/raw *SMS_PA* 
        dcm2niix -f T1_tmp -z y -o T1 T1_MPR*
        cd T1
        3dresample -dxyz 1 1 1 -prefix T1.nii.gz -inset T1_tmp.nii.gz
        rm T1_tmp.nii.gz
        cd ../dMRI/raw
        dwidenoise AP_raw.nii.gz AP_denoise.nii.gz -noise noiselevel.nii.gz -force
        mrdegibbs AP_denoise.nii.gz AP.nii.gz -force
        mv AP_raw.bval AP.bval
        mv AP_raw.bvec AP.bvec
        mv AP_raw.json AP.json
    fi
    cd ${RawDir}
    # 1.2 structure pipeline
    if [ ! -d  ${RawDir}/${sub}/T1/T1_vbm ]; then
        python $BB_BIN_DIR/bb_structural_pipeline/bb_pipeline_struct.py \
        -s ${sub}
    fi
    # 1.3 diffusion pipeline
    if [ ! -d  ${RawDir}/${sub}/dMRI/dMRI.xtract ]; then
        python $BB_BIN_DIR/bb_diffusion_pipeline/bb_pipeline_diff.py \
        -s ${sub}
    fi
    # 1.4 recon DKI, MAP, NODDI
    if [ ! -d  ${RawDir}/${sub}/dMRI/dMRI/dti_DKI_MK.nii.gz ]; then
        # should setup big and small delta in reconstruction.py
        python $BB_BIN_DIR/bb_diffusion_pipeline/bb_DKI/reconstruction.py \
        -s ${sub} -t $RawDir
    fi
    # 1.5 get roi stats for metrics of DKI, MAP, NODDI
    cd ${RawDir}
    $BB_BIN_DIR/bb_diffusion_pipeline/bb_tbss/bb_tbss_DSI_metrics ${sub}
done

# 2. TBSS for all subjects
meas="DKI_MD DKI_FA DKI_AD DKI_RD DKI_MK DKI_AK DKI_RK DKI_MKT DKI_KFA ISOVF ICVF OD RTOP RTAP RTPP NORM MSD QIV NG NG_PER NG_PAR"
$BB_BIN_DIR/bb_diffusion_pipeline/bb_tbss/bb_tbss_all_subjects "${RawDir[*]}" "${meas[*]}"

# 3. surface analysis
meas="DKI_MD DKI_FA DKI_AD DKI_RD DKI_MK DKI_AK DKI_RK DKI_MKT DKI_KFA ISOVF ICVF OD RTOP RTAP RTPP NORM MSD QIV NG NG_PER NG_PAR"
hemis="lh rh"
smoothing="5 10"

# 3.1 recon_all
    $BB_BIN_DIR/bb_FS_pipeline/recon_all_parallel.sh $WorkDir
# 3.2 projection all metrics to surface and roi analysis
    $BB_BIN_DIR/bb_diffusion_pipeline/bb_DKI/surf_analysis_diff_metrics.sh \
    $WorkDir $meas $hemis $smoothing
# 3.3 surface stats 
    # should creat fsgd file and contrast file in FS_stats
    $BB_BIN_DIR/bb_diffusion_pipeline/bb_DKI/mris_preproc.sh \
    "${WorkDir[*]}" "${meas[*]}" "${hemis[*]}" "${smoothing[*]}"

    $BB_BIN_DIR/bb_diffusion_pipeline/bb_DKI/mris_glm.sh \
    "${WorkDir[*]}" "${meas[*]}" "${hemis[*]}" "${smoothing[*]}"

    meas="ISOVF ICVF OD"
    $BB_BIN_DIR/bb_diffusion_pipeline/bb_DKI/mris_glm-sim.sh \
    "${WorkDir[*]}" "${meas[*]}" "${hemis[*]}" "${smoothing[*]}"
