
#!/bin/sh

echo "Add files and do local commit"
git add .
echo "checking status"
git status
git commit -am "updated the repo with ECR terraform scripts and dummy app codes to test CI"

echo "Pushing to Github Repository"
git push -u origin master
