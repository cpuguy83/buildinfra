package targets

import (
	"universe.dagger.io/docker"
)

#_RpmBase: {
	input:  docker.#Image
	prefix: string

	docker.#Run & {
		"input": input
		command: {
			name: "yum"
			args: ["install", "-y", "make", "gcc", "libseccomp-devel"]
		}
	}
}
