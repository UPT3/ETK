echo "Installing, this wil take about 8 minutes."
apt update &> /dev/null
echo "installing 7z"
DEBIAN_FRONTEND=noninteractive apt-get install -qq p7zip-full p7zip-rar &> /dev/null
echo "updating pip"
pip install --upgrade pip &> /dev/null
echo "installing nnsvs main branch"
pip install https://github.com/nnsvs/nnsvs/tarball/master &> /dev/null
echo "installing everything else (this will take a bit...)"
pip install https://github.com/MattShannon/bandmat/archive/master.zip wheel numpy cython==0.29.27 optuna "hydra-core >= 1.1.0, < 1.2.0" "hydra_colorlog >= 1.1.0" hydra-optuna-sweeper mlflow utaupy tqdm pydub pyyaml natsort github-clone tbb gdown torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113 &> /dev/null
echo "Finished"
