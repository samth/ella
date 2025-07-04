# Contributing to Ella Framework

Thank you for your interest in contributing to Ella! We welcome contributions from everyone.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/ella.git`
3. Create a feature branch: `git checkout -b feature-name`
4. Make your changes
5. Test your changes
6. Submit a pull request

## Development Setup

### Prerequisites

- Racket 8.0 or later
- Git

### Installation

```bash
git clone https://github.com/your-username/ella.git
cd ella
raco pkg install --link
```

### Running Tests

```bash
raco test .
```

### Running Examples

```bash
cd examples
racket hello-world.rkt
```

## Code Guidelines

### Style

- Follow standard Racket formatting conventions
- Use descriptive variable and function names
- Add comments for complex logic
- Keep functions focused and small

### Documentation

- Document all public APIs
- Include examples in documentation
- Update API.md when adding new features
- Add examples for new features

### Testing

- Write tests for new features
- Ensure all existing tests pass
- Test with different Racket versions if possible
- Include both unit tests and integration tests

## Types of Contributions

### Bug Reports

When reporting bugs, please include:

- Racket version
- Operating system  
- Minimal reproduction case
- Expected vs actual behavior
- Error messages (if any)

### Feature Requests

For feature requests, please:

- Describe the use case
- Explain why it would be valuable
- Consider backward compatibility
- Provide examples if possible

### Code Contributions

We welcome:

- Bug fixes
- New features
- Performance improvements
- Documentation improvements
- Example applications
- Test improvements

## Pull Request Process

1. **Fork and Branch**: Create a feature branch from `main`
2. **Develop**: Make your changes following our guidelines
3. **Test**: Ensure all tests pass and add new tests
4. **Document**: Update documentation as needed
5. **Commit**: Use clear, descriptive commit messages
6. **Submit**: Create a pull request with a detailed description

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature  
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] All existing tests pass
- [ ] New tests added (if applicable)
- [ ] Manual testing completed

## Documentation
- [ ] API.md updated (if applicable)
- [ ] Examples added/updated (if applicable)
- [ ] Inline documentation added

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] No sensitive information in code
```

## Architecture

### Module Structure

```
ella/
├── lib/              # Core modules
│   ├── routing.rkt   # Route handling
│   ├── filters.rkt   # Before/after filters
│   ├── helpers.rkt   # Helper functions
│   ├── templates.rkt # Template system
│   ├── responses.rkt # Response handling
│   ├── errors.rkt    # Error handling
│   └── params.rkt    # Parameter parsing
├── main.rkt         # Legacy main module
├── main-new.rkt     # Modular main module
├── docs/            # Documentation
├── examples/        # Example applications
└── tests/           # Test suite
```

### Adding New Features

When adding new features:

1. Consider which module it belongs in
2. Add to the appropriate `lib/` module
3. Export from `main-new.rkt`
4. Update `API.md`
5. Add examples and tests
6. Update documentation

## Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers and answer questions
- Follow the Golden Rule

### Communication

- Use clear, descriptive language
- Be patient with questions
- Provide helpful feedback on PRs
- Celebrate contributions from others

## Release Process

1. Update version in `info.rkt`
2. Update CHANGELOG.md
3. Tag release: `git tag v1.x.x`
4. Push tags: `git push --tags`
5. Publish to package catalog

## Getting Help

- Check existing documentation
- Look at examples for patterns
- Ask questions in issues
- Join community discussions

## Recognition

Contributors will be:

- Added to AUTHORS file
- Mentioned in release notes
- Credited in documentation

Thank you for helping make Ella better!