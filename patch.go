//go:build ignore
// +build ignore

package main

import (
	"bytes"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
)

// function to patch qmake and QtCore
func main() {
	//this is a path to the /Applications directory where there is a hidden directory .env_darwin_amd64
	//which is a symbolic link to vendor/github.com/therecipe/env_darwin_amd64_602
	//under the program directory after running go mod vendor
	pPath := filepath.Join("/Applications", ".env_darwin_amd64", "5.13.0", "clang_64")
	if len(os.Args) >= 2 {
		pPath = os.Args[1]
	}
	//looking for version 5.13.0 and concatenating the path with
	if !strings.Contains(pPath, "5.13.0") {
		pPath = filepath.Join(pPath, "5.13.0", "clang_64")
	}

	// for loop based on the two below strings
	for _, fn := range []string{"lib/QtCore.framework/Versions/5/QtCore", "bin/qmake"} {

		fn = filepath.Join("./5.13.0/clang_64/", fn)
		//I'm looking for
		//5.13.0/clang_64/lib/QtCore.framework/Versions/5 and the filename QtCore
		//and
		//5.13.0/clang_64/bin/ and the filename qmake

		data, err := ioutil.ReadFile(fn)
		if err != nil {
			println("couldn't find", fn)
			continue
		}

		for _, path := range []string{"qt_prfxpath", "qt_epfxpath", "qt_hpfxpath"} {
			path += "="

			start := bytes.Index(data, []byte(path))
			if start == -1 {
				continue
			}

			end := bytes.IndexByte(data[start:], byte(0))
			if end == -1 {
				continue
			}

			rep := append([]byte(path), []byte(pPath)...)
			if lendiff := end - len(rep); lendiff < 0 {
				end -= lendiff
			} else {
				rep = append(rep, bytes.Repeat([]byte{0}, lendiff)...)
			}
			data = bytes.Replace(data, data[start:start+end], rep, -1)
		}

		if err := ioutil.WriteFile(fn, data, 0644); err != nil {
			println("couldn't patch", fn)
		} else {
			println("patched", fn)
		}
	}
}
