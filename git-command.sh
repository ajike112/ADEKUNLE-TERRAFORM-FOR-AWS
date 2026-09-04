
#!/bin/sh

echo "Add files and do local commit"
git add .
echo "checking status"
git status
git commit -am "updated ECS for Jenkins and Sonarqube to autoscale"

echo "Pushing to Github Repository"
git push -u origin master
