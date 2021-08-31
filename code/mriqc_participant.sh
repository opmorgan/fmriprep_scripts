#! /usr/bin/env bash

source globals.sh ## ($bids_dir set here)

subject_id=$1

out_dir=$bids_dir/derivatives/mriqc
tmp_dir=$bids_dir/tmp_mriqc ## (For intermediate files)
nthreads=2
mem=10 ## GB

## Check that BIDS directory exists
if [ ! -d $bids_dir ]; then
  printf "BIDS root directory ($bids_dir) does not exist! Exiting."
  exit
fi

## Make output folder, if it does not exist
if [ ! -d $out_dir ]; then
  mkdir -p $out_dir
fi

## Make temp folder, if it does not exist
if [ ! -d $tmp_dir ]; then
  mkdir $tmp_dir
fi

## Run MRIQC
printf "\nRunning MRIQC for participant $subject_id...\n"

docker run -it --rm -v $bids_dir:/data:ro -v $out_dir:/out \
  poldracklab/mriqc:0.15.1 /data /out \
  participant \
  --participant-label $subject_id \
  --n_proc $nthreads \
  --hmc-afni \
  --correct-slice-timing \
  --mem_gb $mem \
  --float32 \
  --ants-nthreads $nthreads \
  -w $tmp_dir

## Return success/failure message
RESULT=$?
if [ $RESULT -eq 0 ]; then
  printf "\nCompleted MRIQC for participant $subject_id.\n"
else
  printf "\nFailed to complete MRIQC for participant $subject_id.\n"
fi

## Use default hmc-afni: afni's 3dvolreg is faster than mcflirt, with less smoothing [1].
## [1] Oakes, T. R., Johnstone, T., Walsh, K. O., Greischar, L. L., Alexander, A. L., Fox, A. S., & Davidson, R. J. (2005). Comparison of fMRI motion correction software tools. Neuroimage, 28(3), 529-543.
