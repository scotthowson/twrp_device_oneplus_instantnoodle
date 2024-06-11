
# Android Device Tree for OnePlus IN2013 (instantnoodle)

This repository contains the Android device tree for the OnePlus IN2013 (instantnoodle) for building TWRP.

## Getting Started

To get started with building TWRP using AOSP sources, you'll need to be familiar with [Git and Repo](https://source.android.com/source/using-repo.html).

### Initializing the Repository

1. **Initialize your local repository using the AOSP trees to build TWRP**:

    ```sh
    repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11
    ```

2. **Initialize a shallow clone to save space**:

    ```sh
    repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11
    ```

### Creating Local Manifests

1. **Create a directory for local manifests**:

    ```sh
    mkdir -p .repo/localmanifests
    ```

2. **Create and edit the manifest file**:

    ```sh
    cat > .repo/localmanifests/instantnoodle.xml << 'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <manifest>
        <project path="device/oneplus/instantnoodle"
            name="scotthowson/twrp_device_oneplus_instantnoodle"
            remote="github"
            revision="android-10" />
    </manifest>
    EOF
    ```

### Syncing the Repository

To sync the repository, run:

```sh
repo sync
```

**Note**: The device makefile in the device tree and dependencies file should use the "twrp" prefix.

### Building TWRP

Execute the following commands in order to build TWRP:

1. **Set up the build environment**:

    ```sh
    . build/envsetup.sh
    ```

2. **Allow missing dependencies and set locale**:

    ```sh
    export ALLOW_MISSING_DEPENDENCIES=true
    export LC_ALL=C
    ```

3. **Choose the device configuration**:

    ```sh
    lunch twrp_instantnoodle-eng
    ```

4. **Build the recovery image**:

    ```sh
    make -j16 adbd recoveryimage
    ```

### Testing the Build

To test the built recovery image:

1. **Temporarily boot the recovery image**:

    ```sh
    fastboot boot out/target/product/instantnoodle/recovery.img
    ```

2. **Flash the recovery image**:

    ```sh
    fastboot flash recovery recovery.img
    ```