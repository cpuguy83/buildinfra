package deb

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
	"dagger.io/dagger"
)

#Compressor: {
	contents: dagger.#FS
	output:   dagger.#FS
}

#Xz: {
	input:    docker.#Image
	contents: dagger.#FS
	name:     string | *"contents.tar.xz"

	_source: "/tmp/compress"
	_dest:   "/tmp/xzout"

	_run: docker.#Run & {
		"input": input
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
	input:    docker.#Image
	contents: dagger.#FS
	name:     string | *"contents.tar.gz"

	_source: "/tmp/compress"
	_dest:   "/tmp/gzipout"

	_run: docker.#Run & {
		"input": input
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
	input:    docker.#Image
	contents: dagger.#FS
	name:     string | *"contents.tar.zst"

	_source: "/tmp/compress"
	_dest:   "/tmp/zstout"

	_run: docker.#Run & {
		"input": input
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
