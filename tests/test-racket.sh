#start container and get id
id=$(podman run -v $PWD/harebrained:/harebrained:z -tid racket/racket:8.2-full bash)
#execute commands to install r6rs library
#podman exec -ti ${id} plt-r6rs --install /harebrained/intervals.scm
podman exec -ti ${id} plt-r6rs --install /harebrained/tests/runner.scm
podman exec -ti ${id} plt-r6rs --install /harebrained/bio/private/types.scm
podman exec -ti ${id} plt-r6rs --install /harebrained/bio/collections.scm
podman exec -ti ${id} plt-r6rs --install /harebrained/bio/sequences.scm
podman exec -ti ${id} plt-r6rs --install /harebrained/bio/read/private/utilities.scm
podman exec -ti ${id} plt-r6rs --install /harebrained/bio/read/fasta.scm
#execute test script
podman exec -ti ${id} plt-r6rs /harebrained/tests/sequences.scm
podman exec -ti ${id} plt-r6rs /harebrained/tests/collections.scm
#stop container
podman stop ${id}
