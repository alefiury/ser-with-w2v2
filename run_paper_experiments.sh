#!/bin/bash
set -x

export LC_NUMERIC="en_US.UTF-8"
export PYTHONHASHSEED=1234

# Parameters:
SEED=$1
seed_mod = "global/seed=${SEED}"

#-----------------------------------------Baseline features-----------------------------------------
#OS-experiment
paiprun configs/main/os-baseline.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/os-baseline/${SEED}" --mods $seed_mod
#Spectrogram-experiment
paiprun configs/main/spectrogram-baseline.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/spectrogram-baseline/${SEED}" --mods $seed_mod

#-----------------------------------------Wav2Vec2-PT-----------------------------------------------
#Local Encoder
paiprun configs/main/w2v2-exps.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/w2v2PT-local" --mods $seeds_mod"&global/wav2vec2_embedding_layer=local_encoder&global/dienen_config=!yaml configs/dienen/mean_mlp.yaml"
#Contextual Encoder
paiprun configs/main/w2v2-exps.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/w2v2PT-contextual" --mods $seeds_mod"&global/wav2vec2_embedding_layer=output&global/dienen_config=!yaml configs/dienen/mean_mlp.yaml"
#All Layers
paiprun configs/main/w2v2-exps.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/w2v2PT-alllayers" --mods $seeds_mod"&global/wav2vec2_embedding_layer=enc_and_transformer"

#-----------------------------------------Wav2Vec2-LS960---------------------------------------------
ls960_mod = "&global/wav2vec2_model_path=~/Models/wav2vec2/wav2vec_small_960h.pt&global/wav2vec2_dict_path=~/Models/wav2vec2"

#Local Encoder
paiprun configs/main/w2v2-exps.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/w2v2LS960-local" --mods $seeds_mod"&global/wav2vec2_embedding_layer=local_encoder&global/dienen_config=!yaml configs/dienen/mean_mlp.yaml"$ls960_mod
#Contextual Encoder
paiprun configs/main/w2v2-exps.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/w2v2LS960-contextual" --mods $seeds_mod"&global/wav2vec2_embedding_layer=output&global/dienen_config=!yaml configs/dienen/mean_mlp.yaml"$ls960_mod
#All Layers
paiprun configs/main/w2v2-exps.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/w2v2LS960-alllayers" --mods $seeds_mod"&global/wav2vec2_embedding_layer=enc_and_transformer"$ls960_mod

#------------------------------------------Ablation--------------------------------------------------
#LSTM
paiprun experiments/configs/main/w2v2-exps.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/w2v2PT-alllayers-lstm" --mods "global/wav2vec2_embedding_layer=enc_and_transformer&global/dienen_config=!yaml configs/dienen/feature_learnable_combination_mean_bilstm.yaml&global/batch_size=16"
#-SpeakerNorm
paiprun experiments/configs/main/w2v2-exps.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/w2v2PT-alllayers-globalnorm" --mods "global/wav2vec2_embedding_layer=enc_and_transformer&global/normalize=global"
#+eGeMAPS
paiprun experiments/configs/main/w2v2-os-exps.yaml --output_path "s3://lpepino-datasets2/is2021_experiments/w2v2PT-alllayers-egemaps" --mods "global/wav2vec2_embedding_layer=enc_and_transformer&global/normalize=global"
