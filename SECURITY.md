# Security Policy

## Supported versions

Security fixes are released for the latest 2.x release.

| Version | Supported          |
| ------- | ------------------ |
| 2.9.x   | :white_check_mark: |
| < 2.9   | :x:                |

Every 2.x release is a safe upgrade from any earlier 2.x version. New parsing
behavior ships behind opt-in profiles, so existing defaults are unchanged. If
you are on an older release, upgrade to the latest 2.x before reporting.

## Reporting a vulnerability

Please do not report security issues through public GitHub issues.

Instead, [report a vulnerability privately](https://github.com/savonrb/nori/security/advisories/new)
through GitHub. You will get an acknowledgement within 7 days. Please keep the
report confidential until a fix is released.

## Scope

This policy covers the nori gem, the response parser used by the savon SOAP
client. For issues in another gem in the family (akami, gyoku, httpi, savon,
wasabi), report to the affected repository in the
[savonrb organization](https://github.com/savonrb). If you are not sure which
gem is affected, report it here.
