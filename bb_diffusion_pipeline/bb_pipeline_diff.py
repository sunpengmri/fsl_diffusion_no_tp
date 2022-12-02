#!/bin/env python
#
# Script name: bb_pipeline_diff.py
#
# Description: Script with the dMRI pipeline. 
#			   This script will call the rest of dMRI functions.
#
# Authors: Fidel Alfaro-Almagro, Stephen M. Smith & Mark Jenkinson
#
# Copyright 2017 University of Oxford
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import bb_pipeline_tools.bb_logging_tool as LT
import sys,argparse,os.path

class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

class Usage(Exception):
    def __init__(self, msg):
        self.msg = msg

# def bb_pipeline_diff(subject, jobHold, fileConfiguration):
def bb_pipeline_diff():

    parser = MyParser(description='UK Biobank tool to get a B0 of a set of B0 images')
    parser.add_argument('-s', dest='subject', type=str, nargs=1, help='subject name')
    parser.add_argument('-t', dest='jobHold', type=str, default=['-1'],nargs=1, help='jobHold')
    parser.add_argument('-f', dest='fileConfig',type=str, default=[''], nargs=1,help='fileConfig')

    argsa = parser.parse_args()
    
    if (argsa.subject==None):
        parser.print_help()
        exit()
    
    if (argsa.jobHold==None):
        parser.print_help()
        exit()

    if (argsa.fileConfig==None):
        parser.print_help()
        exit()
    
    subject=argsa.subject[0]
    jobHold=argsa.jobHold[0]
    fileConfiguration=argsa.fileConfig[0]

    logger = LT.initLogging(__file__, subject)
    logDir  = logger.logDir
    baseDir = logDir[0:logDir.rfind('/logs/')]

    jobEDDY =         LT.runCommand(logger, '${FSLDIR}/bin/fsl_sub -T 75  -N "bb_eddy_'                + subject + '" -j ' + jobHold     + '  -q $FSLGECUDAQ -l ' + logDir + ' $BB_BIN_DIR/bb_diffusion_pipeline/bb_eddy/bb_eddy_no_topup ' + subject )
    jobDTIFIT =       LT.runCommand(logger, '${FSLDIR}/bin/fsl_sub -T 5   -N "bb_dtifit_'              + subject + '" -j ' + jobEDDY    + '  -l ' + logDir + ' ${FSLDIR}/bin/dtifit -k ' + baseDir + '/dMRI/dMRI/data -m ' + baseDir + '/dMRI/dMRI/nodif_brain_mask -r ' + baseDir + '/dMRI/dMRI/bvecs -b ' + baseDir + '/dMRI/dMRI/bvals -o ' + baseDir + '/dMRI/dMRI/dti')
    jobTBSS =         LT.runCommand(logger, '${FSLDIR}/bin/fsl_sub -T 240 -N "bb_tbss_'                + subject + '" -j ' + jobDTIFIT      + '  -l ' + logDir + ' $BB_BIN_DIR/bb_diffusion_pipeline/bb_tbss/bb_tbss_general ' + subject )
    # # we use dipy to process NODDI
    jobPREBEDPOSTX =  LT.runCommand(logger, '${FSLDIR}/bin/fsl_sub -T 5   -N "bb_pre_bedpostx_gpu_'    + subject + '" -j ' + jobTBSS      + '  -l ' + logDir + ' $BB_BIN_DIR/bb_diffusion_pipeline/bb_bedpostx/bb_pre_bedpostx_gpu ' + baseDir + '/dMRI/dMRI')
    jobBEDPOSTX =     LT.runCommand(logger, '${FSLDIR}/bin/fsl_sub -T 190 -N "bb_bedpostx_gpu_'        + subject + '" -j ' + jobPREBEDPOSTX + '  -q $FSLGECUDAQ -l ' + logDir + ' $BB_BIN_DIR/bb_diffusion_pipeline/bb_bedpostx/bb_bedpostx_gpu ' + baseDir + '/dMRI/dMRI')
    jobPOSTBEDPOSTX = LT.runCommand(logger, '${FSLDIR}/bin/fsl_sub -T 15  -N "bb_post_bedpostx_gpu_'   + subject + '" -j ' + jobBEDPOSTX    + '  -l ' + logDir + ' $BB_BIN_DIR/bb_diffusion_pipeline/bb_bedpostx/bb_post_bedpostx_gpu ' + baseDir + '/dMRI/dMRI')
    jobXTRACT =      LT.runCommand(logger, '$BB_BIN_DIR/bb_diffusion_pipeline/bb_xtract/bb_xtract_gpu ' + baseDir + '/dMRI/dMRI' + ' ' + jobPOSTBEDPOSTX)
    return jobXTRACT,

if __name__ == "__main__":
    bb_pipeline_diff()



# subject='con001'
# jobHold= '-1'
# fileConfiguration=''
# bb_pipeline_diff(subject, jobHold, fileConfiguration)

