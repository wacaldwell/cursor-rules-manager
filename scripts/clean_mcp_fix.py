#!/usr/bin/env python3
"""
Clean up and properly fix MCP server requirements in cursor rules files
"""

def clean_and_fix_mcp_section():
    # Read the original backup and apply clean replacements
    files_to_fix = [
        "environments/scripts/.cursorrules",
        "environments/projects/.cursorrules", 
        "templates/python-project.cursorrules",
        "templates/shell-scripts.cursorrules",
        "templates/terraform.cursorrules"
    ]
    
    # Correct MCP section content
    correct_mcp_section = """## MCP SERVER REQUIREMENTS - CRITICAL
- **AWS Operations**: When creating plans involving AWS, consult AWS MCP servers for guidance on:
  - Cost effectiveness and optimization recommendations
  - Security best practices and compliance requirements
  - Service selection and configuration best practices
  - This includes guidance for: EC2, S3, IAM, CloudFormation, Route53, and all other AWS services
- **Terraform Operations**: When creating infrastructure plans, consult HashiCorp's Terraform MCP servers for guidance on:
  - Cost effectiveness and resource optimization
  - Security configurations and best practices
  - Infrastructure design patterns and recommendations
  - This applies to all infrastructure-as-code planning and implementation"""
    
    for file_path in files_to_fix:
        try:
            with open(file_path, 'r') as f:
                content = f.read()
            
            # Find the MCP section and replace it
            lines = content.split('\n')
            new_lines = []
            in_mcp_section = False
            
            for line in lines:
                if line.strip() == "## MCP SERVER REQUIREMENTS - CRITICAL":
                    # Replace entire section
                    new_lines.extend(correct_mcp_section.split('\n'))
                    in_mcp_section = True
                elif in_mcp_section and line.strip() and not line.startswith('  ') and not line.startswith('- '):
                    # End of MCP section
                    in_mcp_section = False
                    new_lines.append(line)
                elif not in_mcp_section:
                    new_lines.append(line)
            
            with open(file_path, 'w') as f:
                f.write('\n'.join(new_lines))
            
            print(f"✓ Fixed {file_path}")
            
        except Exception as e:
            print(f"✗ Error fixing {file_path}: {e}")

if __name__ == "__main__":
    clean_and_fix_mcp_section()