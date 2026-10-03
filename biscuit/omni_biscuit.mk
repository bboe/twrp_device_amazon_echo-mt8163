#
# Copyright (C) 2026 The Team Win Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, device/amazon/mt8163-echo/echo.mk)

PRODUCT_DEVICE := biscuit
PRODUCT_NAME := omni_biscuit
PRODUCT_MODEL := Echo Dot (2nd Gen)

PRODUCT_PROPERTY_OVERRIDES += ro.twrp.source=https://github.com/bboe/twrp_device_amazon_echo-mt8163
