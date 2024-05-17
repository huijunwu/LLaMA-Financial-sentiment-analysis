#!/opt/homebrew/bin/bash -ex

################################
# Read the hostfile
#cat hostfile.txt.h800 > hostfile.txt
readarray -t hosts < hostfile.txt

# The total number of nodes
# how many lines in hostfile.txt
nnodes=${#hosts[@]}

# The address and port of the master node
# the first line in hostfile.txt
master_addr=${hosts[0]}
master_port=6001

################################
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

MICRO_BATCH_SIZE=4 # mod
GLOBAL_BATCH_SIZE=-1 # -1 to calculate automatically.
#MAX_SEQ_LENGTH=4096
MAX_SEQ_LENGTH=1024
TENSOR_TYPE="BFLOAT16" # FLOAT16 or BFLOAT16 or FLOAT32

src_checkpoint_dir="${project_dir}/Llama-2-7b" # 这个就是llama2的folder，这个folder不动，在train之前copy到project folder

project_dir="/home/huijun.wu"
local_data_dir="${project_dir}/dockerdata"
dst_checkpoint_dir="${local_data_dir}/llama2_7b_base"

# 2024Llama!

# The path to the Python script
train_command="train.py --load_ckpt_dir $dst_checkpoint_dir --save_ckpt_dir ${local_data_dir}/rst_checkpoints --tokens_dir ${project_dir}/reuters_tokens --tokenizer_model ${src_checkpoint_dir}/tokenizer.model  --micro_batch_size $MICRO_BATCH_SIZE --global_batch_size $GLOBAL_BATCH_SIZE --max_seq_len $MAX_SEQ_LENGTH --tensor_type $TENSOR_TYPE --warmup_tokens_b 0 --first_cycle_tokens_b 0.018 --max_lr 3e-5 --min_lr 3e-6 --grad_clip 0 --train_sft"

################################
kill_pythons() {
  # Add your cleanup code here
  # For example, you can kill all background jobs:
  # kill $(jobs -p)

  # for ((i=0; i<${nnodes}; i++)); do
  #   host=${hosts[$i]}
  #   ssh ${host} "pkill -f python"
  #   ssh ${host} "pkill -f torchrun"
  #   ssh ${host} "kill -9 `pidof python`"
  #   ssh ${host} "kill -9 `pidof torchrun`"
  # done

  for vm_name in huijun-1 huijun-2
  do
    gcloud compute ssh $vm_name --command "pkill -f python"
    gcloud compute ssh $vm_name --command "pkill -f torchrun"
    gcloud compute ssh $vm_name --command "kill -9 `pidof python`"
    gcloud compute ssh $vm_name --command "kill -9 `pidof torchrun`"
  done
}

trap 'kill_pythons' INT

# kill any existing pythons to prevent OOM.
echo "Killing python processes.."
kill_pythons > /dev/null 2>&1

################################
USERNAME=aaaaaaaaaaaaaaa
YOUR_ACCESS_TOKEN=bbbbbbbbbbbbb

# for vm_name in huijun-1 huijun-2
# do
#   gcloud compute ssh $vm_name --command "sudo apt install -y git-lfs"
#   gcloud compute ssh $vm_name --command "git lfs install"
#   gcloud compute ssh $vm_name --command "GIT_LFS_SKIP_SMUDGE=1 git clone --branch main --single-branch https://${USERNAME}:${YOUR_ACCESS_TOKEN}@huggingface.co/meta-llama/Llama-2-7b"
#   gcloud compute ssh $vm_name --command "git lfs pull"
# done

################################
# The number of processes per node
# use all GPUs
nproc_per_node=auto # mod

# Start the script on each host
echo "starting remote processes.."
for ((i=0; i<${nnodes}; i++)); do
  host=${hosts[$i]}
  echo "Initializing $host"
  # start process
  cmd="rsync -a $src_checkpoint_dir ${local_data_dir}/; cd $project_dir; source env_a800.sh; torchrun --nnodes ${nnodes} --nproc_per_node ${nproc_per_node} --node_rank ${i} --master_addr ${master_addr} --master_port ${master_port} ${train_command}"
  ssh ${host} $cmd &
  #echo $cmd
  #if [ $i -gt 0 ]
  #then
    # echo "Copying $master_addr:$src_dir to $host"
    # rsync -a $src_dir $host:$dst_dir
  #fi
done

wait
