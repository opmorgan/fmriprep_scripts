#! /usr/bin/env bash

source globals.sh ## ($bids_dir set here)

out_dir=$bids_dir/derivatives/mriqc
tmp_dir=$bids_dir/tmp_mriqc ## (For intermediate files)
nthreads=2
mem=10 ## GB

## Check that BIDS directory exists
if [ ! -d $bids_dir ]; then
  printf "BIDS root directory ($bids_dir) does not exist! Exiting..."
  exit
fi

## Make output folder, if it does not exist
if [ ! -d $out_dir ]; then
  mkdir $out_dir
fi

## Make temp folder, if it does not exist
if [ ! -d $tmp_dir ]; then
  mkdir $tmp_dir
fi

## Run MRIQC
printf "\nRunning MRIQC for all participants...\n"

docker run -it --rm -v $bids_dir:/data:ro -v $out_dir:/out \
  poldracklab/mriqc:0.15.1 /data /out \
  participant \
  --n_proc $nthreads \
  --hmc-afni \
  --correct-slice-timing \
  --mem_gb $mem \
  --float32 \
  --ants-nthreads $nthreads \
  --ica \
  --verbose-reports \
  -w $bids_dir/tmp_mriqc

## Return success/failure message
RESULT=$?
if [ $RESULT -eq 0 ]; then
  printf "\nCompleted MRIQC for all participants.\n"
else
  printf "\nFailed to complete MRIQC for all participants.\n"
fi

## Use default hmc-afni: afni's 3dvolreg is faster than mcflirt, with less smoothing [1].
## [1] Oakes, T. R., Johnstone, T., Walsh, K. O., Greischar, L. L., Alexander, A. L., Fox, A. S., & Davidson, R. J. (2005). Comparison of fMRI motion correction software tools. Neuroimage, 28(3), 529-543.

