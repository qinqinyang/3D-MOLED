#!/bin/bash

# all related data in the subxxx folder (including T1W,MOLED-T2*,QSM,GRE-T2*,GSM)
# 
SUB_DIR="sub002"
cd "$SUB_DIR" || { echo " $SUB_DIR fail"; exit 1; }

T1W="T1W.nii"

if [ ! -f "$T1W_BRAIN" ]; then
  echo "SKull extraction -> $T1W_BRAIN"
  bet "$T1W" "$T1W_BRAIN" -R
fi


T2STAR_LIST=("GRE_t2star_01" "GRE_t2star_02" "OLED_t2star_01" "OLED_t2star_02")
QSM_LIST=("GRE_qsm_01" "GRE_qsm_02" "OLED_qsm_01" "OLED_qsm_02")



for i in "${!T2STAR_LIST[@]}"; do
  T2_NAME="${T2STAR_LIST[$i]}"
  QSM_NAME="${QSM_LIST[$i]}"

  BET_OUT="${T2_NAME}_brain.nii.gz"
  if [ ! -f "$BET_OUT" ]; then
    echo "bet $T2_NAME.nii -> $BET_OUT"
    bet "${T2_NAME}.nii" "$BET_OUT" -R
  fi

  FLIRT_OUT="${T2_NAME}_to_T1W.nii.gz"
  MAT_OUT="${T2_NAME}_to_T1W.mat"
  echo "flirt: $BET_OUT -> $FLIRT_OUT (dof 6, mutualinfo)"
  flirt -in "$BET_OUT" -ref "$T1W_BRAIN" -out "$FLIRT_OUT" -omat "$MAT_OUT" -dof 6 -cost mutualinfo


  QSM_IN="${QSM_NAME}.nii"
  QSM_OUT="${QSM_NAME}_to_T1W.nii.gz"
  echo "applyxfm: $QSM_IN -> $QSM_OUT using $MAT_OUT"
  flirt -in "$QSM_IN" -ref "$T1W_BRAIN" -out "$QSM_OUT" -applyxfm -init "$MAT_OUT"
done

echo "Finish！"


