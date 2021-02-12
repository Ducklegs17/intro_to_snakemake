README

There are 4 branches in this repository.

### Main 
The main branch includes a very simple workflow that processes a single sample and is entirely hardcoded.

### add_quast
This branch adds the QUAST rule to the end of the workflow.

### generalise
This branch generalises the workflow to process two samples. Note that the first rule, 'get_data' is not generalised and doesn't represent good practice. This is rectified in the 'other_features' branch.

### other_features
This branch has all rules generalised and also includes examples of a number of different snakemake features including logging, specifying threads, passing resource requirements to the cluster-configs/default.yaml file, and benchmarking.

# Instructions for installing Anaconda3 and Snakemake on Phoenix 

```
#load Anaconda3 on Phoenix
module load Anaconda3/2020.07

#If this fails, enter 'module spider Anaconda3/2020.07' and follow the instructions before retrying.

# Integrate conda into bash
conda init bash

#If you don’t have permission for below step, just close and reopen your shell session
source ${HOME}/.bashrc

# Change the default location into which conda saves packages and environments
conda config --prepend pkgs_dirs ${HOME}/.conda/pkgs
conda config --prepend envs_dirs ${HOME}/.conda/envs

# Change the default channels used for finding software and resolving dependencies
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

# Install snakemake using conda
# This might take 5-10mins
# Probably best to find the most recent version of snakemake and use that
conda create --name snakemake --yes snakemake=${SNAKEMAKE_VERSION:-5.5.4}

# Activate the conda environment
conda activate snakemake
complete -o bashdefault -C snakemake-bash-completion snakemake

#Test to see if it worked
snakemake --version

#Clone the git repository
git clone https://github.com/Ducklegs17/intro_to_snakemake.git

```

# Changing account details to match your own

Enter `rcquota` into phoenix and you should get something like the following:

```
===========================================================================
Compute Usage: System = hpc1, Period = 2021.q1 [ 47.2% lapsed]
---------------------------------------------------------------------------
System         Project               Grant_SU       Usage_SU     Grant Use%
hpc1           biohub                   50000          64154        128.31%
                 a123456                +-->             13          0.03%
===========================================================================
```


Note the word located above your a-number. In my case it is 'biohub'. This is the account that your phoenix usage is charged to. 
cd into the repository and edit `cluster-configs/phoenix.yaml` so that the word biohub is changed to whatever your account name is. 

# Running a snakemake workflow
It is best to run Snakemake in a screen

```
#Create a new screen with a name of your choice
screen -S nameofyourchoice

#Load anaconda3 from phoenix
#Note that the version below may not be the most recent. 
#Feel free to use `module spider anaconda` to find the most recent version.
module load Anaconda3/2020.07

#Activate the snakemake conda environment that you made earlier
conda activate snakemake

#If you are running singularity/using docker images
module load Singularity

#To perform a dryrun of your workflow (see which rules will be run)
snakemake --dryrun

#To generate a DAG showing visual file dependencies in a PDF
snakemake --dag | dot -Tpdf > outputdag.pdf

#To generate a rulegraph showing visual rule dependencies in a PDF
snakemake --rulegraph | dot -Tpdf > outputrulegraph.pdf

#To run the workflow using the targets specified in 'rule all'
snakemake --profile profiles/slurm --use-conda

#If some rules contain docker images, use
snakemake --profile profiles/slurm --use-conda --use-singularity

#To request a specific target file
snakemake --profile profiles/slurm --use-conda requested/file/name.txt

#To detatch from your screen press 'Ctrl+a' and then press 'd'. This doesn't delete the screen.
#It will keep running on Phoenix but will be disconnected from your local computer.

#To reattach the screen
screen -r nameofyourchoice

#To checkout a different branch
git checkout branchname
```
