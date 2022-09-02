package runc

import (
	"strings"

	"universe.dagger.io/docker"
	"dagger.io/dagger"
	"dagger.io/dagger/core"
)

#Source: {
	repo:     string | *"https://github.com/opencontainers/runc.git"
	checkout: string | *"v1.1.4"

	_pull: core.#GitPull & {
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

	// list of cache mounts to use during build
	// Examples for this might be /go/pkg/mod and /root/.cache/go-build
	// This is provided so callers can manage their own caches if needed.
	//
	// Note that go has issues with caching (or rather invalidating) cgo code.
	// If you build multiple platforms (or different linux distros even), this
	// could cause issues unless you scope the cache id to the platform/distro.
	cacheMounts: _ | *{}

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
		"input":  _input
		"mounts": cacheMounts
		workdir:  "/go/src/github.com/opencontainers/runc"
		env: {
			if tags != _|_ {
				BUILDTAGS: strings.Join(tags, " ")
			}
			if commit != _|_ {
				COMMIT: commit
			}
		}
		command: {
			name: "make"
			args: ["runc"]
		}
	}

	_scripts: core.#Source & {
		path: "./build"
	}

	_man: docker.#Run & {
		"input": _input
		mounts: {
			cacheMounts
			"_scripts": core.#Mount & {
				contents: _scripts.output
				dest:     "/tmp/_internal/scripts/build"
			}
		}
		workdir: "/go/src/github.com/opencontainers/runc"
		command: name: "/tmp/_internal/scripts/build/man.sh"
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
