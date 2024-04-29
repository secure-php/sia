# SymPHP
SymPHP is a concolic execution engine for PHP-based web applications, leveraging the idea of Symbolic Interpreter Analysis (SIA).
It symbolically analyzes the language interpreter to (indirectly) analyze the web application code.
To perceive web application execution state, we modified [PHP interpreter](https://github.com/php/php-src) to expose WebPC.
We also enhanced [S2E](https://github.com/S2E/s2e) to symbolically analyze the language interpreter with WebPC based state scheduling.
SymPHP has been tested on Ubuntu 22.04.
More technical details can be found in our SP24 paper.

```tex
@inproceedings{li2024symphp,
    title       = {Holistic Concolic Execution for Dynamic Web Applications via Symbolic Interpreter Analysis},
    author      = {Li, Penghui and Meng, Wei and Zhang, Mingxue and Wang, Chenlin and Luo, Changhua},
    booktitle   = {Proceedings of the 45h IEEE Symposium on Security and Privacy (S&P)},
    month       = may,
    year        = 2024
}
```

## Installation
### Build S2E

SymPHP generally follows the [standard instructions](https://s2e.systems/docs/s2e-env.html#id2) for building S2E.
Below are some key steps.

```sh
# install the dependencies in https://github.com/secureweb/s2e/blob/master/Dockerfile

# use s2e-env
cd $SYMPHP/s2e-env
python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip
pip install .

# build S2E
cd $SYMPHP/s2e-env/s2e
source s2e_activate 
s2e build

# build an ubuntu-22.04-x86_64 VM image for running PHP interpreter in
s2e image_build ubuntu-22.04-x86_64
```

### Build PHP Interpreter

```sh
cd $SYMPHP/php-src
./buildconf --force 

# this builds the PHP binaries sapi/cli/php and sapi/cgi/php-cgi
# one can enable other optional configurations, e.g., --with-mysql
# https://www.php.net/manual/en/configure.about.php
EXTRA_INCLUDES="-I ../s2e-env/s2e/source/s2e/guest/common/include" ./configure
make
```

### Build Bug Checker
S2E can capture several types of errors during the analysis.
Following the idea of Fault Escalation (Trickel et al. 2023), SymPHP issues a segfault for syntax parsing errors in sinks.
It is worth noting that directly signaling SIGSEGV would not work due to the ways S2E captures errors.
Therefore, we insert the following code snippet to intentionally trigger segfault on syntax parsing errors.
We modified the [dash](https://github.com/nyuichi/dash) for command injection vulnerabilities.

```c
// https://stackoverflow.com/a/2045478/10498659
*(int*)0 = 0;
```

Build dash:

```sh
cd $SYMPHP/dash
sh autogen.sh
./configure
make
```

## Use
We illustrate the use cases of SymPHP using an example.
The following PHP code snippet would trigger a segfault on the modified dash at the else branch.

```php
# $SYMPHP/s2e-env/s2e/projects/test_files/test.php
<?php
if(isset($_GET['var1'])) {
    $var1 = $_GET['var1'];
	if($var1 == '2022'){
		echo "branch one \n";
	}
	elseif($var1 . "o" == "hello") {
		echo "branch two \n";
		
		// trigger segfault acccording to Fault Escalation
		system('ls ('); 
	}
}
```

### Start a S2E Project
Create a new project for the binary php-cgi.
```sh
cd $SYMPHP/s2e-env 
. venv/bin/activate
cd $SYMPHP/s2e-env/s2e
source s2e_activate

s2e new_project -i ubuntu-22.04-x86_64 $SYMPHP/php-src/sapi/cgi/php-cgi
cd projects/php-cgi
```
### Config S2E Project
In s2e-config.lua, InterpreterMonitor plugin should be enabled; WEBPC should be enabled for CUPASearcher.
A reference configuration file (with hardcoded paths) can be found in test_files/s2e-config.lua.
TestCaseGenerator plugin should be set to generate test cases on segfaults.

```lua
add_plugin("InterpreterMonitor")

add_plugin("CUPASearcher")
pluginsConfig.CUPASearcher = {
    -- The order of classes is important, please refer to the plugin
    -- source code and documentation for details on how CUPA works.
    classes = {
        -- This ensures that states run for a certain amount of time.
        -- Otherwise too frequent state switching may decrease performance.
        "batch",
	    
        -- include WEBPC as CUPA Searcher
        "WEBPC", 

        "pc",
    },
}

add_plugin("TestCaseGenerator")
pluginsConfig.TestCaseGenerator = {
    generateOnStateKill = true,
    generateOnSegfault = true
}

```

### Run
Copy other required files, including modified dash.

```sh
# copy necessary binaries
cp $SYMPHP/dash/src/dash dash
cp $SYMPHP/s2e-env/s2e/projects/test_files/invokephp.sh .
cp $SYMPHP/s2e-env/s2e/projects/test_files/test.php .
cp $SYMPHP/s2e-env/s2e/projects/test_files/bootstrap.sh .
```

Start the analysis.

```sh
GUI=1 ./launch-s2e.sh
```

More details can be found in test_files/bootstrap.sh

```sh
${S2ECMD} get "invokephp.sh"
${S2ECMD} get "test.php"
${S2ECMD} get "dash"
sudo chmod a+x dash php-cgi

#sudo systemctl stop mysql
sudo cp dash /usr/bin/dash
sh invokephp.sh
```

### Check Results
When a segmentation fault is triggered, the TestCaseGenerator plugin of S2E would generate a test case automatically.
For example, in s2e-last/debug.txt.

```txt
15 [State 2] TestCaseGenerator: generating test case at address 0xffffffff8104bd6b
15 [State 2] LinuxMonitor: Terminating state: received segfault
15 [State 2] Terminating state: Segfault
15 [State 2] TestCaseGenerator: generating test case at address 0xffffffff8104bd6b
15 [State 2] TestCaseGenerator:       v0__SYM_var1_0 = {0x68, 0x65, 0x6c, 0x6c}; (int32_t) 1819043176, (string) "hell"
```
## Others 
We explain how we modified the PHP interpreter [here](php-enhance.md).
We hope these could help interested readers to extend the idea of SIA to other languages.

Please open an issue if you have questions or encounter bugs.

## License
SymPHP is under Apache-2.0 license.
SymPHP uses various libraries that may have their own licenses.
Please refer to the LICENSE file in each directory or to the header of each source file.
