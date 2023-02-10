#postfilter step for NNSVS 0.1.0

if [[ -z ${trajectory_smoothing+x} ]]; then
    trajectory_smoothing=false
    trajectory_smoothing_cutoff=50
fi

mkdir -p $expdir/acoustic/norm/
python $NNSVS_COMMON_ROOT/extract_static_scaler.py \
    $dump_norm_dir/out_acoustic_scaler.joblib \
    $expdir/acoustic/model.yaml \
    $dump_norm_dir/out_acoustic_static_scaler.joblib

for s in ${datasets[@]};
do
    if [ ! -e $expdir/acoustic/${acoustic_eval_checkpoint} ]; then
        echo "ERROR: acoustic model checkpoint $expdir/acoustic/${acoustic_eval_checkpoint} does not exist."
        echo "You must train the acoustic model before training a post-filter."
        exit 1
    fi

    # Input
    xrun nnsvs-gen-static-features \
        model.checkpoint=$expdir/acoustic/${acoustic_eval_checkpoint} \
        model.model_yaml=$expdir/acoustic/model.yaml \
        out_scaler_path=$dump_norm_dir/out_acoustic_scaler.joblib \
        in_dir=$dump_norm_dir/$s/in_acoustic/ \
        gt_dir=$dump_norm_dir/$s/out_acoustic/ \
        out_dir=$expdir/acoustic/org/$s/in_postfilter \
        utt_list=data/list/$s.list normalize=false gta=true mgc2sp=true \
        gv_postfilter=true

    if [ -d conf/prepare_static_features ]; then
        ext="--config-dir conf/prepare_static_features"
    else
        ext=""
    fi

done

# apply normalization for input and output features
scaler_path=$dump_norm_dir/out_postfilter_scaler.joblib

for s in ${datasets[@]}; do
    xrun nnsvs-preprocess-normalize in_dir=$expdir/acoustic/org/$s/in_postfilter \
        scaler_path=$scaler_path \
        out_dir=$expdir/acoustic/norm/$s/in_postfilter
done

# for convenience
cp -v $scaler_path $expdir/acoustic/norm/in_postfilter_scaler.joblib
