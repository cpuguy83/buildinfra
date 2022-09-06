package deb

import (
	"strings"

	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#Build: {
	data:      #Compressor | dagger.#FS
	control:   #Compressor | dagger.#FS
	postinst?: dagger.#FS

	_merge: core.#Merge & {
		inputs: {
			data.output | data
			control.output | control
		}
	}

	input: docker.#Image

	_run: docker.#Run & {
		"input": input
		workdir: "/tmp/work"
		mounts: {
			"/tmp/work": core.#Mount & {
				contents: _merge.output
				dest:     "/tmp/work"
			}
		}
		command: {
			name: "/bin/sh"
			flags: "-c": "ar r "
		}
	}
}

#Control: {
	name:         string
	version:      string
	architecture: string
	maintainer:   string
	depends: [pkgName=string]: {}
	conflicts?: [pkgName=string]: {}
	suggests?: [pkgName=string]: {}
	replaces?: [pkgName=string]: {}
	section:     string | *"admin"
	priority:    string | *"optional"
	homepage:    string
	description: string

	_write: core.#WriteFile & {
		input:    dagger.#Scratch
		path:     "/control"
		contents: """
            Package: \(name)
            Version: \(version)
            Architecture: \(architecture)
            Maintainer: \(maintainer)
            Depends: \(strings.Join(depends, ", "))
            Conflicts: \(strings.Join(conflicts, ", "))
            Suggests: \(strings.Join(suggests, ", "))
            Replaces: \(strings.Join(replaces, ", "))
            Section: \(section)
            Priority: \(priority)
            Homepage: \(homepage)
            Description: \(description)
        """
	}

	output: _write.output
}
