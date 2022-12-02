#!/bin/env python

'''
 Authors: Fidel Alfaro Almagro
 FMRIB, Oxford University
 06-Apr-2019 18:03:23
 Version $1.0
 ProjectDir = 
 '''

import os,sys,argparse
import bb_pipeline_tools.bb_logging_tool as LT
import bb_pipeline_tools.bb_file_manager as FM

class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

class Usage(Exception):
    def __init__(self, msg):
        self.msg = msg


def bb_pipeline_FS(subject, jobHold, fileConfiguration):

    logger  = LT.initLogging(__file__, subject)
    logDir  = logger.logDir
    baseDir = logDir[0:logDir.rfind('/logs/')]

    if (not 'T1' in fileConfiguration) or (fileConfiguration['T1'] == ''):
        logger.error('There is no T1. FreeSurfer for subject ' + subject + ' cannot be run.')
        LT.finishLogging(logger)
        return -1
    
    else:
        jobFS01 = LT.runCommand(logger, 'fsl_sub -q long.qc  -N "bb_FS_run_'  + subject + '" -l ' + logDir + ' -j ' + jobHold + ' $BB_BIN_DIR/bb_FS_pipeline/bb_FS_run.sh  ' + subject)
        jobFS02 = LT.runCommand(logger, 'fsl_sub -q short.qc -N "bb_FS_segm_' + subject + '" -l ' + logDir + ' -j ' + jobFS01 + ' $BB_BIN_DIR/bb_FS_pipeline/bb_FS_segm.sh ' + subject )
        jobFS03 = LT.runCommand(logger, 'fsl_sub -q short.qc -N "bb_FS_IDPs_' + subject + '" -l ' + logDir + ' -j ' + jobFS02 + ' $BB_BIN_DIR/bb_FS_pipeline/bb_FS_get_IDPs.py ' + subject )

        LT.finishLogging(logger)
        return jobFS03


def main(): 
  
    parser = MyParser(description='BioBank FreeSurfer Tool')
    parser.add_argument("subjectFolder", help='Subject Folder')

    argsa = parser.parse_args()

    subject = argsa.subjectFolder
    subject = subject.strip()

    if subject[-1] =='/':
        subject = subject[0:len(subject)-1]
    
    fileConfig = FM.bb_file_manager(subject)

    jobSTEP1 = bb_pipeline_FS(subject, '-1', fileConfig)
    
    print(jobSTEP1)
             
if __name__ == "__main__":
    main()
