#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from common AOSP config
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

LOCAL_PATH := device/oneplus/instantnoodle

# define hardware platform
PRODUCT_PLATFORM := kona

# A/B support
AB_OTA_UPDATER := true

# A/B updater updatable partitions list. Keep in sync with the partition list
# with "_a" and "_b" variants in the device. Note that the vendor can add more
# more partitions to this list for the bootloader and radio.
AB_OTA_PARTITIONS += \
	boot \
	system \
	system_ext \
	vendor \
	vbmeta \
	dtbo

PRODUCT_PACKAGES += \
	otapreopt_script \
	update_engine \
	update_engine_sideload \
	update_verifier

# A/B
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

# Boot control HAL
PRODUCT_PACKAGES += \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service \
	android.hardware.boot@1.0-impl-wrapper.recovery \
	android.hardware.boot@1.0-impl-wrapper \
	android.hardware.boot@1.0-impl.recovery \
	bootctrl.$(PRODUCT_PLATFORM) \
	bootctrl.$(PRODUCT_PLATFORM).recovery

TW_DEVICE_VERSION := howson-dev

TW_LOAD_VENDOR_MODULES := "touchscreen.ko aw8697.ko adsp_loader_dlkm.ko oplus_chg.ko"

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# fastbootd
PRODUCT_PACKAGES += \
	android.hardware.fastboot@1.0-impl-mock \
	fastbootd \
	resetprop

# qcom decryption
PRODUCT_PACKAGES_ENG += \
	qcom_decrypt \
	qcom_decrypt_fbe

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
	$(LOCAL_PATH)

# tzdata
PRODUCT_PACKAGES_ENG += \
	tzdata_twrp

# Apex libraries
PRODUCT_COPY_FILES += \
	$(OUT_DIR)/target/product/$(PRODUCT_RELEASE_NAME)/obj/SHARED_LIBRARIES/libandroidicu_intermediates/libandroidicu.so:$(TARGET_COPY_OUT_RECOVERY)/root/system/lib64/libandroidicu.so