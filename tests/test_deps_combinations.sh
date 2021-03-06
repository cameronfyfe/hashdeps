#! /bin/bash
# Tests of multiple dependencies and combinations of dependency types.

. ./utils.sh

# shunit2 function called before each test.
setUp()
{
    prepare_and_cd_to_test_temp_dir

    # Put some initial source files used by rules in place.
    for dep_file in "${TARGET_2_DEPENDENCIES[@]} ${TARGET_3_DEPENDENCIES[@]}"
    do
        echo "example source line" > "${dep_file}"
    done
}

test_touch_means_no_remake_two_deps()
{
    ${MAKE_CMD} ${TARGET_2_TARGET}
    assert_file_with_x_deps_made_n_times ${TARGET_2_TARGET} 2 1

    # Touch the dependencies and re-make the file - it should be unchanged.
    touch "${TARGET_2_DEPENDENCIES[@]}"
    ${MAKE_CMD} ${TARGET_2_TARGET}
    assert_file_with_x_deps_made_n_times ${TARGET_2_TARGET} 2 1
}

test_edit_means_remake_two_deps()
{
    ${MAKE_CMD} ${TARGET_2_TARGET}
    assert_file_with_x_deps_made_n_times ${TARGET_2_TARGET} 2 1

    # Edit a dependency and re-make the file - it should be updated.
    edit_file_to_force_remake "${TARGET_2_DEPENDENCIES[0]}"
    ${MAKE_CMD} ${TARGET_2_TARGET}
    assert_file_with_x_deps_made_n_times ${TARGET_2_TARGET} 2 2
}

# Test a target where only the first dependency is hashed.
test_touch_means_no_remake_mixed_deps()
{
    # Make the file, which will create it with one line.
    ${MAKE_CMD} ${TARGET_3_TARGET}
    assert_file_with_x_deps_made_n_times ${TARGET_3_TARGET} 2 1

    # Touch the hashed dependency and re-make the file - it will be unchanged.
    touch "${TARGET_3_DEPENDENCIES[0]}"
    ${MAKE_CMD} ${TARGET_3_TARGET}
    assert_file_with_x_deps_made_n_times ${TARGET_3_TARGET} 2 1

    # Touch the un-hashed dependency and re-make the file - it will be re-made.
    touch "${TARGET_3_DEPENDENCIES[1]}"
    ${MAKE_CMD} ${TARGET_3_TARGET}
    assert_file_with_x_deps_made_n_times ${TARGET_3_TARGET} 2 2
}

. /usr/bin/shunit2
