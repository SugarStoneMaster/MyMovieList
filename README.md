<p align="center">
     <img width="150" src="https://github.com/SugarStoneMaster/MyMovieList/assets/58223071/9ce5f855-2f55-4dea-b6b1-24911ce02a71" alt="CineList logo">
</p>

<p align="center">
     <b>CineList</b><br>
 Are you a movie enthusiast looking to keep track of the films you've watched or plan to watch? Look no further! 🎥 🥳
</p>

<p align="center">
<a href="#"><img src="https://img.shields.io/github/contributors/SugarStoneMaster/MyMovieList?style=for-the-badge" alt="Contributors"/></a>
<img src="https://img.shields.io/github/last-commit/SugarStoneMaster/MyMovieList?style=for-the-badge" alt="last commit">
</p>
<p align="center">
<a href="#"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen?style=for-the-badge" alt="PRs Welcome"/></a>
<a href="#"><img src="https://img.shields.io/badge/languages-Swift, Python-blue?style=for-the-badge" alt="Python"/></a>
</p>

<br>

# Table of Contents

1. [Introduction](#introduction)
2. [Documentation](#documentation)
3. [Installation Guide](#installation-guide)
   - [Installing Python](#installing-python)
   - [Cloning the Repository](#cloning-the-repository)
   - [Creating the Virtual Environment](#creating-the-virtual-environment)
   - [Installing Requirements](#installing-requirements)
   - [Dataset Download & Database Configuration](#dataset-download-&-database-configuration)
4. [How to Run](#how-to-run)

# Introduction

Are you a movie enthusiast looking to keep track of the films you've watched or plan to watch? Look no further! **CineList** is your ultimate companion for organizing your cinematic journey. 

**Features:**

- **Watchlist Management:** Easily add movies to your "Watched" or "Want to Watch" lists.
- **Movie Ratings:** Rate the movies you've seen and share your opinions.
- **Discover New Films:** Get recommendations based on your watchlist and ratings.



<div align="center">
<video src="https://github.com/SugarStoneMaster/MyMovieList/assets/58223071/d9088b89-de37-4ac0-bb80-7ac67e7c3a94" controls></video>
</div>


# Documentation

Documentation regarding the engineering process can be found in the `deliverables` folder. 

# Installation Guide
To install the necessary requirements for the project, please follow the steps below.

## Installing Python
Verify you have Python installed on your machine. The project is compatible with Python `3.10.1`.

If you do not have Python installed, please refer to the official [Python Guide](https://www.python.org/downloads/).

## Cloning the Repository 
To clone this repository, download and extract the `.zip` project files using the `<Code>` button on the top-right or run the following command in your terminal:
```shell 
git clone https://github.com/SugarStoneMaster/MyMovieList.git
```

## Creating the Virtual Environment 
It's strongly recommended to create a virtual environment for the project and activate it before proceeding. 
Feel free to use any Python package manager to create the virtual environment. However, for a smooth installation of the requirements we recommend you use `pip`. Please refer to [Creating a virtual environment](https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/#creating-a-virtual-environment).

You may skip this step, but please keep in mind that doing so could potentially lead to conflicts if you have other projects on your machine. 
## Installing Requirements
To install the requirements, please: 
1. Make sure you have **activated the virtual environment where you installed the project's requirements**. If activated, your terminal, assuming you are using **bash**, should look like the following: ``(name-of-your-virtual-environment) user@user path``

2. Install the project requirements using `pip`:
```shell 
pip install -r requirements.txt
```

## Dataset Download & Database Configuration 

Download the [!dataset](https://www.kaggle.com/datasets/alanvourch/tmdb-movies-daily-updates) and follow the instructions to install and configure ![MongoDB](https://www.mongodb.com/). 

# How to Run 

After downloading, move the dataset to the desired location on your machine. Run the `main.py` script to prepare and load the dataset into your database. 
After that, you can start you application by running the script located at `backend/app.py`. 
