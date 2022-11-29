set -e
set -u
set -o pipefail

function xrun () {
    set -x
    $@
    set +x
}

CONFIG_PATH="config.yaml"

script_dir=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
NNSVS_COMMON_ROOT="scripts"
. "$NNSVS_COMMON_ROOT/yaml_parser.sh" || exit 1;

eval $(parse_yaml $CONFIG_PATH "")

train_set="train_no_dev"
dev_set="dev"
eval_set="eval"
datasets=($train_set $dev_set $eval_set)
testsets=($dev_set $eval_set)

dumpdir=dump
dump_org_dir="$dumpdir/$spk/org"
dump_norm_dir="$dumpdir/$spk/norm"

stage=0
stop_stage=-1

. $NNSVS_COMMON_ROOT/parse_options.sh || exit 1;


if [ -z ${tag:=} ]; then
    expname="${spk}"
else
    expname="${spk}_${tag}"
fi
expdir="exp/$expname"


# Prepare files in singing-database for training
if [ ${stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
    echo ""
    echo "###"
    echo "stage 0: Data preparation"
    echo "###"
    echo ""
    rm -rf $out_dir
    rm -f preprocess_data.py.log
    python preprocess_data.py $CONFIG_PATH || exit 1;
fi

if [ ${stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
    echo ""
    echo "###"
    echo "stage 1: Feature generation#"
    echo "###"
    echo ""
    rm -rf $dumpdir
    . $NNSVS_COMMON_ROOT/new/feature_generation.sh || exit 1;
fi

if [ ${stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
    echo ""
    echo "###"
    echo "stage 2: Time-lag model training"
    echo "###"
    echo ""
    . $NNSVS_COMMON_ROOT/train_timelag.sh || exit 1;
fi

if [ ${stage} -le 3 ] && [ ${stop_stage} -ge 3 ]; then
    echo ""
    echo "###"
    echo "stage 3: Duration model training"
    echo "###"
    echo ""
    . $NNSVS_COMMON_ROOT/train_duration.sh || exit 1;
fi

if [ ${stage} -le 4 ] && [ ${stop_stage} -ge 4 ]; then
    echo ""
    echo "###"
    echo "stage 4: Training acoustic model"
    echo "###"
    echo ""
    . $NNSVS_COMMON_ROOT/new/train_acoustic.sh || exit 1;
fi

# Postfilter stuff
if [ ${stage} -le 5 ] && [ ${stop_stage} -ge 5 ]; then
    echo "stage 6: Prepare input/output features for post-filter"
    . $NNSVS_COMMON_ROOT/new/prepare_postfilter.sh
fi

if [ ${stage} -le 6 ] && [ ${stop_stage} -ge 6 ]; then
    echo "stage 7: Training post-filter"
    . $NNSVS_COMMON_ROOT/new/train_postfilter.sh
fi

# Vocoder stuff
#if [ ${stage} -le 8 ] && [ ${stop_stage} -ge 8 ]; then
#    echo "stage 8: Prepare vocoder input/output features"
#    . $NNSVS_COMMON_ROOT/prepare_voc_features.sh
#fi

#if [ ${stage} -le 9 ] && [ ${stop_stage} -ge 9 ]; then
#    echo "stage 9: Compute statistics of vocoder's input features"
#
#    if [[ ${acoustic_features} == *"static_deltadelta_sinevib"* ]]; then
#        ext="--num_windows 3 --vibrato_mode sine"
#    elif [[ ${acoustic_features} == *"static_deltadelta_diffvib"* ]]; then
#        ext="--num_windows 3 --vibrato_mode diff"
#    elif [[ ${acoustic_features} == *"static_only_sinevib"* ]]; then
#        ext="--num_windows 1 --vibrato_mode sine"
#    elif [[ ${acoustic_features} == *"static_only_diffvib"* ]]; then
#        ext="--num_windows 1 --vibrato_mode diff"
#    elif [[ ${acoustic_features} == *"static_deltadelta"* ]]; then
#        ext="--num_windows 3 --vibrato_mode none"
#    elif [[ ${acoustic_features} == *"static_only"* ]]; then
#        ext="--num_windows 1 --vibrato_mode none"
#    else
#        ext=""
#    fi
#
#    xrun python $NNSVS_COMMON_ROOT/scaler_joblib2npy_voc.py \
#        $dump_norm_dir/out_acoustic_scaler.joblib $dump_norm_dir/ \
#        --sample_rate $sample_rate $ext
#fi

#if [ ${stage} -le 10 ] && [ ${stop_stage} -ge 10 ]; then
#    echo "stage 10: Training vocoder using parallel_wavegan"
#    if [ ! -z ${pretrained_vocoder_checkpoint} ]; then
#        extra_args="--resume $pretrained_vocoder_checkpoint"
#    else
#        extra_args=""
#    fi
#    # NOTE: copy normalization stats to expdir for convenience
#    mkdir -p $expdir/$vocoder_model
#    cp -v $dump_norm_dir/in_vocoder*.npy $expdir/$vocoder_model
#    xrun parallel-wavegan-train --config conf/parallel_wavegan/${vocoder_model}.yaml \
#        --train-dumpdir $dump_norm_dir/$train_set/in_vocoder \
#        --dev-dumpdir $dump_norm_dir/$dev_set/in_vocoder/ \
#        --outdir $expdir/$vocoder_model $extra_args
#fi

#if [ ${stage} -le 11 ] && [ ${stop_stage} -ge 11 ]; then
#    echo "stage 11: Synthesis waveforms by parallel_wavegan"
#    if [ -z "${vocoder_eval_checkpoint}" ]; then
#        vocoder_eval_checkpoint="$(ls -dt "${expdir}/${vocoder_model}"/*.pkl | head -1 || true)"
#    fi
#    outdir="${expdir}/$vocoder_model/wav/$(basename "${vocoder_eval_checkpoint}" .pkl)"
#    for s in ${testsets[@]}; do
#        xrun parallel-wavegan-decode --dumpdir $dump_norm_dir/$s/in_vocoder \
#            --checkpoint $vocoder_eval_checkpoint \
#            --outdir $outdir
#    done
#fi

#Pack it up
if [ ${stage} -le 12 ] && [ ${stop_stage} -ge 12 ]; then
    echo "#  stage 12: Release preparation          #"
    python prepare_release.py $CONFIG_PATH || exit 1;
fi
