# BeEF Test Suite

This directory contains the BeEF test suite using RSpec and SimpleCov for comprehensive testing and coverage reporting.

## Setup

### Prerequisites
- Ruby 3.0+
- Bundler
- All gems from `Gemfile`

### Configuration Files
- `spec/spec_helper.rb` - Main test configuration
- `.simplecov` - Coverage configuration
- `spec/support/` - Test helpers and utilities

## Running Tests

### Basic Commands

```bash
# Run all tests (fast, no coverage)
bundle exec rake short
# or
bundle exec rspec spec/ --tag '~run_on_browserstack' --tag '~run_on_long_tests'

# Run specific component tests
bundle exec rspec spec/beef/core/
bundle exec rspec spec/beef/extensions/
bundle exec rspec spec/beef/modules/
```

### Coverage Commands

```bash
# Complete coverage (recommended)
bundle exec rake coverage
# or
COVERAGE=all bundle exec rspec spec/ --tag '~run_on_browserstack' --tag '~run_on_long_tests'

# Component-specific coverage
bundle exec rake coverage_core        # Core only
bundle exec rake coverage_modules     # Modules only
bundle exec rake coverage_extensions  # Extensions only
```

### Legacy Commands (Still Supported)

```bash
# Old coverage commands still work
bundle exec rake coverage:modules
bundle exec rake coverage:all
bundle exec rake coverage_complete
```

## Architecture

### SimpleCov Configuration

- **Environment-based**: Uses `COVERAGE=core|modules|extensions|all` environment variable
- **Grouped reporting**: Separate groups for Core, Extensions, and Modules
- **Filtered tracking**: Only tracks relevant files based on focus area
- **HTML reports**: Generated in `coverage/` directory

### Test Organization

- **Centralized config**: `BeefTestConfig` module provides test data instead of global constants
- **Component isolation**: Each component (core/extensions/modules) has dedicated specs
- **Branch coverage**: Realistic test data for conditional logic testing
- **Mock management**: Proper mocking of external dependencies

### Rake Tasks

- **Clean separation**: Base `spec*` tasks vs coverage `coverage*` tasks
- **Environment variables**: Coverage controlled via `COVERAGE` env var
- **No sequential execution**: Single test runs with proper filtering
- **Backward compatibility**: Old task names still work

## Key Improvements

### ✅ **Eliminated Global Constants**
- Replaced `BRANCH_COVERAGE` constants with centralized `BeefTestConfig` module
- No more "already initialized constant" warnings

### ✅ **Simplified Coverage Logic**
- Cleaner filtering using `track_files` instead of complex `add_filter` logic
- Environment variable `COVERAGE` instead of `COVERAGE_FOCUS`

### ✅ **Better Test Organization**
- Centralized test configuration in `BeefTestConfig`
- Component-specific test data loading
- Reduced code duplication

### ✅ **Cleaner Rake Tasks**
- Single execution instead of sequential runs
- Proper environment variable usage
- Backward compatibility maintained

### ✅ **Standard Patterns**
- Uses `.simplecov` config file (standard practice)
- Follows RSpec best practices
- Better separation of concerns

## Coverage Focus Areas

- **core**: Framework core functionality
- **extensions**: Extension modules
- **modules**: Command modules (main focus)
- **all**: Complete coverage across all areas

## Troubleshooting

### Common Issues

1. **"already initialized constant" warnings**
   - Fixed by using centralized config instead of global constants

2. **Low coverage percentages**
   - Use `COVERAGE=all` for complete coverage
   - Ensure realistic test data triggers conditional paths

3. **Test failures**
   - Check that mocks are properly configured
   - Verify test data matches module expectations

### Debug Commands

```bash
# Run with debug output
bundle exec rspec --format documentation

# Run single test file
bundle exec rspec spec/beef/modules/browser/browser_spec.rb

# Check coverage report
open coverage/index.html
```

## Contributing

When adding new tests:

1. Use `BeefTestConfig.branch_coverage_for(:component)` for branch test data
2. Add realistic datastore values that trigger conditional logic
3. Mock external dependencies (database, network, etc.)
4. Follow existing patterns for consistency