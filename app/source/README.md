
Disk access was originally in a separated model service.

Disk API
-------- 
- [POST assert(command)](#post-assertcommand)
- [POST assert_all(commands)](#post-assert_allcommands)
- - - -
- [POST run(command)](#post-runcommand)
- [POST run_all](#post-run_allcommands)
- [POST run_until_false](#post-run_until_falsecommands)
- [POST run_until_true](#post-run_until_truecommands)


- - - -
## POST assert(command)
Runs a single [command](#command).  
- result 
  - When it succeeds, the single result of the `command`.
  - When it fails, raises `ServiceError`.
- example
  ```bash
  $ DIRNAME=/cyber-dojo/katas/12/34/56
  $ curl \
    --data '{"command":["dir_make","${DIRNAME}"]}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      http://${DOMAIN}:${PORT}/assert
  ```
  ```bash
  {"assert":true}
  ```

- - - -
## POST run(command)
Runs a single [command](#command).  
- result 
  - The single result of the `command`.
- example
  ```bash
  $ DIRNAME=/cyber-dojo/katas/34/E3/R6
  $ curl \
    --data '{"command":["dir_make","${DIRNAME}"]}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      http://${DOMAIN}:${PORT}/run
  ```
  ```bash
  {"run":true}
  ```

- - - -
## POST assert_all(commands)
Runs all [commands](#commands).  
- result 
  - When they all succeed, the `commands` results in an array.  
  - When one of them fails, immediately raises `ServiceError`.  
- example
  ```bash
  $ DIRNAME=/cyber-dojo/groups/45/Pe/6N
  $ curl \
    --data '{"commands":[["dir_make","${DIRNAME}"],["dir_exists?","${DIRNAME}"]]}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      http://${DOMAIN}:${PORT}/assert_all
  ```
  ```bash
  {"assert_all":[true,true]}
  ```

- - - -
## POST run_all(commands)
Runs all [commands](#commands).
- result 
  - The `commands` results, in an array.
- example
  ```bash
  $ DIRNAME=/cyber-dojo/groups/2P/45/6E
  $ curl \
    --data '{"commands":[["dir_make","${DIRNAME}"],["dir_make","${DIRNAME}"]]}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --fail POST \
      http://${DOMAIN}:${PORT}/run_all
  ```
  ```bash
  {"run_all":[true,false]}
  ```

- - - -
## POST run_until_true(commands)
Runs [commands](#commands) until one is **true**.  
- result 
  - The `commands` results (including the last **true** one) in an array.
- example
  ```bash
  $ DIRNAME=/cyber-dojo/groups/12/5Q/6E
  $ curl \
    --data '{"commands":[["dir_exists?","${DIRNAME}"],["dir_make","${DIRNAME}"]]}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      http://${DOMAIN}:${PORT}/run_until_true
  ```
  ```bash
  {"run_until_true":[false,true]}
  ```

- - - -
## POST run_until_false(commands)
Runs [commands](#commands) until one is **false**.
- result 
  - The `commands` results (including the last **false** one) in an array.
- example
  ```bash
  $ DIRNAME=/cyber-dojo/groups/1q/K4/d9
  $ curl \
    --data '{"commands":[["dir_make","${DIRNAME}"],["dir_make","${DIRNAME}"]]}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      http://${DOMAIN}:${PORT}/run_until_false
  ```
  ```bash
  {"run_until_false":[true,false]}
  ```

- - - -
## commands
An array of commands.

## command
There are 5 commands:
  * [dir_make_command](#dir_make_command)
  * [dir_exists_command](#dir_exists_command)
  * [file_create_command](#file_create_command)
  * [file_append_command](#file_append_command)
  * [file_read_command](#file_read_command)

They can all be used in the 6 methods `assert`, `run`, `assert_all`, `run_all`, `run_until_true`, `run_until_false`.   
The 2 methods `assert` and `assert_all` raise instead of returning **false**.  
The 6 methods _always_ raise when
  * there is no space left on the file-system.  
  * `command` or `commands` is malformed (eg unknown, incorrect arity, not a String)

- - - -
### dir_make_command
A command to create a dir.  
An array of two elements `[ "dir_make", "${DIRNAME}" ]`  
Corresponds to the `bash` command `mkdir -p ${DIRNAME}`.
- example
  ```json
  [ "dir_make", "/cyber-dojo/katas/4R/5S/w4" ]
  ```
- result
  * **true** when the `dir_make` succeeds.
  * **false** when the `dir_make` fails.
    - when **DIRNAME** already exists as a dir.
    - when **DIRNAME** already exists as a file.

- - - -
### dir_exists_command
A query to determine if a dir exists.  
An array of two elements `[ "dir_exists?", "${DIRNAME}" ]`  
Corresponds to the `bash` command `[ -d ${DIRNAME} ]`.    
- example
  ```json
  [ "dir_exists?", "/cyber-dojo/katas/4R/5S/w4" ]
  ```
- result
  * **true** when **DIRNAME** exists.
  * **false** when **DIRNAME** does not exist.

- - - -
### file_create_command
A command to create a _new_ file.  
An array of three elements `[ "file_create", "${FILENAME}", "${CONTENT}" ]`  
Creates a _new_ file called **FILENAME** with content **CONTENT** in an _existing_ dir (created with a `dir_make_command`).
- example
  ```json
  [ "file_create", "/cyber-dojo/katas/4R/5S/w4/manifest.json", "{...}" ]
  ```
- result
  * **true** when the file creation succeeds.
  * **false** when the file creation fails.
    - when **FILENAME** already exists.
    - when **FILENAME** exists as a dir.

- - - -
### file_append_command
A command to append to an _existing_ file.  
An array of three elements `[ "file_create", "${FILENAME}","${CONTENT}" ]`  
Appends **CONTENT** to an _existing_ file called **FILENAME** (created with a `file_create_command`)
- example
  ```json
  [ "file_append", "/cyber-dojo/katas/4R/5S/w4/manifest.json", "{...}" ]  
  ```
- result
  * **true** when the file append succeeds.
  * **false** when the file append fails.
    - when **FILENAME** does not exist.
    - when **FILENAME** exists as a dir.

- - - -
### file_read_command
A command to read from an _existing_ file.  
An array of two elements `[ "file_read", "${FILENAME}" ]`  
Reads the contents of an _existing_ file called **FILENAME**.
- example
  ```json
  [ "file_read", "/cyber-dojo/katas/4R/5S/w4/manifest.json" ]
  ```
- result
  * the contents of the file when the read succeeds.
  * **false** when the file read fails.
    - when **FILENAME** does not exist.
    - when **FILENAME** exists as a dir.
