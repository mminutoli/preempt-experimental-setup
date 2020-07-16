Experimental Setup for PREEMPT
==============================

This repository contains the automation that was built as part of the PREEMPT
experimental setup.  The repository is organized as follow:

- :code:`plots` : Contains scripts and the data collected during our runs. Once
  the experimental setup is configured and built, the plots included in the
  paper are generated in the directories under :code:`build/plots`.
- :code:`portland-dataset` : A contact network for the city of Portland.
- :code:`experiments`: The batch script generator to reproduce our experimental
  setup. Module dependencies are documented inside the Jinja2 templates used to
  generate the scripts.


Building Ripples on Summit
--------------------------

Get the source code:

.. code-block:: shell

   $ git clone https://github.com/pnnl/ripples.git


Prepare the build environment:

.. code-block:: shell

   $ pip install --user pipenv
   $ cd ripples
   $ pipenv --three
   $ pipenv install
   $ pipenv shell


Create a conan profile:

.. code-block:: shell

   (ripples) $ conan profile new default --detect
   (ripples) $ conan profile update settings.compiler.libcxx=libstdc++11 default
   (ripples) $ conan profile update env.CC=$(which gcc) default
   (ripples) $ conan profile update env.CXX=$(which g++) default


Install dependencies (including what is not on bintray):

.. code-block:: shell

   (ripples) $ conan create conan/waf-generator user/stable
   (ripples) $ conan create conan/trng user/stable
   (ripples) $ conan install . --build fmt


Build ripples:

.. code-block:: shell

   (ripples) $ ./waf configure --enable-mpi --enable-cuda build_release


The rest of the instructions will refer to the directory where ripples was built
as :code:`$RIPPLES_DIR`.


Getting the input data
----------------------

Data sets from the `Stanford Large Network Dataset Collection
<http://snap.stanford.edu/data/index.html>`_:

- `HepPh <http://snap.stanford.edu/data/cit-HepPh.txt.gz>`_
- `Slashdot <http://snap.stanford.edu/data/soc-Slashdot0811.txt.gz>`_
- `Epinions <http://snap.stanford.edu/data/soc-Epinions1.txt.gz>`_
- `DBLP
  <http://snap.stanford.edu/data/bigdata/communities/com-dblp.ungraph.txt.gz>`_
- `Google <http://snap.stanford.edu/data/web-Google.txt.gz>`_
- `BerkStan <http://snap.stanford.edu/data/web-BerkStan.txt.gz>`_
- `LiveJournal
  <http://snap.stanford.edu/data/bigdata/communities/com-lj.ungraph.txt.gz>`_
- `Orkut
  <http://snap.stanford.edu/data/bigdata/communities/com-orkut.ungraph.txt.gz>`_

Preparing the data in binary format
-----------------------------------

Once you have downloaded and decompressed the input files, you need to convert
them into the ripples binary format. We considered all the graphs as undirected
to be consistent with contact networks.

Binary versions of the input can be created using the :code:`dump-graph` tool
distributed with Ripples:

.. code-block:: shell

   $ $RIPPLES_DIR/build/release/tools/dump-graph -i <graph_file> -u -d IC --dump-binary -o <graph_file>.IC.bin

Store all the generated binary in the same directory. In the rest of this guide,
we will refer to the directory containing the binaries as :code:`$INPUTS_DIR`.


Reassembling the Portland dataset
---------------------------------

The Portland data set is stored under :code:`portland-dataset`. To reassemble
and produce the needed binary file used the following commands:

.. code-block:: shell

   $ cd $RIPPLES_DIR/protland-dataset
   $ cat portland_weights.tar.xz.parta* > portland_weights.tar.xz 
   $ tar xJf portland_weights.tar.xz
   $ RIPPLES_DIR/build/release/tools/dump-graph -i portland_weights.txt -u -w -d IC --dump-binary -o portland_weights.txt.IC.bin

Move the binary file in your :code:`$INPUTS_DIR`.


Configuring and building the experimental setup
-----------------------------------------------

This experimental setup was designed for Summit at the Oak Ridge Leadership
Computing Facility. Details on the machine can be found `here
<https://www.olcf.ornl.gov/olcf-resources/compute-systems/summit/>`_.

Ripples documents software dependencies using conan. The configuration used to
run the experiments on Summit is available in this repository in the Jinja2
templates used to generate the batch scripts.

The experimental setup includes:

- Generators for the jobs to be submitted to summit.
- The data produced during our runs.
- R scripts to generate the scaling plots in the paper.

Get the experimental setup source code:

.. code-block:: shell

   $ git clone https://github.com/mminutoli/preempt-experimental-setup.git


Prepare the build environment:

.. code-block:: shell

   $ pip install --user pipenv
   $ cd preempt-experimental-setup
   $ pipenv --three
   $ pipenv install
   $ pipenv shell

Configure and build the experimental setup:

.. code-block:: shell

   (preempt-experimental-setup) $ mkdir $HOME/preempt-results
   (preempt-experimental-setup) $ ./waf configure --ripples-dir=$RIPPLES_DIR/build/release/tools --inputs-dir=$INPUTS_DIR --results-dir=$RESULTS_DIR
   (preempt-experimental-setup) $ ./waf build -j 1

The scripts for job submission can be found under :code:`build/experiments`. The
logs produced by their execution will be stored under :code:`$RESULTS_DIR`. You
need to be sure that :code:`$RESULTS_DIR` can be written by the compute nodes.


The plots in the paper will be generated under :code:`build/plots`.

Important Note
**************

Not provding the path to the directory storing the binaries during the configure
step will avoid building the scripts.

If the machine where you are building the experimental setup does not have an R
installation, the experimental setup won't compile our plots. If you decide to
install R, beaware that our R scripts will install the missing packages.
Therefore:

- Don't remove :code:`-j1` the first time you run the build command.
- Once you started the build process, go grab a book and your favorite
  caffeinated beverage: it will take a while.


Submitting Jobs on Summit
=========================

Once you have generated the scripts, you will be able to find them under the
build:

- Hill Climbing: :code:`build/experiments/hill-climbing`
- IMM: :code:`build/experiments/imm`

Jobs can be submitted on the machine with:

.. code-block:: shell

   $ bsub -P <ACCOUNT> <path-to-script>


Each job will produce an execution log in the form of a JSON file in the
:code:`$RESULT_DIR`. The :code:`plots` directory contains all the needed scripts
to generate the scaling plots and tasking related analysis.

For any further information please refer to the `Summit User Guide
<https://docs.olcf.ornl.gov/systems/summit_user_guide.html>`_.

   
Contacts
========

- `Marco Mintutoli <marco.minutoli@pnnl.gov>`_
- `Mahantesh Halappanavar <mahantesh.halappanavar@pnnl.gov>`_
- `Ananth Kalyanaraman <ananth@wsu.edu>`_

Disclamer Notice
================

This material was prepared as an account of work sponsored by an agency of the
United States Government.  Neither the United States Government nor the United
States Department of Energy, nor Battelle, nor any of their employees, nor any
jurisdiction or organization that has cooperated in the development of these
materials, makes any warranty, express or implied, or assumes any legal
liability or responsibility for the accuracy, completeness, or usefulness or any
information, apparatus, product, software, or process disclosed, or represents
that its use would not infringe privately owned rights.

Reference herein to any specific commercial product, process, or service by
trade name, trademark, manufacturer, or otherwise does not necessarily
constitute or imply its endorsement, recommendation, or favoring by the United
States Government or any agency thereof, or Battelle Memorial Institute. The
views and opinions of authors expressed herein do not necessarily state or
reflect those of the United States Government or any agency thereof.

.. raw:: html

   <div align=center>
   <pre style="align-text:center">
   PACIFIC NORTHWEST NATIONAL LABORATORY
   operated by
   BATTELLE
   for the
   UNITED STATES DEPARTMENT OF ENERGY
   under Contract DE-AC05-76RL01830
   </pre>
   </div>
