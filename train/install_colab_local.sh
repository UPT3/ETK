echo "Installing, this will take about 5.5 minutes."
sudo apt-get update
echo "installing 7z"
sudo apt-get install -qq p7zip-full p7zip-rar
#echo "updating pip"
pip install --upgrade pip &> /dev/null
#echo "installing PyTorch"
#pip install -I torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116
#echo "installing nnsvs main branch"
#pip install https://github.com/nnsvs/nnsvs/tarball/master &> /dev/null
echo "installing nnsvs 0.0.3"
pip install nnsvs &> /dev/null

echo "installing everything else (this will take a bit...)"
pip install --no-cache-dir -U https://github.com/MattShannon/bandmat/archive/master.zip git+https://github.com/r9y9/ParallelWaveGAN@nnsvs wheel optuna "hydra-core >= 1.1.0, < 1.2.0" "hydra_colorlog >= 1.1.0" hydra-optuna-sweeper mlflow numpy scipy utaupy tqdm pydub pyyaml natsort github-clone tbb gdown "joblib" "tensorboard<2.9,>=2.8" "typing-extensions<4.2.0,>=3.7.4" "protobuf<3.20,>=3.9.2" "cython==0.29.27" "setuptools<60" &> /dev/null
echo "Finished"
