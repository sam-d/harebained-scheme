#regenerate the graph of all record types
dot -Tpng doc/graph/record_hierarchy.dot > doc/graph/record_hierarchy.png
#generate documentation
podman run --rm -v $PWD:/harebrained -it racket/racket:8.5-full scribble --htmls --dest /harebrained/doc /harebrained/harebrained-scheme.scrbl
