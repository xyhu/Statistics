## Udacity MLND Capstone

This repo contains the code for the Udacity MLND Capstone.
* `requirements.txt` contains the packages required by the code.
* `data_exploration.py` contains the code doing data exploration and visualization
* `implementation.py` contains the model selection, training and prediction code
* `conf.py` contains the file path that stores the data and save files. Remember to change it.

To run the model selection process with 100 covariates, run the following in the command line
```
python implementation.py build 100 &
```

To run the prediction process with 100 covariates, run the following in the command line
```
python implementation.py predict 100 &
```
