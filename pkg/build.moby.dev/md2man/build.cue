package md2man

import (
	"universe.dagger.io/docker"
	"dagger.io/dagger/core"
	"dagger.io/dagger"
)

#Source: {
	repo:     string | *"https://github.com/cpuguy83/go-md2man.git"
	checkout: string | *"v2.0.2"

	_pull: core.#GitPull & {
		remote:     repo
		ref:        checkout
		keepGitDir: false
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
		dest:     "/go/src/github.com/cpuguy83/go-md2man"
	}

	_rootfs: core.#Merge & {
		inputs: [ input.rootfs, _copy.output]
	}

	_input: docker.#Image & {
		rootfs: _rootfs.output
		config: input.config
	}

	_bin: docker.#Run & {
		"input":  _input
		"mounts": cacheMounts
		workdir:  "/go/src/github.com/cpuguy83/go-md2man"
		command: name: "make"
	}

	bin: core.#Copy & {
		input:    dagger.#Scratch
		contents: _bin.output.rootfs
		source:   "/go/src/github.com/cpuguy83/go-md2man/bin/go-md2man"
		dest:     "\(prefix)/bin/"
	}

	_merge: core.#Merge & {
		"inputs": [input.rootfs, bin.output]
	}

	output: docker.#Image & {
		rootfs: _merge.output
		config: input.config
	}
}
