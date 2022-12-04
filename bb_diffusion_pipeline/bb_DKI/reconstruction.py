# FOR DKI,NODDI, AND MAP DIFFUSION FITTING
import os,sys,argparse,os.path
import numpy as np
import matplotlib.pyplot as plt
import dipy.reconst.dki as dki
import dipy.reconst.dti as dti
from dipy.reconst import mapmri
from dipy.core.gradients import gradient_table
from dipy.data import get_fnames, get_sphere
from dipy.io.gradients import read_bvals_bvecs
from dipy.io.image import load_nifti,save_nifti
from dipy.segment.mask import median_otsu
from scipy.ndimage import gaussian_filter
from dipy.viz import window, actor
from mpl_toolkits.axes_grid1 import make_axes_locatable
from dmipy.signal_models import cylinder_models, gaussian_models
from dmipy.distributions.distribute_models import SD1WatsonDistributed
from dmipy.core.acquisition_scheme import acquisition_scheme_from_bvalues
from dmipy.core.modeling_framework import MultiCompartmentModel

# user setup
big_delta = 0.0365  # seconds
small_delta = 0.0157  # seconds

class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

class Usage(Exception):
    def __init__(self, msg):
        self.msg = msg

def reconstruction_dki_map_noddi():     

    parser = MyParser(description='recon dki noddi maps based dipy and dmipy')
    parser.add_argument('-s', dest='subject', type=str, nargs=1, help='subject name')
    parser.add_argument('-t', dest='workdir', type=str,nargs=1, help='workdir')

    argsa = parser.parse_args()
    
    if (argsa.subject==None):
        parser.print_help()
        exit()
    
    if (argsa.workdir==None):
        parser.print_help()
        exit()


    subject=argsa.subject[0]
    workingdir=argsa.workdir[0]

    # workingdir="/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang/con001/dMRI/dMRI"
    # fraw="/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang/con001/dMRI/dMRI/data.nii.gz"
    # fbval="/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang/con001/dMRI/dMRI/bvals"
    # fbvec="/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang/con001/dMRI/dMRI/bvecs"
    # fmask="/media/peng/data/02_MriDataSet/99_demo/15_ukbiobank/wang/con001/dMRI/dMRI/nodif_brain_mask.nii.gz"
    fraw=workingdir + '/' + subject + '/dMRI/dMRI/data.nii.gz'
    fbval=workingdir + '/' + subject + '/dMRI/dMRI/bvals'
    fbvec=workingdir + '/' + subject + '/dMRI/dMRI/bvecs'
    fmask=workingdir + '/' + subject + '/dMRI/dMRI/nodif_brain_mask.nii.gz'

    data, affine = load_nifti(fraw)
    bvals, bvecs = read_bvals_bvecs(fbval, fbvec)
    gtab_dki = gradient_table(bvals, bvecs)
    mask,mask_affine=load_nifti(fmask)

    # DKI
    dkimodel = dki.DiffusionKurtosisModel(gtab_dki)
    dkifit = dkimodel.fit(data, mask=mask)

    DKI_FA = dkifit.fa
    DKI_MD = dkifit.md
    DKI_AD = dkifit.ad
    DKI_RD = dkifit.rd
    DKI_MK = dkifit.mk(0, 3)
    DKI_AK = dkifit.ak(0, 3)
    DKI_RK = dkifit.rk(0, 3)
    DKI_MKT = dkifit.mkt(0, 3)
    DKI_KFA = dkifit.kfa

    # MAP
    gtab_map = gradient_table(bvals=gtab_dki.bvals, bvecs=gtab_dki.bvecs,
                        big_delta=big_delta,
                        small_delta=small_delta)

    radial_order = 6
    map_model_both_aniso = mapmri.MapmriModel(gtab_map, radial_order=radial_order,
                                            laplacian_regularization=True,
                                            laplacian_weighting=.2,
                                            positivity_constraint=False)


    mapfit_both_aniso = map_model_both_aniso.fit(data,mask)
    RTOP=mapfit_both_aniso.rtop()
    RTAP=mapfit_both_aniso.rtap()
    RTPP=mapfit_both_aniso.rtpp()
    NORM=mapfit_both_aniso.norm_of_laplacian_signal()
    MSD=mapfit_both_aniso.msd()
    QIV=mapfit_both_aniso.qiv()

    map_model_both_ng = mapmri.MapmriModel(gtab_map, radial_order=radial_order,
                                            laplacian_regularization=True,
                                            laplacian_weighting=.2,
                                            positivity_constraint=False,
                                            bval_threshold=2000)           

    mapfit_both_ng = map_model_both_ng.fit(data,mask)
    NG=mapfit_both_ng.ng()
    NG_PER=mapfit_both_ng.ng_perpendicular()
    NG_PAR=mapfit_both_ng.ng_parallel()


    ball = gaussian_models.G1Ball()
    stick = cylinder_models.C1Stick()
    zeppelin = gaussian_models.G2Zeppelin()
    watson_dispersed_bundle = SD1WatsonDistributed(models=[stick, zeppelin])
    # watson_dispersed_bundle.parameter_names
    watson_dispersed_bundle.set_tortuous_parameter('G2Zeppelin_1_lambda_perp','C1Stick_1_lambda_par','partial_volume_0')
    watson_dispersed_bundle.set_equal_parameter('G2Zeppelin_1_lambda_par', 'C1Stick_1_lambda_par')
    watson_dispersed_bundle.set_fixed_parameter('G2Zeppelin_1_lambda_par', 1.7e-9)
    NODDI_mod = MultiCompartmentModel(models=[ball, watson_dispersed_bundle])
    # NODDI_mod.parameter_names
    NODDI_mod.set_fixed_parameter('G1Ball_1_lambda_iso', 3e-9)
    acq_scheme = acquisition_scheme_from_bvalues(np.squeeze(bvals)*1e6, bvecs, small_delta, big_delta)

    NODDI_fit_result = NODDI_mod.fit(acq_scheme, data, mask=mask)
    fitted_parameters = NODDI_fit_result.fitted_parameters

    ISOVF=fitted_parameters['partial_volume_0']
    ICVF=fitted_parameters['SD1WatsonDistributed_1_partial_volume_0']
    OD=fitted_parameters['SD1WatsonDistributed_1_SD1Watson_1_odi']

    os.chdir(workingdir + '/' + subject + '/dMRI/dMRI')
    #NODDI
    save_nifti("dti_OD.nii.gz", OD,affine=affine)
    save_nifti("dti_ICVF.nii.gz", ICVF,affine=affine)
    save_nifti("dti_ISOVF.nii.gz", ISOVF,affine=affine)
    # MAP
    save_nifti("dti_RTOP.nii.gz", RTOP,affine=affine)
    save_nifti("dti_RTAP.nii.gz", RTAP,affine=affine)
    save_nifti("dti_RTPP.nii.gz", RTPP,affine=affine)
    save_nifti("dti_NORM.nii.gz", NORM,affine=affine)
    save_nifti("dti_MSD.nii.gz", MSD,affine=affine)
    save_nifti("dti_QIV.nii.gz", QIV,affine=affine)
    save_nifti("dti_NG.nii.gz", NG,affine=affine)
    save_nifti("dti_NG_PER.nii.gz", NG_PER,affine=affine)
    save_nifti("dti_NG_PAR.nii.gz", NG_PAR,affine=affine)
    # dki
    save_nifti("dti_DKI_FA.nii.gz", DKI_FA,affine=affine)
    save_nifti("dti_DKI_MD.nii.gz", DKI_MD,affine=affine)
    save_nifti("dti_DKI_AD.nii.gz", DKI_AD,affine=affine)
    save_nifti("dti_DKI_RD.nii.gz", DKI_RD,affine=affine)
    save_nifti("dti_DKI_MK.nii.gz", DKI_MK,affine=affine)
    save_nifti("dti_DKI_AK.nii.gz", DKI_AK,affine=affine)
    save_nifti("dti_DKI_RK.nii.gz", DKI_RK,affine=affine)
    save_nifti("dti_DKI_MKT.nii.gz", DKI_MKT,affine=affine)
    save_nifti("dti_DKI_KFA.nii.gz", DKI_KFA,affine=affine)


if __name__ == "__main__":
    reconstruction_dki_map_noddi()
