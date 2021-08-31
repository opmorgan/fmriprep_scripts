#! /usr/bin/env bash

source globals.sh ## ($bids_dir set here)

subject_id=$1

out_dir=$bids_dir/derivatives
tmp_dir=$HOME/fmri/tmp_fmriprep ## (For intermediate files)
nthreads=12
mem=20 #gb

## Export required environmental variables
export TEMPLATEFLOW_HOME=$HOME/fmri/lib/templateflow
export FS_LICENSE=$HOME/fmri/lib/fs_license.txt

#Convert virtual memory from gb to mb
mem=`echo "${mem//[!0-9]/}"` #remove gb at end
mem_mb=`echo $(((mem*1000)-5000))` #reduce some memory for buffer space during pre-processing

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

#Run fmriprep
printf "\nRunning fMRIprep for participant $subject_id...\n"

fmriprep-docker $bids_dir $out_dir \
  participant \
  --participant-label $subject_id \
  --skip-bids-validation \
  --md-only-boilerplate \
  --fs-license-file $FS_LICENSE \
  --fs-no-reconall \
  --output-spaces MNI152NLin2009cAsym:res-2 \
  --nthreads $nthreads \
  --stop-on-first-crash \
  --mem_mb $mem_mb \
  -w $tmp_dir

## Return success/failure message
RESULT=$?
if [ $RESULT -eq 0 ]; then
  printf "\nCompleted fMRIprep for participant $subject_id.\n"
else
  printf "\nFailed to complete fMRIprep for participant $subject_id.\n"
fi
