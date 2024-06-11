#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Release name
PRODUCT_RELEASE_NAME := instantnoodle

# Inherit from our custom product configuration
$(call inherit-product, vendor/twrp/config/common.mk)

PRODUCT_DEVICE := $(PRODUCT_RELEASE_NAME)
PRODUCT_NAME := twrp_$(PRODUCT_DEVICE)
PRODUCT_BRAND := OnePlus
PRODUCT_MODEL := IN2013
PRODUCT_MANUFACTURER := oneplus

# Inherit from instantnoodle device
$(call inherit-product, device/$(PRODUCT_MANUFACTURER)/$(PRODUCT_DEVICE)/device.mk)