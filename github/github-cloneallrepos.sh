#!/bin/bash

# Color codes
RED='\033[0;31m'    # Red color for errors
GREEN='\033[0;32m'  # Green color for successes
YELLOW='\033[1;33m' # Yellow color for progress
NC='\033[0m'        # No color (reset)

# Check if a destination folder argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <destination_folder>"
  exit 1
fi

# Set the destination folder from the command line argument
dest_folder="$1"

# Create public and private directories if they don't exist
mkdir -p "$dest_folder/public" "$dest_folder/private"

# Log file for unsuccessful operations
log_file="$dest_folder/operation_log.log"
echo "Creating log file..."
echo "Operation Log - $(date)" > "$log_file"

# Count the total number of repositories
total_repos=$(gh repo list --limit 1000 | wc -l)

# Check if any repositories were found
if [ "$total_repos" -eq 0 ]; then
  echo -e "${RED}No repositories found.${NC}"
  exit 0
fi

echo "Found $total_repos repositories."

# Initialize progress counter
progress=0

# List and clone repositories
gh repo list --limit 1000 | while IFS= read -r repo; do
  # Clean the repo line by removing extra whitespace
  cleaned_repo=$(echo "$repo" | awk '{$1=$1; print $1}')

  # Check if the remote repo exists by using `gh repo view` to confirm
  if ! gh repo view "$cleaned_repo" &> /dev/null; then
    echo -e "${RED}Remote repository $cleaned_repo has been deleted or does not exist.${NC}" | tee -a "$log_file"
    progress=$((progress + 1))
    printf "\r${YELLOW}Progress: [%d/%d]${NC}\n" "$progress" "$total_repos"
    continue  # Skip this repository and move to the next
  fi

  # Get repository information
  repo_info=$(gh repo view "$cleaned_repo" --json isPrivate,isFork -q '.isPrivate, .isFork')
  IFS=',' read -r is_private <<< "$repo_info"

  # Set the appropriate destination folder
  if [ "$is_private" = "true" ]; then
    echo "Cloning private repo $cleaned_repo..."
    dest="$dest_folder/private"
  else
    echo "Cloning public repo $cleaned_repo..."
    dest="$dest_folder/public"
  fi

  # Extract the repo name from the cleaned repo
  repo_name=$(basename "$cleaned_repo")

  # Check if the directory already exists
  if [ -d "$dest/$repo_name" ]; then
    echo "$repo_name already exists in $dest. Pulling latest changes..."

    # Check if it is indeed a git repository
    if [ -d "$dest/$repo_name/.git" ]; then
      cd "$dest/$repo_name" || { echo -e "${RED}Failed to enter directory $repo_name${NC}" | tee -a "$log_file"; continue; }

      # Pull latest changes and capture the output
      pull_output=$(git pull --quiet 2>&1)
      pull_status=$?

      if [ $pull_status -ne 0 ]; then
        echo -e "${RED}Error pulling changes for $repo_name: $pull_output${NC}" | tee -a "$log_file"
        
        # Check for merge conflicts
        if [[ "$pull_output" == *"CONFLICT"* ]]; then
          echo -e "${RED}Merge conflict detected in $repo_name. Please resolve it manually.${NC}" | tee -a "$log_file"
          git merge --abort  # Abort the merge to keep the repo clean
          echo "$repo_name has a merge conflict. Please resolve it manually." >> "$log_file"
        else
          echo -e "${RED}An error occurred while pulling for $repo_name: $pull_output${NC}" | tee -a "$log_file"
        fi
      else
        echo -e "${GREEN}Successfully pulled latest changes for $repo_name.${NC}"
      fi

      cd - > /dev/null || { echo -e "${RED}Failed to return to the previous directory${NC}" | tee -a "$log_file"; }
    else
      echo -e "${RED}$repo_name already exists but is not a git repository. Skipping this repository.${NC}" | tee -a "$log_file"
    fi
  else
    # Clone the repo only if it doesn't exist
    clone_output=$(gh repo clone "$cleaned_repo" "$dest/$repo_name" 2>&1)
    clone_status=$?

    if [ $clone_status -ne 0 ]; then
      echo -e "${RED}Failed to clone $cleaned_repo: $clone_output${NC}" | tee -a "$log_file"
      progress=$((progress + 1))
      printf "\r${YELLOW}Progress: [%d/%d]${NC}\n" "$progress" "$total_repos"
      continue
    fi

    cd "$dest/$repo_name" || { echo -e "${RED}Failed to enter directory $repo_name${NC}"; continue; }
    echo "Pulling latest changes for $repo_name..."
    
    pull_output=$(git pull --quiet 2>&1)
    if [ $? -ne 0 ]; then
      echo -e "${RED}Failed to pull for $repo_name: $pull_output${NC}" | tee -a "$log_file"
    else
      echo -e "${GREEN}Successfully pulled latest changes for $repo_name.${NC}"
    fi

    cd - > /dev/null || { echo -e "${RED}Failed to return to the previous directory${NC}" | tee -a "$log_file"; }
  fi

  # Update the progress
  progress=$((progress + 1))
  printf "\r${YELLOW}Progress: [%d/%d]${NC}\n" "$progress" "$total_repos"

done

# Print newline after progress completion
printf "\r${YELLOW}Progress: [%d/%d]${NC}\n" "$total_repos" "$total_repos"
echo -e "${GREEN}Done!${NC}"
