PIPELINE_CONFIG_PATH=/workdir/models/research/configs/ssd320_bench.config
CKPT_DIR=${1:-"/results/SSD320_FP16_1GPU"}
GPUS=1

export TF_ENABLE_AUTO_MIXED_PRECISION=1

TENSOR_OPS=0
export TF_ENABLE_CUBLAS_TENSOR_OP_MATH_FP32=${TENSOR_OPS}
export TF_ENABLE_CUDNN_TENSOR_OP_MATH_FP32=${TENSOR_OPS}
export TF_ENABLE_CUDNN_RNN_TENSOR_OP_MATH_FP32=${TENSOR_OPS}

echo -n "Single GPU mixed precision training performance: " && \
python -u /workdir/models/research/object_detection/model_main.py \
       --pipeline_config_path=${PIPELINE_CONFIG_PATH} \
       --model_dir=${CKPT_DIR} \
       --alsologtostder \
        "${@:2}" 2>&1 | awk -v GPUS=$GPUS '/global_step\/sec/{ array[num++]=$2 } END { for (x = 3*num/4; x < num; ++x) { sum += array[x] }; print GPUS*32*4*sum/num " img/s"}'