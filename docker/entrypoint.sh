#!/usr/bin/env bash

source /entry/colors.sh

msgerr

s-build() {
    # if (( $# > 0 )) && [[ "$1" == "clean" ]]; then
    #     msgerr bold cyan " >>> Running 'make clean'\n"
    #     make clean
    #     return $?
    # fi
    msgerr bold cyan " >>> Running 'make'\n"
    (( $# > 0 )) && msgerr bold yellow " [...] Extra make arguments: $* \n"
    make "${@:2}"
}

s-help() {
    msgerr green "Docker Entrypoint\n\n"
    msgerr bold green "Commands:\n"
    msgerr bold cyan "    build|rebuild|make [args...]"
    msgerr cyan "          Run 'make', passing any additional arguments directly to make\n"

    msgerr bold cyan "    clean|reset|purge [args...]"
    msgerr cyan "          Run 'make clean', passing any additional arguments directly to 'make clean'\n"

    msgerr bold cyan "    tar|output|dump [tar_out=/dev/stdout] [tar_src=output/]"
    msgerr cyan "          Tar's the folder 'output/' into stdout, or a different output/src if user specifies additional args.\n"
}

if (( $# < 1 )); then
    s-help
    exit 1 
fi

case "$1" in
    build|rebuild|make)
        s-build "${@:2}"
        ;;
    clean|reset|purge)
        s-build clean "${@:2}"
        ;;
    tar|output|dump|save|extract)
        msgerr bold cyan " >>> Tarring 'output' folder\n"
        tar_dest="-"
        tar_src="output/"
        if (( $# > 1 )); then
            msgerr bold yellow " [...] Additional argument passed. Tarring to '$2' instead of stdout\n"
            tar_dest="$2"
        else
            msgerr bold yellow " [...] Outputting TAR to stdout!\n"
        fi
        if (( $# > 2 )); then
            msgerr bold yellow " [...] 3rd argument detected. Tarring folder '$3' instead of ${tar_src}\n"
            tar_src="$3"
        fi
        tar cf "$tar_dest" "$tar_src"
        ;;
    bash|shell|sh)
        bash "${@:2}"
        ;;
    help|'-h'|'--help'|'-?'|'/?')
        s-help
        ;;
    *)
        s-help
        exit 1
        ;;
esac