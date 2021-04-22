#!/bin/bash
set -x

export LC_NUMERIC="en_US.UTF-8"
export PYTHONHASHSEED=1234

# Parameters:
SEED=$1
OUTPUT_PATH=$2
seed_mod="global/seed=${SEED}"

#-----------------------------------------Baseline features-----------------------------------------
#OS-experiment
errors=1
while (($errors!=0)); do
paiprun configs/main/os-baseline.yaml --output_path "${OUTPUT_PATH}/os-baseline/${SEED}" --mods $seed_mod
errors=$?; done
#Spectrogram-experiment
errors=1
while (($errors!=0)); do
paiprun configs/main/spectrogram-baseline.yaml --output_path "${OUTPUT_PATH}/spectrogram-baseline/${SEED}" --mods $seed_mod
errors=$?; done
#-----------------------------------------Wav2Vec2-PT-----------------------------------------------
#Local Encoder
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-exps.yaml --output_path "${OUTPUT_PATH}/w2v2PT-local/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=local_encoder&global/dienen_config=!yaml configs/dienen/mean_mlp.yaml"
errors=$?; done
#Contextual Encoder
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-exps.yaml --output_path "${OUTPUT_PATH}/w2v2PT-contextual/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=output&global/dienen_config=!yaml configs/dienen/mean_mlp.yaml"
errors=$?; done
#All Layers
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-exps.yaml --output_path "${OUTPUT_PATH}/w2v2PT-alllayers/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=enc_and_transformer"
errors=$?; done
#-----------------------------------------Wav2Vec2-LS960---------------------------------------------
ls960_mod="&global/wav2vec2_model_path=~/Models/wav2vec2/wav2vec_small_960h.pt&global/wav2vec2_dict_path=~/Models/wav2vec2"
#Local Encoder
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-exps.yaml --output_path "${OUTPUT_PATH}/w2v2LS960-local/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=local_encoder&global/dienen_config=!yaml configs/dienen/mean_mlp.yaml$ls960_mod"
errors=$?; done
#Contextual Encoder
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-exps.yaml --output_path "${OUTPUT_PATH}/w2v2LS960-contextual/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=output&global/dienen_config=!yaml configs/dienen/mean_mlp.yaml$ls960_mod"
errors=$?; done
#All Layers
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-exps.yaml --output_path "${OUTPUT_PATH}/w2v2LS960-alllayers/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=enc_and_transformer$ls960_mod"
errors=$?; done

#------------------------------------------Ablation--------------------------------------------------
#LSTM
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-exps.yaml --output_path "${OUTPUT_PATH}/w2v2PT-alllayers-lstm/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=enc_and_transformer&global/dienen_config=!yaml configs/dienen/feature_learnable_combination_mean_bilstm.yaml&global/batch_size=16"
errors=$?; done
#-SpeakerNorm
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-exps.yaml --output_path "${OUTPUT_PATH}/w2v2PT-alllayers-globalnorm/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=enc_and_transformer&global/normalize=global"
errors=$?; done
#+eGeMAPS
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-os-exps.yaml --output_path "${OUTPUT_PATH}/w2v2PT-alllayers-egemaps/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=enc_and_transformer&global/normalize=global"
errors=$?; done

#---------------------------------------SOA Paper Setting---------------------------------------------
#Ravdess
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-soapaper-config.yaml --output_path "${OUTPUT_PATH}/soapaper-ravdess/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=enc_and_transformer&global/normalize=global&global/dataset=ravdess"
errors=$?; done
#IEMOCAP
errors=1
while (($errors!=0)); do
paiprun configs/main/w2v2-soapaper-config.yaml --output_path "${OUTPUT_PATH}/soapaper-iemocap/${SEED}" --mods "${seed_mod}&global/wav2vec2_embedding_layer=enc_and_transformer&global/normalize=global&global/dataset=iemocap_impro"
errors=$?; done
