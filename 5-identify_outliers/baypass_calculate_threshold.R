#load modules
library(ape)
library(optparse)
library(corrplot)

#import parameters
option_list <- list(
  make_option(c('--infile')  ,action='store',type='character',default=NULL  ,help='Baypass output from simulated data'),
  make_option(c('--out')  ,action='store',type='character',default=NULL  ,help='Path to output directory and file name')
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

#read input files 
pod.xtx <- read.table(opt$infile, header = TRUE)

#compute 1% threshold
pod.thresh <- quantile(pod.xtx$M_XtX, probs = 0.99)

#Save threshold value to file
write.table(pod.thresh, 
	file = opt$out, 
	quote = FALSE, 
	row.names = FALSE, 
	col.names = FALSE)
