# Security Policy

## Supported Versions

This template is actively maintained and we recommend always using the latest version.

| Version | Supported          |
| ------- | ------------------ |
| 6.1.x   | :white_check_mark: |
| 6.0.x   | :white_check_mark: |
| < 6.0   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in this Salesforce template, please report it responsibly.

### How to Report

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please report security issues via email to:

📧 **contact@beyondthecloud.dev**

### What to Include

When reporting a vulnerability, please include:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact
- Suggested fix (if you have one)
- Your contact information

### Response Timeline

- We will acknowledge receipt of your vulnerability report within **3 business days**
- We will provide a more detailed response within **7 business days**
- We will work with you to understand and address the issue
- We will notify you when the vulnerability has been fixed

### Responsible Disclosure

We appreciate responsible disclosure and will:

- Keep you informed about our progress
- Credit you in the fix (if you wish)
- Work to address the issue as quickly as possible

## Security Best Practices

When using this template:

### Salesforce Security

- **Never commit credentials** - Use `.gitignore` for sensitive files
- **Use scratch org URLs** - Rotate Dev Hub auth URLs regularly
- **Review permissions** - Implement proper sharing and FLS checks
- **Validate input** - Prevent SOQL injection and XSS
- **Use secrets management** - Store GitHub secrets securely

### Code Quality

- Run security checks: `npm run lint`
- Review dependencies: `npm audit`
- Keep dependencies updated: `npm update`
- Use pre-commit hooks (Husky)

### CI/CD Security

- **Protect GitHub secrets** - Limit access to `SFDX_AUTH_URL_DEVHUB`
- **Branch protection** - Enable branch protection on `main`
- **Review workflows** - Audit GitHub Actions regularly
- **Limit permissions** - Use minimal required permissions

## Security Resources

- [Salesforce Security Guide](https://developer.salesforce.com/docs/atlas.en-us.secure_coding_guide.meta/secure_coding_guide/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)

## Contact

For security concerns, contact:

**Beyond The Cloud Sp. z o.o.**

- Email: contact@beyondthecloud.dev
- Website: [beyondthecloud.dev](https://beyondthecloud.dev)

---

Thank you for helping keep this template and its users safe! 🔒
