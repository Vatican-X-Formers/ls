#!/usr/bin/env bash

lr=2.5e-4
warmup=10000
iters=430000
csize=32
crank=1
bsize=1
memlen=2048
tps=2048
wlen=512

wd=0.01
dp=0.2

update_freq=4

task=enwik8

expname=${task}-base-phase1

export OMP_NUM_THREADS=1

# It is important to set --num-workers to larger values for the speed on text8.
# A good practice is to set it to (num_cpu_cores / num_gpus)
# Note: we need 8 V100 GPUs with 32GB memory
fairseq-train \
    datasets/${task}/data-bin/ \
    --user-dir ./model_lib \
    --task truncated_bptt_lm --arch transformer-ls \
    --n-layer 12 --d-model 512 --n-head 8 --d-inner 2048 --dropout ${dp} --emb-dropout ${dp} \
    --tokens-per-sample ${tps} --mem-len ${memlen} --window-len ${wlen} \
    --keep-last-epochs 1 --validate-interval-updates 1000 \
    --optimizer adam --weight-decay ${wd} \
    --lr-scheduler fixed --warmup-updates ${warmup}  --max-update ${iters} --batch-size-valid 32 \
    --lr ${lr}  --batch-size ${bsize} \
    --save-dir ./chks/${expname} \
    --chunk-size ${csize} --chunk-rank ${crank} \
    --update-freq ${update_freq} \
    --criterion char_level_lm_loss  --pre-ln --use-gelu \
    --num-workers 0 \
    --seed 2  --log-interval 25 \

