package deb

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
	"universe.dagger.io/alpha/debian/apt"
)

#Compressor: {
	output: docker.#Image
	suffix: string
}

#Xz: {
	suffix: "xz"
	ref:    core.#Ref | *"buildpack-deps:jammy"
	_pull:  docker.#Pull & {
		source: ref
	}

	_set: core.#Set & {
		input:  _pull.output.config
		config: core.#ImageConfig & {
			entrypoint: ["/bin/sh", "-c"]
			cmd: ["tar -C ${SOURCE} --xz -cf ${DEST} ."]
		}
	}

	output: docker.#Image & {
		rootfs: _pull.output.rootfs
		config: _set.output
	}
}

#Gzip: {
	suffix: "gz"
	ref:    core.#Ref | *"buildpack-deps:jammy"
	_pull:  docker.#Pull & {
		source: ref
	}

	_set: core.#Set & {
		input:  _pull.output.config
		config: core.#ImageConfig & {
			entrypoint: ["/bin/sh", "-c"]
			cmd: ["tar -C ${SOURCE} -z -cf ${DEST} ."]
		}
	}

	output: docker.#Image & {
		rootfs: _pull.output.rootfs
		config: _set.output
	}
}

#Zstd: {
	suffix: "zst"
	ref:    core.#Ref | *"buildpack-deps:jammy"
	_pull:  docker.#Pull & {
		source: ref
	}

	_install: apt.#Install & {
		input: _pull.output
		packages: zstd: _
	}

	_set: core.#Set & {
		input:  _pull.output.config
		config: core.#ImageConfig & {
			entrypoint: ["/bin/sh", "-c"]
			cmd: ["tar -C ${SOURCE} --zstd -cf ${DEST} ."]
		}
	}

	output: docker.#Image & {
		rootfs: _install.output.rootfs
		config: _set.output
	}
}
