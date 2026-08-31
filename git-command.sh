
#!/bin/sh

echo "Add files and do local commit"
git add .
echo "checking status"
git status
git commit -am "updated the repo with SonarQube terraform scripts and Jenkinsfile"

echo "Pushing to Github Repository"
git push -u origin master
