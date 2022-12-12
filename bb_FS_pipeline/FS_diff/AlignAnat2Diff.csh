 #!/bin/tcsh -ef
 #

source subjects.csh

# Loop through each subject
foreach subj ($SUBJECTS)
  echo $subj
  set outdir = $TUTORIAL_DIR/$subj/dtrecon

  # For each subject's wmparc and aparc+aseg volumes resample them to diffusion space
  foreach vol (wmparc aparc+aseg)
    set vol = $SUBJECTS_DIR/$subj/mri/$vol.mgz
    set vol2diff = ${vol:r}2diff.mgz
    set cmd = (mri_vol2vol --mov $outdir/lowb.nii --targ $vol --inv --interp nearest \
               --o $vol2diff --reg $outdir/register.dat --no-save-reg)
    echo $cmd
    eval $cmd
  end

end