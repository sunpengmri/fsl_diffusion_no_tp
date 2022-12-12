 #!/bin/tcsh -ef
 #

source subjects.csh

# Loop through each subject
foreach subj ($SUBJECTS)
  echo $subj
  set outdir = $TUTORIAL_DIR/$subj/dtrecon

  # Use wmparc2diff.mgz to mask out noise in the fa.nii, adc.nii, and ivc.nii volumes
  foreach vol (fa adc ivc)
    set cmd = (mri_mask $outdir/$vol.nii $SUBJECTS_DIR/$subj/mri/wmparc2diff.mgz \
               $outdir/${vol}-masked.mgz)
    echo $cmd
    eval $cmd
  end

end