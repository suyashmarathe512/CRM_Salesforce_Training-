# Goat Salesforce DX Project

## Project Overview

The **Goat** Salesforce DX project is a comprehensive training and development repository designed to demonstrate advanced Salesforce org configurations, customizations, and best practices. This project serves as a complete Salesforce organization setup, encompassing a wide range of metadata types and components that represent a fully-featured CRM implementation.

### Purpose and Scope

This repository is intended for:
- **Training and Learning**: Providing hands-on examples of Salesforce development, configuration, and deployment using Salesforce DX.
- **Development Reference**: Serving as a template for building complex Salesforce applications with multiple integrated features.
- **Testing Environment**: Offering a sandbox org with pre-configured components for testing customizations and integrations.

The org includes enterprise-level features such as automated processes, custom objects, Lightning components, communities, and extensive security configurations, making it suitable for demonstrating real-world Salesforce implementations.

### Key Characteristics

- **API Version**: 64.0 (latest Salesforce platform features)
- **Namespace**: Unmanaged (suitable for development and training)
- **Login URL**: Production Salesforce (https://login.salesforce.com)
- **Source Directory**: `force-app/main/default`

## Org Structure and Metadata

The Salesforce org is organized using the standard Salesforce DX project structure, with all metadata residing in the `force-app/main/default` directory. The org contains a comprehensive set of metadata types that cover all major Salesforce capabilities:

### Core Metadata Categories

#### Security and Access Management
- **Profiles and Permission Sets**: Custom security configurations for different user roles
- **Roles and Sharing Rules**: Hierarchical access control and data sharing mechanisms
- **Queues and Groups**: Work distribution and collaboration structures

#### Automation and Business Logic
- **Approval Processes**: Multi-step approval workflows for business processes
- **Assignment and Escalation Rules**: Automated case and lead routing
- **Workflows and Flows**: Declarative automation for business processes
- **Triggers and Apex Classes**: Custom business logic and data processing

#### User Interface and Experience
- **Applications and App Menus**: Custom app configurations and navigation
- **Lightning Components (Aura and LWC)**: Modern, responsive UI components
- **FlexiPages and Layouts**: Custom page layouts and record pages
- **Tabs and Navigation Menus**: Organized user navigation

#### Data Management
- **Custom Objects and Fields**: Extended data model with custom entities
- **Duplicate and Matching Rules**: Data quality and deduplication
- **Report Types**: Custom reporting structures

#### Communication and Integration
- **Email Services and Messaging Channels**: Inbound/outbound communication
- **Remote Site Settings**: External system integrations
- **Apex Email Notifications**: Automated email alerts

#### Communities and Portals
- **Communities and Networks**: Customer and partner portals
- **Sites and Site.com**: Public-facing websites
- **Audience Targeting**: Personalized content delivery

## Features and Components

### Custom Applications
- **Payroll System**: Specialized application for HR and payroll management
- **Warehouse**: Inventory and logistics management application
- Standard Salesforce applications (Sales, Service, Marketing, etc.)

### Automation Examples
- **Opportunity Approval Process**: Automated approval for opportunities over $5000
- **Lead Assignment Rules**: Intelligent lead distribution based on criteria
- **Case Escalation Rules**: Time-based case escalation for service management

### Custom Code Components
- **Apex Classes**: Business logic handlers, batch processes, and utility classes
  - Account and Contact trigger handlers
  - Batch jobs for data processing (duplicate cleanup, opportunity management)
  - REST API integrations and data transformations
- **Lightning Web Components**: Modern UI components for enhanced user experience
- **Aura Components**: Legacy Lightning components for backward compatibility

### Data Quality and Management
- Duplicate detection and prevention rules
- Data validation and transformation utilities
- Batch processing for large data operations

### Security and Compliance
- Comprehensive profile and permission set configurations
- Field-level security and data access controls
- Audit trail and compliance monitoring

## Development Setup

### Prerequisites

- [Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) (latest version)
- [Visual Studio Code](https://code.visualstudio.com/) with:
  - [Salesforce Extensions Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)
  - [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) for code formatting
- Node.js and npm (for package management and scripts)
- A Salesforce Developer Edition org or access to create Scratch Orgs

### Project Setup Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd CRM-Salesforce-Training
   ```

2. **Install Dependencies**
   ```bash
   npm install
   ```

3. **Authenticate to Salesforce**
   ```bash
   sfdx auth:web:login -a MyDevOrg
   ```

4. **Create a Scratch Org**
   ```bash
   sfdx force:org:create -s -f config/project-scratch-def.json -a GoatScratchOrg
   ```

5. **Push Source Code**
   ```bash
   sfdx force:source:push
   ```

6. **Assign Permission Sets (if needed)**
   ```bash
   sfdx force:user:permset:assign -n <PermissionSetName>
   ```

7. **Open the Org**
   ```bash
   sfdx force:org:open
   ```

8. **Load Sample Data (optional)**
   ```bash
   sfdx force:data:tree:import -p data/sample-data-plan.json
   ```

## Deployment and Retrieval

### Deploying to Non-Scratch Orgs

To deploy all metadata to a sandbox or production org:

```bash
sfdx force:source:deploy -p force-app -u <TargetOrgAlias>
```

For specific components:

```bash
sfdx force:source:deploy -m "ApexClass:AccountTriggerHandler,CustomObject:MyObject__c" -u <TargetOrgAlias>
```

### Retrieving Metadata

To retrieve all metadata from an org:

```bash
sfdx force:source:retrieve -p force-app -u <SourceOrgAlias>
```

For specific metadata types:

```bash
sfdx force:source:retrieve -m "ApexClass,CustomObject" -u <SourceOrgAlias>
```

### Package Creation and Installation

Create a package for distribution:

```bash
sfdx force:package:create -n "GoatPackage" -t Unlocked -r force-app
```

Install a package:

```bash
sfdx force:package:install -p <PackageId> -u <TargetOrgAlias>
```

## Best Practices and Workflow

### Development Workflow

1. **Feature Branching**: Create feature branches for new developments
   ```bash
   git checkout -b feature/new-component
   ```

2. **Scratch Org Development**: Use scratch orgs for isolated development
   ```bash
   sfdx force:org:create -f config/project-scratch-def.json -a feature-scratch
   ```

3. **Code Quality**: Run Apex tests before committing
   ```bash
   sfdx force:apex:test:run -c -r human
   ```

4. **Source Tracking**: Leverage source tracking for efficient deployments
   ```bash
   sfdx force:source:status
   ```

### Testing Strategy

- **Unit Tests**: Comprehensive Apex test classes for all custom logic
- **Integration Tests**: End-to-end testing of business processes
- **UI Tests**: Lightning component testing with Jest
- **Performance Testing**: Batch job and bulk data operation testing

### Code Quality Standards

- Follow Salesforce coding best practices
- Use Prettier for consistent code formatting
- Maintain test coverage above 75%
- Document complex business logic with comments

### Security Considerations

- Implement least privilege access principles
- Use named credentials for external integrations
- Regularly review and update security settings
- Monitor debug logs for performance and security issues

## Useful Links

### Official Salesforce Documentation
- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm)

### Development Resources
- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dev_guide.htm)
- [Lightning Web Components Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Salesforce Platform APIs](https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api.htm)

### Community and Support
- [Salesforce Developer Community](https://developer.salesforce.com/forums/)
- [Trailhead](https://trailhead.salesforce.com/) - Learning platform
- [Salesforce Stack Exchange](https://salesforce.stackexchange.com/)

## Support

### Getting Help

For questions, issues, or contributions:

1. **Check Existing Issues**: Search the repository's issue tracker for similar problems
2. **Create an Issue**: Open a new issue with detailed description and steps to reproduce
3. **Contact Maintainers**: Reach out to project maintainers for direct support

### Contributing

We welcome contributions to improve this training repository:

1. Fork the repository
2. Create a feature branch
3. Make your changes with proper testing
4. Submit a pull request with detailed description

### License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Last Updated**: [Current Date]
**Salesforce API Version**: 64.0
**Repository Version**: 1.0.0
