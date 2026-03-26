
#!/bin/sh

echo "Add files and do local commit"
git add .
echo "checking status"
git status
git commit -am "added terraform, provider, and resource blocks"

echo "Pushing to Github Repository"
git push