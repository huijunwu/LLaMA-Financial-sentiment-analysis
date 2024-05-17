#!/opt/homebrew/bin/bash -ex


project_dir="/rovin_home/sentiment_analysis"
local_data_dir="/dockerdata"
src_checkpoint_dir="/rovin_home/sentiment_analysis/checkpoints/llama2_7b_base"
dst_checkpoint_dir="$local_data_dir/llama2_7b_base"
# /dockerdata/llama2_7b_base


# upload MacPro laptop to VM
for node in huijun-1 huijun-2
do
  gcloud compute ssh \
    huijun-1 \
    --command "mkdir -p $src_checkpoint_dir && mkdir -p $dst_checkpoint_dir"


  gcloud compute scp \
    * \
    $node:/rovin_home/sentiment_analysis
done

