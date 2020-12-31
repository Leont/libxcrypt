#! /bin/sh
set -e

if [ "$PERFORM_COVERITY_SCAN" = 1 ] || [ "$DISTCHECK" = 1 ]; then
  exit 0
fi

GCOV=gcov

if [ "$TRAVIS_OS_NAME" = osx ]; then
  case "$CC" in
    gcc*)
      GCC_VER="$( (brew list --versions gcc || echo gcc 0) |
                  sed 's/^gcc \([0-9]*\)\..*$/\1/' )"
      if command -V "gcov-$GCC_VER"; then
        GCOV="gcov-$GCC_VER"
      fi
    ;;
  esac

elif [ "$TRAVIS_OS_NAME" = linux ]; then
  if [ "$CC" = clang ]; then
    GCOV="$PWD/.clang_gcov_wrapper.sh"
  fi

fi
export GCOV

# Log the identities and versions of the coverage tools.
for tool in "$GCOV" lcov codecov
do
    # $tool might include mandatory command-line arguments.
    # Interpret it the same way Make would.
    set fnord $tool
    shift
    if command -V $1; then
        echo + "$@" --version
        "$@" --version
    fi
    echo
done
set fnord; shift  # clear $@

set -x
lcov --gcov-tool $GCOV --directory . --capture --output-file all_coverage.info
lcov --gcov-tool $GCOV --remove all_coverage.info \
     '/usr/*' '*test*' > coverage.info
rm all_coverage.info
codecov -X gcov
