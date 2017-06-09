PgMex-JDBC Performance Tests
------------
The test suite was developed to compare performance of [**PgMex library**](http://pgmex.alliedtesting.com) and of
**Matlab Database Toolbox** working via a direct JDBC connection.

Currently tests cover performance for different methods of inserting and types of data to be inserted. The results
of experiments obtained through this suite can be seen [here](https://pgagarinov.github.io/pgmex-blog/2017-06-06-performance-comparison-of-postgresql-connectors-in-matlab-part-I/).

Features
------------
The test suite can launch tests for different testing modes and output test results as graphs depicting performance of respective connectors for various data volumes.

This suite is fully configurable through a special xml file that may be easily edited.

Getting started with PgMex-JDBC Performance Tests is super easy! Simply fork this repository and follow the instructions below.


Getting Started with PgMex-JDBC Performance Tests
------------------------------

### Prerequisites

You're going to need:

 - **Matlab, version 2015b or newer** older versions may work, but are unsupported.

You need to have **Matlab Database Toolbox** installed in case you want to test its performance through JDBC (but it is also possible to configure tests
to run only for [**PgMex library**](http://pgmex.alliedtesting.com), in the latter
case **Matlab Database Toolbox** is not required).

 - [**PgMex library**](http://pgmex.alliedtesting.com) - in case its performance is to be investigated
(see details [here](http://pgmex.alliedtesting.com/#installation)).

### Getting Set Up

1. Fork this repository on Github.
2. Clone *your forked repository* (not our original one) to your hard drive with

```shell
git clone https://github.com/YOURUSERNAME/pgmex-jdbc-perf-test.git
```

3. In case you want to run tests for  [**PgMex library**](http://pgmex.alliedtesting.com),
follow [these instructions](http://pgmex.alliedtesting.com/#installation) (it is easier to
unzip the respective archive directly into the directory `pgmex-jdbc-perf-test`, paths to the library
will be added automatically by instructions below).

4. `cd pgmex-jdbc-perf-test`
5. Start Matlab and make sure to run `s_install` script from `install` subfolder. You can do this either manually from Matlab command line or via a shell script for a specific Matlab version in `install` subfolder.

```matlab
# either run this from within Matlab
cd install;
s_install;
```

```shell
# OR run this from shell
cd install
./start_matlab2016b_glnxa64.sh #for windows platform use a bat script
```
Please keep in mind that if you do not use the start script from `install` subfolder to start Matlab you need to make sure that
your "Start in" directory is always `pgmex-jdbc-perf-test/install`. That is because the very first run of `s_install` script
creates `javaclasspath.txt` file with absolute paths to some `jar` files that are a part of
[MatrixBerry-Core library](https://github.com/pgagarinov/mxberry-core) included partially into the given project.
As part of this very first run the jar files are added to *dynamic Java path of Matlab JVM*. All subsequent Matlab runs
with "Start in" directory set to `pgmex-jdbc-perf-test/install` load the created `javaclasspath.txt` file thus adding the jar
files to *static Java path of Matlab JVM*.

Configuring of Tests
-------------------------

Test suite is configured by plain xml files for easier editing and scm system integration. Please note that
configuration files are located computer-specific directories.
Thus there can be multiple instance of configuration `default`, each stored in a folder matching a specific
computer name. Also, apart from computer-specific folders there is a folder that contains
so-called *templates*. Template is a configuration that is then *deployed* to a computer-specific folder and then
modified (if necessary). Such workflow is necessary to avoid conflicts when working with configurations on
different machines when configurations can be edited and then committed to a source control system
by different users.

All in all, if either you do not have yet any configurations or you would like to modify some existing
configuration, you need to execute a special command in Matlab pointing the configuration name like this:

`com.allied.pgmex.perftest.editconf('default')`

In case the configuration 'default' doesn't exist in your computer-specific folder, it is automatically *deployed* by copying the corresponding template configuration 'default' into the mentioned computer-specific subfolder (a user is not required to know where this subfolder is located).
Then the configuration will be opened for editing.

Please note that if you already have configurations created some time ago you can list them using the following command

`com.allied.pgmex.perftest.listconf()`

Once you find your configurations in the list you can edit them via

`com.allied.pgmex.perftest.editconf('youconfname')`

You can also copy existing configurations like this:

`com.allied.pgmex.perftest.copyconf('default','myconf')`

Let us assume that you finally have your configuration created and opened it in Matlab editor through
the command com.allied.pgmex.perftest.editconf. Now it is time to edit this configuration. Below we
describe configuration parameters you may be need to edit.

The main parameter you inevitably have to edit is **connectionString** in **database** section of the configuration. Its value looks like

`host=localhost dbname=postgres port=5432 user=postgres password=mypassword`

You need to adjust this parameter by typing in your own host, database name, port, user name and password.

The only remaining section whose parameters values may be edited is **performanceTestingParams**
(it is better to leave parameters from all other sections intact as those parameters for development
purposes only). The table below contains a description of all these parameters.

Parameter Name                   | Parameter description
---------------------------------|--------------
maxExecTimeInSecs| maximal execution time in seconds for each particular insertion method that limits a total runtime for a method in question; Inf means "no restriction"
pathToSaveTestData|path for storing test experiment results into mat files (later it is possible to display these results by a desired way); if empty, current folder is used
pathToSaveFigures| path for storing figures with graphs depicting results of test experiments; if empty, current folder is used
raiseExceptionIfError| in case of an error during execution for some test raiseExceptionIfError=1 raises an exception thus stopping execution of current test; raiseExceptionIfError=0 displays a warning and tries to continue a test execution
saveFiguresInTests| determines whether figures with graphs with test results are created (if saveFiguresInTests=0, only mat files with results of experiments are created)
singleExpRunFuncName| function name for executing single experiments,this parameter should not be changed
testModeName|can be `jdbc`, `pgmex` or `all`; `jdbc` turns testing only for **Matlab Database Toolbox** working via a direct JDBC connection are tested,  `pgmex` – only for methods of [**PgMex library**](http://pgmex.alliedtesting.com), `all` runs tests for both connectors
samplesMeshModeName| defines an algorithm used for generating a vector with different numbers of test data tuples used in each particular experiment, may be uniform or manual (see their description below)
samplesMeshModeProps| parameters for all modes for generating a vector with different numbers of test data tuples used in each particular experiment (see below their description)
nTrialsPerSample| number of trials for each single experiment to measure time of its execution (the final values are avarages across all trials)

Please take into account that in case `testModeName` equals `jdbc` or `all` you need to have **Matlab Database Toolbox** installed,
while in case `testModeName` equals `pgmex` or `all` you should have a non-trial version of [**PgMex library**](http://pgmex.alliedtesting.com) installed (see [here](http://pgmex.alliedtesting.com/#purchase) for details). Please note that a trial version cannot be used in a combination with this test pack. This is because without a license (or in case the license is not installed correctly) [**PgMex library**](http://pgmex.alliedtesting.com) works in *demo mode* which has a few limitations for an amount of data transferred to DB, a number of fields extracted and a number of sequential calls. These limitations can prevent execution of experiments when the limits are exceeded.

Let us now describe each mode for generation of sample meshes determining volumes of data used in experiments. Each sample is determined by
number of tuples for input test data. Test data values are taken from a special mat file (see the section
"Experiment conditions for comparison between **Matlab Database Toolbox** and [**PgMex**](http://pgmex.alliedtesting.com)"
[here](https://pgagarinov.github.io/pgmex-blog/2017-06-06-performance-comparison-of-postgresql-connectors-in-matlab-part-I/) if you are interested in understanding the nature of this data set). In case a required number of test data tuples exceeds the number of tuples in the
mentioned mat file, this input data is simply replicated as many times as necessary to build a sufficiently large data set.


If `samplesMeshModeName=uniform`, sample mesh is taken to be uniform from minimal to maximal values; in such case the mesh and is fully determined by the following
parameters from `samplesMeshModeProps.uniform` section:

Parameter Name                   | Parameter description
---------------------------------|--------------
minNumOfTuples| minimal number of tuples for input test data, if `minNumOfTuples=NaN`, it is determined automatically as maximal number of tuples divided by number of samples
maxNumOfTuples| maximal number of tuples for input test data, if `maxNumOfTuples=NaN`, it is determined automatically by the number of tuples in the mat file with input data mentioned above
nTuplesSamples| number of samples for different variants of number of tuples used for input test data

If `samplesMeshModeName=manual`, sample mesh is given manually by the following parameter from `samplesMeshModeProps.manual` section:

Parameter Name                   | Parameter description
---------------------------------|--------------
nTuplesVec| vector containing different variants of number of tuples used for input test data

Launching of Tests
-------------------------

In case the configuration name is 'default' you can just run

`runtests('com.allied.pgmex.perftest.TestCompareWithJDBC')`

In case your configuration is named differently, say, 'youconfname', execute first

`com.allied.pgmex.perftest.configuration.ConfStorage.setConfName('youconfname')`

and after that - run

`runtests('com.allied.pgmex.perftest.TestCompareWithJDBC')`


Other Ways to Plot Results
-------------------------

As it was already said in the previous section, results of all tests are saved into mat files. The names of these mat files are determined by the names of the corresponding tests. Each mat file can later be imported in Matlab for closer investigation. The only variable stored in each file is the structure named STestData. Use the following static methods for plotting the corresponding results or saving the respective figures:

`com.allied.pgmex.perftest.TestCompareWithJDBC.plot(STestData)` - to plot the test results in Matlab
`com.allied.pgmex.perftest.TestCompareWithJDBC.saveFigures(STestData)` - to save the figures as graphical images.

These methods have additional properties allowing to configure the way the results are to be displayed. Let us have a closer look at these properties.

Property Name                   | Property description
--------------------------------|--------------
filterFuncNameList| contains a cell array with values from `{'datainsert','fastinsert','batchParamExec'}`, enables displaying results only for methods listed in the cell (but only if are calculated)
selfTimeMode| may be `only`, `on` and `off`, `only` means that only "pure" time used immediately for execution of the corresponding method is displayed, for `on` (default) this "pure" time is displayed along with total time including overhead expenses for data preparation before calling each method, `off` switches off displaying of "pure" time
xLimVec| two-value vector with limits of x-axis, i.e. with minimal and maximal number of tuples to be displayed
yLimVec| two-value vector with limits of y-axis, i.e. with minimal and maximal execution time to be displayed
legendLocation| location of legend, see help of the built-in function `"legend"` for details

Besides, `com.allied.pgmex.perftest.TestCompareWithJDBC.saveFigures` has an additional property named `figureFormatList` with names of formats
used for saving of figures, by default it is just `{'jpeg'}`, but many other formats including 'pdf', 'fig' as well as those
accepted by the built-in `"saveas"` function may be used.

In conclusion let us consider a couple of examples that demonstrate a usage of these properties:

`com.allied.pgmex.perftest.TestCompareWithJDBC.plot(STestData,'selfTimeMode','off','yLimVec',[0 180])` - plot graphs without "pure" time with maximal execution time restricted to 180 seconds

`com.allied.pgmex.perftest.TestCompareWithJDBC.saveFigures(STestData,'figureFormatList',{'jpeg','fig'},'xLimVec',[0 150])` - save figures in jpeg and fig format for graphs with maximal number of tuples equal to 150

Need Help? Found a bug?
--------------------

[Submit an issue](https://github.com/pgagarinov/pgmex-jdbc-perf-test/issues) to the PgMex-JDBC Performance Tests Github if you need any help.
And, of course, feel free to submit pull requests with bug fixes or changes.


Contributors
--------------------

PgMex-JDBC Performance Tests Suite was built by [Peter Gagarinov](https://github.com/pgagarinov)
and [Ilya Rublev](https://github.com/irublev) while working on [**PgMex library**](http://pgmex.alliedtesting.com)
at [Allied Testing Ltd](https://www.alliedtesting.com/).
