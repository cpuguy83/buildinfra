package deb

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
	"universe.dagger.io/alpha/debian/apt"
	"dagger.io/dagger"
)

#Compressor: {
	contents: dagger.#FS
	output:   dagger.#FS
}

#Xz: {
	ref:      core.#Ref | *"buildpack-deps:jammy"
	contents: dagger.#FS
	name:     string | *"contents.tar.xz"

	_pull: docker.#Pull & {
		source: ref
	}

	_source: "/tmp/compress"
	_dest:   "/tmp/xzout"

	_run: docker.#Run & {
		input: _pull.output
		mounts: {
			"\(_source)": core.#Mount & {
				"contents": contents
				dest:       _source
			}
		}
		workdir: _dest
		command: {
			"name": "/bin/sh"
			flags: "-c": "tar -C \(_source) --xz -cf \(_dest)/\(name) ."
		}
		export: directories: "\(_dest)": _
	}

	output: _run.export.directories[_dest]
}

#Gzip: {
	ref:      core.#Ref | *"buildpack-deps:jammy"
	contents: dagger.#FS
	name:     string | *"contents.tar.gz"

	_pull: docker.#Pull & {
		source: ref
	}

	_source: "/tmp/compress"
	_dest:   "/tmp/gzipout"

	_run: docker.#Run & {
		input: _pull.output
		mounts: {
			"\(_source)": core.#Mount & {
				"contents": contents
				dest:       _source
			}
		}
		workdir: _dest
		command: {
			"name": "/bin/sh"
			flags: "-c": "tar -C \(_source) -czf \(_dest)/\(name) ."
		}
		export: directories: "\(_dest)": _
	}

	output: _run.export.directories[_dest]
}

#Zstd: {
	ref:      core.#Ref | *"buildpack-deps:jammy"
	contents: dagger.#FS
	name:     string | *"contents.tar.zst"

	_pull: docker.#Pull & {
		source: ref
	}

	_source: "/tmp/compress"
	_dest:   "/tmp/zstout"

	_install: apt.#Install & {
		input: _pull.output
		packages: "zstd": _
		// TODO: we need a cache prefix for this
	}

	_run: docker.#Run & {
		input: _install.output
		mounts: {
			"\(_source)": core.#Mount & {
				"contents": contents
				dest:       _source
			}
		}
		workdir: _dest
		command: {
			"name": "/bin/sh"
			flags: "-c": "tar -C \(_source) --zstd -cf \(_dest)/\(name) ."
		}
		export: directories: "\(_dest)": _
	}

	output: _run.export.directories[_dest]
}
