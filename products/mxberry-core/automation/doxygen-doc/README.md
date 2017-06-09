MatrixBerry-Core
------------
library was originally developed as a set of auxilary classes and functions for [Ellipsodal Toolbox for Matlab](https://github.com/SystemAnalysisDpt-CMC-MSU/ellipsoids) project 
back in 2014. Then in 2016 it was decided to separate the library from "Ellipsoidal Toolbox" so that it can be developed as an independent open-source project.

Right from the begining we have been following Test Driven Development (TTD) approach by implementing and extending a test coverage
for most of the library functions. Our ideology is to cover every new feature with meanigful tests and every bug found - with negative tests.

Features
------------
* **Configuration management** - Version-tracked hostname-specific configurations stored as plain xml for easier editing and
scm system integration
* **Containers** 
    - On-disk hash maps in `mxberry.core.cont.ondisk` package. 
    - `mxberry.core.cont.MapExtended` is an extension of built-in `containers.Map` class that supports 
        - conversion to structures
        - union of hash maps
        - deep copies
        - comparison

* **Input parameter parsing functions** `mxberry.core.parseparext` and `mxberry.core.parseparams` and input parameters checking functions in `mxberry.core.check` package
* **OOP helper classes**

    - **for handle classes**  - `mxberry.core.obj.HandleObjectCloner`
class designed as a parent class
for handle objects that require such features as 
         - automatic deep copy
         - comparison, sorting
         - support for `ismember` and `unique` operations
Check out tests in `mxberry.core.obj.test` package for more details

     - **for emulation of static properties** - `mxberry.core.obj.StaticPropStorage` class emulates static properties via persistent variables.
Check out tests in `mxberry.core.obj.test` package for more details

* **ismember and unique functions for arbitrary types** - `mxberry.core` package contains a lot of functions with `ismember*` and `unique*`
name patterns for different types of unique-like and ismember-like operations. 
mxberry.core.ismember and mxberry.core.unique use these operations to implement `ismember`
and `unique` for arbitrary types. 
Check out tests in `mxberry.core.test.IsMemberTC` test case for more details

* **Easier Matlab exceptions handling** - `mxberry.core.MExceptionUtils` class provides methods for converting Matlab exceptions
into plain text and hyper text strings.
* **Useful generic-purpose functions in** `mxberry.core` package, such as 
    - `absrelcompare` for comparing arrays using both relative and absolute tolerances
    - `getcallername` and `getcallernameext` for getting names of callers
    - `throwerror` and `throwwarn` for throwing warnings and exceptions with automatically generated identifiers

* **Helper functions for different built-in types**
    -  `mxberry.core.string` - working with strings
    -  `mxberry.core.struct` - structures
    -  `mxberry.core.cell` - cells

* **Utility functions for working with files and directories** are located in `mxberry.io` package. All these functions are implemented
in Java so they are free of filename and path length limit problems on Windows platforms.

* **Java static path management** - `mxberry.java.AJavaStaticPathMgr` class is designed as extendable abstract class
for much easier management of java static path in Matlab, including an automatic
deployment of 'jar' files. See `mxberry.selfmnt.JavaStaticPathMgr` class for an 
example of AJavaStaticPathMgr abstract methods implementation for a deployment of MatrixBerry Core library.

* **System information** - `mxberry.system` package contains functions for getting 
    - pid of current Matlab process
    - computer name
    - current user name
    - names and parameters of all network interfaces

* **XML serialization and de-serialization of Matlab structures** in `mxberry.xml.xmlformat` package.

Getting started with MatrixBerry-Core is super easy! Simply fork this repository and follow the instructions below. Or, if you'd like to check out what MatrixBerry-Core is capable of, take a look at the [Doxygen documentation](https://pgagarinov.github.io/mxberry-core/).

Getting Started with MatrixBerry-Core
------------------------------

### Prerequisites

You're going to need:

 - **Matlab, version 2015b or newer** — older versions may work, but are unsupported.

### Getting Set Up

1. Fork this repository on Github.
2. Clone *your forked repository* (not our original one) to your hard drive with 

```shell
git clone https://github.com/YOURUSERNAME/mxberry-core.git
```

3. `cd mxberry-core`
4. Start Matlab and make sure to run `s_install` script from `install` subfolder. You can do this either manually from Matlab command line or via a shell script for a specific Matlab version in `install` subfolder.

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
your "Start in" directory is always `mxberry-core/install`. That is because the very first run of `s_install` script creates `javaclasspath.txt` file with absolute paths to some `jar` files that are a part of MatrixBerry-Core library. As part of this very first run the jar files are added to *dynamic Java path of Matlab JVM*. All subsequent Matlab runs with "Start in" directory set to `mxberry-core/install` load the created `javaclasspath.txt` file thus adding the jar files to *static Java path of Matlab JVM*.

Need Help? Found a bug?
--------------------

[Submit an issue](https://github.com/pgagarinov/mxberry-core/issues) to the MatrixBerry-Core Github if you need any help. And, of course, feel free to submit pull requests with bug fixes or changes.


Contributors
--------------------

MatrixBerry-Core was built by [Peter Gagarinov](https://www.linkedin.com/in/pgagarinov) and [Ilya Rublev](http://ait.mtas.ru/en/about/personal/roublev.php) while working on [Ellipsoidal Toolbox for Matlab](http://systemanalysisdpt-cmc-msu.github.io/ellipsoids/) at [Computation Mathematics and Cybernetics Faculty of Lomonosov Moscow State University, System Analysis Department](http://sa.cs.msu.su/).
