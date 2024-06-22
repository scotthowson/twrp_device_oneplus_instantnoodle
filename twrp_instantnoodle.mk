#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Omni stuff.
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from instantnoodle device
$(call inherit-product, device/oneplus/instantnoodle/device.mk)

PRODUCT_DEVICE := instantnoodle
PRODUCT_NAME := twrp_instantnoodle
PRODUCT_BRAND := oneplus
PRODUCT_MODEL := IN2013
PRODUCT_MANUFACTURER := oneplus

PRODUCT_GMS_CLIENTID_BASE := android-oneplus

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="instantnoodle-user 12 RKQ1.211119.001 1666953208969 release-keys"

BUILD_FINGERPRINT := oneplus/instantnoodle/instantnoodle:12/RKQ1.211119.001/1666953208969:user/release-keys
