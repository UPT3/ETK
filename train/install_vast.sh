# for use on VAST with python:3.8-buster image.
echo "Installing, this wil take about 8 minutes."
apt-get update &> /dev/null
echo "installing 7z"
apt-get install -qq p7zip-full libsndfile1 &> /dev/null
echo "updating pip"
pip install --upgrade pip &> /dev/null
echo "installing nnsvs main branch"
pip install -I https://github.com/nnsvs/nnsvs/tarball/master &> /dev/null
echo "installing everything else (this will take a bit...)"
pip install -I https://github.com/MattShannon/bandmat/archive/master.zip wheel numpy cython==0.29.27 optuna "hydra-core >= 1.1.0, < 1.2.0" "hydra_colorlog >= 1.1.0" hydra-optuna-sweeper wheel matplotlib mlflow utaupy tqdm pydub pyyaml natsort github-clone tbb gdown "protobuf<3.20,>=3.9.2" setuptools torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu116 &> /dev/null
echo "Finished"
