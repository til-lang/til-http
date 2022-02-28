# til-http

## Build

1. You can clone Til lang repository inside this repository root, in
   a directory named `til/`, or symlink it from somewhere else.
1. `make`

## Usage

```tcl
set url "http://example.org"
http.get $url | as content
print $content
```
