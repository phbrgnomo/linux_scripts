#!/bin/bash

# Ask for the destination folder
read -p "Enter the destination folder path: " dest_folder

# Create public and private directories if they don't exist
mkdir -p "$dest_folder/public" "$dest_folder/private"

# List and clone repositories
gh repo list --limit 1000 | while IFS= read -r repo; do
  # Clean the repo line by removing extra whitespace
  cleaned_repo=$(echo "$repo" | awk '{$1=$1; print $1}')

  # Get repository information
  repo_info=$(gh repo view "$cleaned_repo" --json isPrivate,isFork -q '.isPrivate, .isFork')
  IFS=',' read -r is_private is_fork <<< "$repo_info"

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
      cd "$dest/$repo_name" || { echo "Failed to enter directory $repo_name"; continue; }

      # Pull latest changes and handle conflicts
      if ! git pull --quiet; then
        echo "Merge conflict detected in $repo_name. Aborting the merge and skipping this repository."
        git merge --abort  # Abort the merge to keep the repo clean
        echo "$repo_name has a merge conflict. Please resolve it manually." >> "$dest_folder/merge-conflicts.log"
      else
        echo "Successfully pulled latest changes for $repo_name."
      fi

      cd - > /dev/null || { echo "Failed to return to the previous directory"; }
    else
      echo "$repo_name already exists but is not a git repository. Skipping this repository."
    fi
  else
    # Clone the repo only if it doesn't exist
    gh repo clone "$cleaned_repo" "$dest/$repo_name" || { echo "Failed to clone $cleaned_repo"; continue; }
    cd "$dest/$repo_name" || { echo "Failed to enter directory $repo_name"; continue; }
    echo "Pulling latest changes for $repo_name..."
    git pull --quiet || { echo "Failed to pull for $repo_name"; }
    cd - > /dev/null || { echo "Failed to return to the previous directory"; }
  fi

  # Check if the repo is a fork
  if [ "$is_fork" = "true" ]; then
    echo "$repo_name is a fork."
  else
    echo "$repo_name is not a fork."
  fi
done
