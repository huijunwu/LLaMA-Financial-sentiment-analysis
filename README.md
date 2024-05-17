# First author: Wei Luo(罗威)
# Pre-trained Large Language Models for Financial Sentiment Analysis.
This project contains codes for the research paper title "Pre-trained Large Language Models for Financial Sentiment Analysis". Authors: Wei Luo, Dihong Gong.

## Environment setup
- `hostfile.txt` should contain the IP addresses for distributed training, one line per IP.
- `env_a800.sh` should contain all the additional custom environment variables for running the codes.

## Data preprocessing
- Split the train, val and test sets for the PhraseBank dataset: `process_financial_phrasebank.py`
- The FinBERT webpage is https://github.com/ProsusAI/finBERT/blob/master/README.md.
- The FinancialPhraseBank-v1.0 download webpage is https://www.researchgate.net/publication/251231364_FinancialPhraseBank-v10.

## Training
- May need to tune some parameters accordingly.
- Execute the training script with `./train.sh`

## Testing
- Execute the testing script with `torchrun test.py`

## Results
Methods | Accuracy
--- | ---
LSTM | 0.71
LSTM with ELMo | 0.75
ULMFit | 0.83
LPS | 0.71
HSC | 0.71
FinBERT | 0.86
`Ours (Few-shots)` | `0.68`
`Ours (SFT)` | `0.90`
`Ours (3-class classification)` | `0.90`
