#!/usr/bin/env python3
"""
Script to fix MCP server requirements in cursor rules files
"""

import re

def fix_mcp_requirements(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Find and replace the MCP SERVER REQUIREMENTS section
    old_section = r"""- \*\*AWS Operations\*\*: ALL AWS-related decisions, commands, and operations MUST be executed through AWS MCP servers
  - Use AWS MCP tools for all AWS CLI commands, resource queries, and configuration changes
  - Never execute AWS operations directly - always route through MCP servers
  - This includes: EC2, S3, IAM, CloudFormation, Route53, and all other AWS services
- \*\*Terraform Operations\*\*: ALL Terraform-related decisions and operations MUST be executed through Terraform MCP servers
  - Use Terraform MCP tools for plan, apply, destroy, and state management
  - Never execute terraform commands directly - always route through MCP servers
  - This applies to all infrastructure-as-code operations"""
    
    new_section = """- **AWS Operations**: When creating plans involving AWS, consult AWS MCP servers for guidance on:
  - Cost effectiveness and optimization recommendations
  - Security best practices and compliance requirements
  - Service selection and configuration best practices
  - This includes guidance for: EC2, S3, IAM, CloudFormation, Route53, and all other AWS services
- **Terraform Operations**: When creating infrastructure plans, consult HashiCorp's Terraform MCP servers for guidance on:
  - Cost effectiveness and resource optimization
  - Security configurations and best practices
  - Infrastructure design patterns and recommendations
  - This applies to all infrastructure-as-code planning and implementation"""
    
    content = re.sub(old_section, new_section, content)
    
    with open(file_path, 'w') as f:
        f.write(content)
    
    print(f"Updated {file_path}")

if __name__ == "__main__":
    files_to_fix = [
        "environments/scripts/.cursorrules",
        "environments/projects/.cursorrules", 
        "templates/python-project.cursorrules",
        "templates/shell-scripts.cursorrules",
        "templates/terraform.cursorrules"
    ]
    
    for file_path in files_to_fix:
        try:
            fix_mcp_requirements(file_path)
        except Exception as e:
            print(f"Error fixing {file_path}: {e}")