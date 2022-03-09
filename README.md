# StringsTool

This tool can check for multiple kinds of faults in strings files

## How to

This is a swift command line tool built with swift package manager, you can clone and built it yourself

Steps:
- Clone
- Build release with command `swift build --configuration release`
- Edit paths in `run.sh` to point to your directories
- `./run.sh`

It comes with some help doc
```
➜  StringsTool .build/release/StringsTool 
Error: Missing expected argument '<dir>'

USAGE: strings-tool <dir> <name> [--check-missing-key]

ARGUMENTS:
  <dir>                   Path that contains the .lproj directory
  <name>                  Strings file name

OPTIONS:
  --check-missing-key
  -h, --help              Show help information.
```

Example usage:

`.build/release/StringsTool /Users/jimmyli/sources/c2iphone/Apps/Consumer/Resources Localizable.strings`

## What errors are checked

### NoStringsFileError

If {file}.strings is missing in any subdirectory

### DuplicatedKeyError

If the same keys are found in one strings file.

### MissingKeyError

If a key that is presented in any other language is missing.

Checking this error is disabled by default.

This is assuming every language should have every string translated, and do not use fallback. However, if we are ok to use fallback translation, we should disable this check

## Demo Results

- Without checking missing keys: [console output](https://drive.google.com/file/d/14Il5ZnPNonA8_kAD1Lk7b1PPL8gCccbE/view?usp=sharing)
- With checking missing keys: [console output](https://drive.google.com/file/d/1PzH0nv21-Zbe7gUEN_2XBJsndCWenpAM/view?usp=sharing)
