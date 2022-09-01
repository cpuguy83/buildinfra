package runc

import (
	"strings"

	"universe.dagger.io/git"
	"universe.dagger.io/docker"
	"dagger.io/dagger"
	"dagger.io/dagger/core"
)

#Source: {
	repo:     string | *"https://github.com/opencontainers/runc.git"
	checkout: string | *"v1.1.4"

	_pull: git.#Pull & {
		remote:     repo
		ref:        checkout
		keepGitDir: true
	}
	output: _pull.output
}

#Build: {
	input: docker.#Image
	// src is the runc source directory
	src: dagger.#FS | #Source

	// prefix is the path tree where the output is written to
	// e.g. /usr will have files in /usr/bin, /usr/share, etc.
	prefix: string | *"usr/local"

	// tags are any custom build tags to set when building the runc binary
	tags?: [string]

	// Customize the commit hash that is embedded in the runc binary
	// This is useful when the runc source is not from a git repo (e.g. no .git dir).
	commit?: string

	_mounts: {
		gomod: core.#Mount & {
			type:     "cache"
			contents: core.#CacheDir & {
				id: "gomod"
			}
			dest: "/go/pkg/mod"
		}
		gobuild: core.#Mount & {
			type:     "cache"
			contents: core.#CacheDir & {
				id: "gobuild"
			}
			dest: "/root/.cache/gobuild"
		}
	}

	_copy: core.#Copy & {
		input:    dagger.#Scratch
		contents: src | src.output
		dest:     "/go/src/github.com/opencontainers/runc"
	}

	_rootfs: core.#Merge & {
		inputs: [input | input.rootfs, _copy.output]
	}

	_input: docker.#Image & {
		rootfs: _rootfs.output
		config: input.config
	}

	_bin: docker.#Run & {
		"input": _input
		mounts:  _mounts
		workdir: "/go/src/github.com/opencontainers/runc"
		env: {
			if tags != _|_ {
				BUILDTAGS: strings.Join(tags, " ")
			}
			if commit != _|_ {
				COMMIT: commit
			}
		}
		command: {
			name: "/bin/sh"
			flags: "-c": "make runc"
		}
	}

	_scripts: core.#Source & {
		path: "./build"
	}

	_man: docker.#Run & {
		"input": _input
		mounts: {
			_mounts
			mansh: core.#Mount & {
				contents: _scripts.output
				dest:     "/tmp/build"
			}
		}
		workdir: "/go/src/github.com/opencontainers/runc"
		command: name: "/tmp/build/man.sh"
	}

	bin: core.#Copy & {
		input:    dagger.#Scratch
		contents: _bin.output.rootfs
		source:   "/go/src/github.com/opencontainers/runc/runc"
		dest:     "\(prefix)/bin/"
	}

	man: core.#Copy & {
		input:    dagger.#Scratch
		contents: _man.output.rootfs
		source:   "/go/src/github.com/opencontainers/runc/man/"
		dest:     "\(prefix)/share/man/"
	}

	completion: core.#Copy & {
		input:    dagger.#Scratch
		contents: src | src.output
		source:   "/contrib/completions/bash/"
		dest:     "\(prefix)/share/bash-completion/completions/"
	}

	_merge: core.#Merge & {
		inputs: [bin.output, man.output, completion.output]
	}

	output: _merge.output
}
