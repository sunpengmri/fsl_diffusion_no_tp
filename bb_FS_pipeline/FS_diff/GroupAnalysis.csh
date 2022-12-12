#!/bin/tcsh -ef

source subjects.csh

set outdir = $TUTORIAL_DIR/GLM
mkdir -p $outdir

# Assemble input for group analysis
set type = CVS-to-avg35    # alternatively could be 'TAL' or 'MNI'
set prefix = fa-masked     # alternatively could be adc-masked or ivc-masked
set inputfiles = ()

foreach subj ($SUBJECTS)
  set inputfiles=($inputfiles $TUTORIAL_DIR/$subj/dtrecon/${prefix}.ANAT+${type}.mgz)
end

set cmd = (mri_concat --i $inputfiles --o $outdir/GroupAnalysis.${prefix}.${type}.Input.mgz)
echo $cmd
eval $cmd

# Create average of the input images for visualization
set cmd = (mri_average $inputfiles $outdir/Average.{$prefix}.${type}.Input.mgz)
echo $cmd
eval $cmd

set cmd = (mri_glmfit --y $outdir/GroupAnalysis.{$prefix}.${type}.Input.mgz \
          --fsgd group_analysis.fsgd dods --C contrast.mtx \
          --glmdir $outdir/gender_age.{$prefix}.${type}.glmdir --mgz)
echo $cmd
eval $cmd
