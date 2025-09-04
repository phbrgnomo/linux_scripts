# Security Guidelines

## Overview

This repository contains shell scripts for Linux system automation. When using these scripts, especially with `curl | bash` patterns, please be aware of the security implications.

## Security Best Practices

### Before Running Any Script

1. **Always review the script content** before executing it:
   ```bash
   curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/<script_path> | less
   ```

2. **Download and inspect locally** before running:
   ```bash
   curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/<script_path> > script.sh
   cat script.sh  # Review the content
   chmod +x script.sh
   ./script.sh
   ```

3. **Use specific commit hashes** instead of `main` branch for production:
   ```bash
   curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/<commit_hash>/<script_path>
   ```

### Script-Specific Security Notes

#### install-ohmyzsh.sh
- Downloads and executes Oh My Zsh installation script from official source
- Downloads Oh My Posh via official installer
- Clones plugins from trusted GitHub repositories
- **Recommendation**: Review plugin sources before installation

#### github-cloneallrepos.sh
- Requires GitHub CLI authentication
- Accesses your GitHub repositories
- **Recommendation**: Run with limited GitHub token permissions

#### essential-debian.sh
- Requires sudo privileges for package installation
- Downloads and executes external scripts (Docker, Miniconda)
- **Recommendation**: Review each optional component before installation

#### Docker Installation Scripts
- Adds Docker's official GPG key and repository
- Adds user to docker group (security consideration)
- **Recommendation**: Understand docker group implications

## Reporting Security Issues

If you discover a security vulnerability, please report it responsibly:

1. **Do not** create a public issue
2. Email the repository owner directly
3. Provide detailed information about the vulnerability
4. Allow time for the issue to be addressed before public disclosure

## Security Validation

This repository includes a validation script (`validate_scripts.sh`) that checks for:
- Syntax errors
- Common security patterns
- Proper file permissions
- Shell script best practices

Run it locally to validate scripts:
```bash
./validate_scripts.sh
```

## Security Checklist for Contributors

When contributing new scripts:

- [ ] Use proper variable quoting (`"$variable"` instead of `$variable`)
- [ ] Validate user input
- [ ] Use `set -e` for error handling
- [ ] Avoid hardcoded paths or credentials
- [ ] Include proper error handling
- [ ] Document any external dependencies
- [ ] Test scripts in isolated environments
- [ ] Follow the principle of least privilege

## Known Security Considerations

1. **curl | bash patterns**: While convenient, they pose security risks if the source is compromised
2. **sudo usage**: Scripts require elevated privileges for system modifications
3. **External downloads**: Scripts download content from external sources
4. **User group modifications**: Some scripts add users to privileged groups

## Mitigation Strategies

1. **Pin specific versions** of external tools when possible
2. **Verify checksums** of downloaded content where available
3. **Use HTTPS** for all external downloads
4. **Implement proper error handling** to fail safely
5. **Log operations** for audit trails

## Updates and Maintenance

- Security-related updates will be documented in commit messages
- Critical security fixes will be prioritized
- Regular review of dependencies and external sources

---

**Remember**: Your security is your responsibility. Always review scripts before running them, especially with elevated privileges.