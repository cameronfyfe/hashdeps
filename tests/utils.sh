#! /bin/bash
# Test utilities and common constants.

# The basic make command with any standard arguments.
# For the tests, disable makefiles from printing their working directory as it
# produces too much stdout spam.
# Similarly, make hashdeps itself quiet by default to reduce spam. This can be
# overridden when writing a test by adding `HASHDEPS_QUIET=` to the end of a
# make command.
# Also disable any makeflags in case e.g. tests are being run through make.
export MAKEFLAGS=
export MAKE_CMD="make -f ${PWD}/Makefile --no-print-directory HASHDEPS_QUIET=y"

# The default suffix used for dependency hashes.
export DEFAULT_HASH_FILE_SUFFIX=.dephash
# A simple name to use for a separate directory to store hashes if needed.
export HASH_DIR_NAME=hashes

# Define all the targets and their dependencies in the test makefile.
export TARGET_1_TARGET=output1.tmp
export TARGET_1_DEPENDENCY=source1.tmp
export TARGET_1_HASH_FILE=source1.tmp${DEFAULT_HASH_FILE_SUFFIX}

export TARGET_2_TARGET=output2.tmp
export TARGET_2_DEPENDENCIES=(source1.tmp source2.tmp)

export TARGET_3_TARGET=output3.tmp
export TARGET_3_DEPENDENCIES=("${TARGET_2_DEPENDENCIES[@]}")

export TARGET_4_TARGET=output4.tmp
export TARGET_4_C_FILE=c_source.c
export TARGET_4_H_FILE=c_source.h
export TARGET_4_D_FILE=c_source.d

export TARGET_5_TARGET=output5.tmp
export TARGET_5_C_FILE=c_source_5.c

prepare_and_cd_to_test_temp_dir()
{
    # Run all tests in a tmp dir - shunit2 provides one for us.
    # This way there's no need to clean up at the end because the tmp dir is
    # cleaned up by shunit2 itself.
    cd "${SHUNIT_TMPDIR}" || exit

    # Clean any lingering files from the temp directory before a test starts.
    rm -rf -- ./*
}

# Edit a file's contents so it will require anything depending to be remade.
edit_file_to_force_remake()
{
    local filename=$1
    # Just add a `-` character after every character in the file.
    sed -i 's/./&-/g' "${filename}"
}

# Return success only if there are any hash files in the given directory.
any_hash_files_in_dir()
{
    local dir=$1
    # This finds any hash files and passes them to grep which will return
    # success if there are any files, and failure if there are none.
    find "${dir}" -name "*${DEFAULT_HASH_FILE_SUFFIX}" | grep -q '.'
    return $?
}

# When a file is made, it gains a line of content from each dependency, so use
# that fact to check how many times a file has been made.
assert_file_with_x_deps_made_n_times()
{
    local filename=$1
    local x=$2
    local n=$3
    local num_lines
    num_lines=$(wc -l < "${filename}")
    assertEquals "file doesn't have ${x} deps" "0" "$((num_lines % x))"
    local times_made=$(( num_lines / x ))
    assertEquals "file made wrong number of times" "${n}" "${times_made}"
}
