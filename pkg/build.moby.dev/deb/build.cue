package deb

import (
	"strings"

	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#Build: {
	data:       dagger.#FS
	control:    #Control | dagger.#FS
	compressor: #Compressor

	_setData: core.#Set & {
		input:  compressor.output.config | compressor.config
		config: core.#ImageConfig & {
			env: {
				input.env
				SOURCE: "/tmp/compress"
				DEST:   "/tmp/data.tar.\(compressor.suffix)"
			}
		}
	}

	_setControl: core.#Set & {
		input:  compressor.output.config | compressor.config
		config: core.#ImageConfig & {
			env: {
				input.env
				SOURCE: "/tmp/compress"
				DEST:   "/tmp/control.tar.\(compressor.suffix)"
			}
		}
	}

	_compressData: docker.#Run & {
		input: docker.#Image & {
			rootfs: compressor.output.rootfs | compressor.rootfs
			config: _setData.output
		}
		mounts: {
			"/tmp/compress": core.#Mount & {
				contents: data
				dest:     "/tmp/compress"
			}
		}
	}

	_compressControl: docker.#Run & {
		input: docker.#Image & {
			rootfs: compressor.output.rootfs | compressor.rootfs
			config: _setControl.output
		}
		mounts: {
			"/tmp/compress": core.#Mount & {
				contents: control
				dest:     "/tmp/compress"
			}
		}
	}

	_compressedData: core.#Subdir & {
		input: _compressData.output
		path:  "/tmp/compress"
	}

	_compressedControl: core.#Subdir & {
		input: _compressControl.output
		path:  "/tmp/compress"
	}

	_merge: core.#Merge & {
		inputs: {
			_compressedData.output
			_compressedControl.output
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
