#load modules
library(ape)
library(mvtnorm)
library(optparse)

#import parameters
option_list <- list(
  make_option(c('--omega')  ,action='store',type='character',default=NULL  ,help='path to omega file produced during first run of baypass'),
  make_option(c('--beta')    ,action='store',type='character',default=NULL  ,help='path to summary_beta_params.out file produced by baypass'),
  make_option(c('--baypass')    ,action='store',type='character',default=NULL  ,help='path to baypass input allele frequency file'),
  make_option(c('--Rfunctions')    ,action='store',type='character',default=NULL  ,help='path to baypass_utils.R (sourced from github)'),
  make_option(c('--suffix')    ,action='store',type='character',default=NULL  ,help='suffix appended to all output (not a path)')
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

#source R script (baypass_utils.R script)
source(opt$Rfunctions)

#read input files 
omega <- as.matrix(read.table(opt$omega))
pi.beta.coef <- read.table(opt$beta, header=TRUE)
bta.data <- geno2YN(opt$baypass)

#prepare beta.pi vector
beta.pi <- as.numeric(pi.beta.coef$Mean)

#simulate dataset
simu.bta <- simulate.baypass(
	omega.mat = omega,
	nsnp = 5000,
	sample.size = bta.data$NN,
	beta.pi = beta.pi,
	pi.maf = 0,
	suffix = opt$suffix
)
 
