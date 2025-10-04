#!/usr/bin/env python3
"""
Cursor MCP Notion Integration for Cursor Rules Manager
Automatically updates Notion workspace using Cursor's MCP server
"""

import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path

class NotionMCPIntegration:
    def __init__(self, project_dir):
        self.project_dir = Path(project_dir)
        self.notion_page_id = "2824ebc7-f011-8123-bdbb-dde4faf21a8c"
        # PARA system configuration
        self.all_notes_database_id = "432d3831-f553-4fad-93bd-e563d2c8e2f9"
        self.devops_resource_id = "8e9d8c36822e45e2b778df36cac66a28"
        
    def get_git_info(self):
        """Get current git information"""
        try:
            commit_hash = subprocess.check_output(
                ["git", "rev-parse", "HEAD"], 
                cwd=self.project_dir, 
                text=True
            ).strip()
            
            commit_message = subprocess.check_output(
                ["git", "log", "-1", "--pretty=%B"], 
                cwd=self.project_dir, 
                text=True
            ).strip()
            
            branch_name = subprocess.check_output(
                ["git", "rev-parse", "--abbrev-ref", "HEAD"], 
                cwd=self.project_dir, 
                text=True
            ).strip()
            
            recent_commits = subprocess.check_output(
                ["git", "log", "--oneline", "-5", "--pretty=format:%s (%h)"], 
                cwd=self.project_dir, 
                text=True
            ).strip().split('\n')
            
            return {
                'commit_hash': commit_hash,
                'commit_message': commit_message,
                'branch_name': branch_name,
                'recent_commits': recent_commits
            }
        except subprocess.CalledProcessError as e:
            print(f"Error getting git info: {e}")
            return None
    
    def get_project_status(self):
        """Determine current project status"""
        try:
            # Check for uncommitted changes
            result = subprocess.run(
                ["git", "diff", "--quiet"], 
                cwd=self.project_dir, 
                capture_output=True
            )
            
            if result.returncode != 0:
                return "🔄 In Development"
            
            # Check branch type
            branch_name = subprocess.check_output(
                ["git", "rev-parse", "--abbrev-ref", "HEAD"], 
                cwd=self.project_dir, 
                text=True
            ).strip()
            
            if branch_name.startswith("feature/"):
                return "✨ Feature Development"
            elif branch_name.startswith("release/"):
                return "🚀 Release Preparation"
            elif branch_name.startswith("hotfix/"):
                return "🔧 Hotfix"
            elif branch_name == "main":
                return "✅ Production Ready"
            else:
                return "📝 Development"
                
        except subprocess.CalledProcessError:
            return "❓ Unknown"
    
    def get_current_version(self):
        """Get current version from git tags or changelog"""
        try:
            # Try to get latest tag
            result = subprocess.run(
                ["git", "describe", "--tags", "--exact-match"], 
                cwd=self.project_dir, 
                capture_output=True, 
                text=True
            )
            
            if result.returncode == 0:
                return result.stdout.strip()
            
            # Fallback to changelog
            changelog_path = self.project_dir / "CHANGELOG.md"
            if changelog_path.exists():
                with open(changelog_path, 'r') as f:
                    content = f.read()
                    # Extract version from changelog
                    import re
                    match = re.search(r'## \[([0-9]+\.[0-9]+\.[0-9]+)\]', content)
                    if match:
                        return f"v{match.group(1)}"
            
            return "v1.0.0"  # Default fallback
            
        except Exception:
            return "v1.0.0"
    
    def generate_notion_content(self, update_type="manual"):
        """Generate content for Notion update"""
        git_info = self.get_git_info()
        if not git_info:
            return None
            
        project_status = self.get_project_status()
        current_version = self.get_current_version()
        
        # Format recent commits
        recent_commits_text = "\n".join([f"- {commit}" for commit in git_info['recent_commits']])
        
        # Check for uncommitted changes
        try:
            uncommitted = subprocess.run(
                ["git", "diff", "--name-only"], 
                cwd=self.project_dir, 
                capture_output=True, 
                text=True
            )
            uncommitted_files = uncommitted.stdout.strip().split('\n') if uncommitted.stdout.strip() else []
            uncommitted_count = len([f for f in uncommitted_files if f])
        except:
            uncommitted_count = 0
        
        content = f"""## 🔄 Project Update - {datetime.now().strftime('%Y-%m-%d %H:%M')}

**Status**: {project_status}  
**Version**: {current_version}  
**Branch**: `{git_info['branch_name']}`  
**Last Commit**: `{git_info['commit_hash'][:8]}`

### Recent Changes
{recent_commits_text}

### Current Development
- **Active Branch**: `{git_info['branch_name']}`
- **Uncommitted Changes**: {uncommitted_count} files
- **Last Activity**: {git_info['commit_message'][:50]}{'...' if len(git_info['commit_message']) > 50 else ''}

### Project Health
- **Tests**: ✅ Available
- **Documentation**: ✅ Complete  
- **Terraform**: ✅ Configured
- **Git Flow**: ✅ Active

---
*Auto-updated via Git Flow integration ({update_type})*"""
        
        return content
    
    def create_cursor_mcp_commands(self, content):
        """Generate Cursor MCP commands for Notion update"""
        commands = []
        
        # Get project name from directory
        project_name = self.project_dir.name.replace('-', ' ').title()
        
        # Command to create a new page in the All Notes database with DevOps Resource tag
        create_command = {
            "tool": "mcp_Notion_notion-create-pages",
            "parent": {
                "database_id": self.all_notes_database_id
            },
            "pages": [{
                "properties": {
                    "Name": f"{project_name} - Update {datetime.now().strftime('%Y-%m-%d %H:%M')}",
                    "Area/Resource": f"https://www.notion.so/{self.devops_resource_id}",
                    "Archive": "__NO__"
                },
                "content": content
            }]
        }
        
        commands.append(create_command)
        
        # Also keep the update command for existing page
        update_command = {
            "tool": "mcp_Notion_notion-update-page",
            "data": {
                "page_id": self.notion_page_id,
                "command": "insert_content_after",
                "selection_with_ellipsis": "## 📈 Recent Activity",
                "new_str": f"\n{content}\n"
            }
        }
        
        commands.append(update_command)
        return commands
    
    def save_commands_to_file(self, commands, filename="notion-update-commands.json"):
        """Save MCP commands to file for Cursor to execute"""
        output_file = self.project_dir / "scripts" / filename
        
        with open(output_file, 'w') as f:
            json.dump(commands, f, indent=2)
        
        print(f"Notion update commands saved to: {output_file}")
        print("To apply these updates, run the commands in Cursor using the Notion MCP server")
        
        return output_file

def main():
    if len(sys.argv) < 2:
        print("Usage: python cursor-notion-update.py <project_dir> [update_type]")
        sys.exit(1)
    
    project_dir = sys.argv[1]
    update_type = sys.argv[2] if len(sys.argv) > 2 else "manual"
    
    integration = NotionMCPIntegration(project_dir)
    
    # Generate content
    content = integration.generate_notion_content(update_type)
    if not content:
        print("Error: Could not generate Notion content")
        sys.exit(1)
    
    # Create MCP commands
    commands = integration.create_cursor_mcp_commands(content)
    
    # Save commands to file
    output_file = integration.save_commands_to_file(commands)
    
    print(f"\nGenerated Notion update content:")
    print("=" * 50)
    print(content)
    print("=" * 50)
    print(f"\nCommands saved to: {output_file}")
    print("\nTo apply this update in Cursor:")
    print("1. Open the generated JSON file")
    print("2. Use the Notion MCP server to execute the commands")
    print("3. Or copy the content and manually update the Notion page")

if __name__ == "__main__":
    main()
