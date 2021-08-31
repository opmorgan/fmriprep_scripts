#! /usr/bin/env bash

source globals.sh ## ($bids_dir set here)

printf "\nRunning fMRIprep for all participants...\n"

for i in `cut -f1 $bids_dir/participants.tsv | tail -n +2`; do
  bash fmriprep_participant.sh $i;
done

## Return success/failure message
RESULT=$?
if [ $RESULT -eq 0 ]; then
  printf "\nCompleted fMRIprep for all participants.\n"
else
  printf "\nFailed to complete fMRIprep for all participants.\n"
fi
