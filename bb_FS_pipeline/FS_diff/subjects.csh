 #!/bin/tcsh -ef
 #
setenv  SUBJECTS_DIR $TUTORIAL_DATA/diffusion_recons
setenv TUTORIAL_DIR  $TUTORIAL_DATA/diffusion_tutorial

set SUBJECTS = (Diff001 Diff002 Diff003 Diff004 Diff005 Diff006 Diff007 Diff008 Diff009 Diff010)
set LESION_SUBJECTS = (LDiff006 LDiff007 LDiff008 LDiff009 LDiff010)
set SUBJECTS_AND_LESION_SUBJECTS = (Diff001 Diff002 Diff003 Diff004 Diff005 LDiff006 LDiff007 LDiff008 LDiff009 LDiff010)