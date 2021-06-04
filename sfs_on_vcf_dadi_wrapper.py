def install_and_import(package):
    import importlib
    try:
        importlib.import_module(package)
    except ImportError:
        import pip
        pip.main(['install', package])
    finally:
        globals()[package] = importlib.import_module(package)

install_and_import('dadi')

#import dadi
import argparse

#GSJ: Python3 wrapper around dadi for calculating and writing out the (joint) SFS from a VCF.
#01/06/2021

VERSION = 1.0

parser = argparse.ArgumentParser(description="This program will call dadi to read in a VCF, calculate a (j)SFS and write that out in matrix or flattened format.")

parser.add_argument('--in_vcf', '-vcf', dest='in_vcf', type=str, action = 'store', nargs='?', default = '',
                    help='full path of the VCF file to calculate the jSFS on.')
parser.add_argument('--in_popfile', '-popfile', dest='in_popfile', type=str, action = 'store', nargs='?', default = '',
                    help='full path of the popfile containing population information. Each line is "individual population".')
parser.add_argument('--out_sfs', '-out', dest='out_sfs', type=str, action = 'store', nargs='?', default = '',
                    help='full path of the output file to write the (j)sfs to.')

parser.add_argument('--populations', '-pops', dest='populations', type=str, action = 'store', nargs='*', default = [],
                    help='space-separated list of populations names to calculate the (j)SFS on.')
parser.add_argument('--projections', '-proj', dest='projections', type=int, action = 'store', nargs='*', default = [],
                    help='space-separated list of projections. Set to double the number of individuals in the specified populations to avoid projection. Projection will be preferable when there are many samples from a population and can be explored using dadi directly or e.g. easySFS.')
parser.add_argument('--polarized', '-p', dest='polarized', action = 'store_true',
                    help='flag to indicate that the polarized (unfolded) SFS should be calculated. This is not recommended without more profiling e.g. it likely assumes that the ref is ancestral?')
parser.add_argument('--keep_fixed', '-keep_fixed', dest='keep_fixed', action = 'store_true',
                    help='flag to indicate whether the corners - fixed 0 and fixed 1 - are masked. Default is true.')
parser.add_argument('--full_dadi_out', '-full_out', dest='full_dadi_out', action = 'store_true',
                    help='flag to indicate that the full dadi output is recorded, which can be used as input into Dadi and includes information like whether the SFS is folded and an SFS mask. If this flag is not used then a flattened space-separate single line of the (j)SFS is written out.')
parser.add_argument('--proportions_out', '-prop_out', dest='proportions_out', action = 'store_true',
                    help='flag to indicate that proportions are written out rather than counts. This is often more suitable for ABC fitting, though information on the overall level of diversity ie population sizes will be lost. If this is not selected then the counts may need to be rescaled for ABC fitting to account for differnet locus sizes etc.')
parser.add_argument('--spectrum_rescale', '-rescale', dest='spectrum_rescale', type=float, action = 'store', nargs='?', default = 1.0,
                    help='should the program rescale the SFS? You need to be careful here, and think about projection especially. E.g. when fitting, calculate the jSFS based on the same number of samples and the same projection. This command can then be used to rescale the (j)SFS based on simulated vs observed locus size, which can make the (j)SFS more informative than a relative number of allele freq counts.')


args = parser.parse_args()

##Testing values
#args.in_vcf = '/home/guy/Dropbox/CambridgeTeaching/students/HelenRidout/splatche3/example_output_reduced_settings_test_2layer-ver3_GeneSamples_1.arp.txt.vcf'
#args.in_popfile = '/home/guy/Dropbox/CambridgeTeaching/students/HelenRidout/splatche3/popfile_test.txt'
#args.out_sfs = '/home/guy/Dropbox/CambridgeTeaching/students/HelenRidout/splatche3/jsfs_test.txt'
#args.populations = ['pop1', 'pop2', 'pop3', 'pop4']
#args.projections = [4,8,4,2]
#args.full_dadi_out = False
#args.spectrum_rescale = 1.0
#args.proportions_out = True


assert len(args.populations) == len(args.projections)
if args.spectrum_rescale != 1.0 and args.proportions_out == True:
    raise RuntimeError("spectrum_rescale != 1.0 and proportions_out is True. Rescaling is intended to be used allele counts.")
if args.spectrum_rescale != 1.0 and args.full_dadi_out == True:
    raise RuntimeError("spectrum_rescale isn't an option if the full dadi output is being written.")
if args.proportions_out == True and args.full_dadi_out == True:
    raise RuntimeError("proportions_out isn't an option if the full dadi output is being written.")

def main():
    dd = dadi.Misc.make_data_dict_vcf(args.in_vcf, args.in_popfile)
    fs = dadi.Spectrum.from_data_dict(dd, args.populations, mask_corners = False if args.keep_fixed == True else True, projections = args.projections, polarized = args.polarized)
    if args.full_dadi_out == True:
        #Write the full (j)SFS in dadi format
        fs.to_file(args.out_sfs)
    else:
        fs_list = fs.tolist()
        for pop_flat in range(len(args.populations) - 1):
            fs_list = [item for sublist in fs_list for item in sublist]
        fs_list = dadi.numpy.array([i for i in fs_list if i is not None], dtype = float)
        fs_list = fs_list * args.spectrum_rescale #The re-scaling happens whether or not we first convert to proportions. If we convert to proportions afterwards then the rescaling is ignored, which makes sense given the input I think.
        if args.proportions_out == True:
            fs_list = fs_list / dadi.numpy.sum(fs_list)
        dadi.numpy.savetxt(fname = args.out_sfs, X = [fs_list], fmt = '%.4f')
        
if __name__ == "__main__":
    main()
