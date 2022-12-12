 #!/bin/tcsh –ef
 #

source subjects.csh

# Run dt_recon on all subjects
foreach subj ($SUBJECTS)
  echo $subj
  set outdir = $TUTORIAL_DIR/$subj/dtrecon
  mkdir -p $outdir
  set dicomfile = $TUTORIAL_DIR/$subj/orig/*-1.dcm
  set cmd = (dt_recon --i $dicomfile --s $subj --o $outdir)
  echo $cmd
  eval $cmd
end