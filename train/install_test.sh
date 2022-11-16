echo "Installing, this will take about 5.5 minutes."
apt-get update &> /dev/null
echo "installing 7z"
apt-get install -qq p7zip-full p7zip-rar &> /dev/null
#echo "updating pip"
pip install --upgrade pip &> /dev/null
#echo "installing PyTorch"
#pip install -I torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116
echo "installing nnsvs main branch"
pip install https://github.com/nnsvs/nnsvs/tarball/master &> /dev/null
echo "installing everything else (this will take a bit...)"
pip install --no-cache-dir -U https://github.com/MattShannon/bandmat/archive/master.zip git+https://github.com/r9y9/ParallelWaveGAN@nnsvs wheel numpy==1.21.6 optuna "hydra-core >= 1.1.0, < 1.2.0" "hydra_colorlog >= 1.1.0" hydra-optuna-sweeper mlflow utaupy tqdm pydub pyyaml natsort github-clone tbb gdown joblib "tensorboard<2.9,>=2.8" "typing-extensions<4.2.0,>=3.7.4" "protobuf<3.20,>=3.9.2" "cython==0.29.27" "setuptools<60" praat-parselmouth &> /dev/null
echo "Finished"