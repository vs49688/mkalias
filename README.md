# mkalias

Quick'n'dirty tool to make APFS aliases without going via AppleScript.

## Usage
```
mkalias [-v] <source_file> <target_file>
mkalias [-v] [-f bin|hex|base64] <source_file>
```

### Examples
#### Create a new alias
```
mkalias <source_file> <target_file>
```

#### Dump alias data to stdout, in hex
```
mkalias hex <source_file>
```

## License

GPL-2.0-only (https://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html)
