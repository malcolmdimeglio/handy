# handy

## Config Parser (configParser.sh)
### Bash version
In Order to use this config parser you will need at least bash version v4
```bash
bash --version
```
```
GNU bash, version 5.0.11(1)-release (x86_64-apple-darwin19.0.0)
Copyright (C) 2019 Free Software Foundation, Inc.
```
### How to use
Simply source this script from your main bash script and give your .INI file as a parameter.
Then you can access its data like you would access an associative array in bash
you can use the .INI file (test.ini) to test it.
```bash
source configParser.sh test.ini

echo ${Settings[LogFile]}
echo ${database[server]}  # Has been overwritten by the second implementation.
echo ${owner[organization]}
echo ${database[test]}
```

```
$ "/opt/ecs/mvuser/MV_IPTel/log/MV_IPTel.log"
$
$ Acme Widgets Inc.
$ 123
```

### You Should Know
If your .INI file contains 2 categories with the same name (like here in test.ini with [database]) your second category will overwrite the first one.

### Regex explenation
```
's/^[[:blank:]]*#.*//g'                       >> Remove '#' lead comments
's/^[[:blank:]]*;.*//g'                       >> Remove ';' lead comments
'/^$/d'                                       >> Remove empty lines
'/^[[:blank:]]*$/d'                           >> Remove seemingly empty lines (tabs and spaces only)
's/[[:blank:]]*=[[:blank:]]*/=/g'             >> Remove blanks surrounding '='
's/^[[:blank:]]*//g'                          >> Remove leading blanks
's/[[:blank:]]*$//g'                          >> Remove trailing blanks
's/\"/\\"/g'                                  >> Escape all existing double quotes
's/(^[^\=]*)(=.*)/\[\1\]\2/g'                 >> Enclose fields with []
's/([^=]=)(.*)/\1\"\2\"/'                     >> Encolose values with double quotes
's/^\[(.*)\]$/); declare -A config\1=(/g'     >> Replace [] segements with declare -A
'/=/!d'                                       >> Delete lines that don't match normal syntax

echo $conf | sed 's/^); //')                  >> Remove the unecessary 1st ';)' character.
                                                 Couldn't make it work within the main command for some reasons
```

## Useful functions (useful_func.sh)
This script has the purpose to provide different kind of useful-ish functions that are not built-in bash.
It is not meant to be sourced or executed in the command prompt. It is meant to be copy pasted at will and adapted to your needs

### 2D-array Associative:Classic
#### Bash version
You need at least bash v4 to use this feature as it uses `declare -A` which is only available from v4 onward

#### What does it do?
It is impossible in bash to create a 2D associative array. However you can create a 1D associative array with `declare -A`
The codded implementation mimics a 2D-like associative array that you can access through variables.

## Colour (colour.sh)
### Bash version
The built-in bash version works fine for this script (v3)

### What does it do?
This script can be sourced. Its only purpose is to facilitate the coloring of outputs with the `echo` command.
It will only create environement variables that you can then use.

Before:
```bash
echo -e "\e[0;31mHello World\e[0m"
```
Will write `Hello World` in Red.

Now:
```bash
source colour.sh

echo -e "${BLUE}Hi There${COLOR_OFF}"
```
Will write `Hi There` in blue. This "new" syntax gives much more clarity to your `echo -e` command

Other colours are available as well as **bold** and *italic* fonts
