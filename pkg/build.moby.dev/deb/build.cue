package deb

import (
	"strings"

	"dagger.io/dagger"
	"dagger.io/dagger/core"
)

#Build: {
	data:    #Compressor | dagger.#FS
	control: #Compressor | dagger.#FS

	_merge: core.#Merge & {
		inputs: {
			data.output | data
			control.output | control
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

	core.#WriteFile & {
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
}
