# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See License.txt in the project root for license information.
# --------------------------------------------------------------------------------------------

# pylint: skip-file
# flake8: noqa

from azure.cli.core.aaz import register_client, AAZClientConfiguration
from azure.cli.core.aaz._client import AAZMgmtClient


@register_client("AppnetMgmtClient")
class AAZAppnetMgmtClient(AAZMgmtClient):
    """Custom management client for appnet that uses eastus2euap endpoint."""

    @classmethod
    def _build_base_url(cls, ctx, **kwargs):
        return "https://eastus2euap.management.azure.com"


__all__ = [
    "AAZAppnetMgmtClient",
]
