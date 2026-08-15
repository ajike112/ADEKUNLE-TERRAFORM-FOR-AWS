
#!/bin/sh

echo "Add files and do local commit"
git add .
echo "checking status"
git status
git commit -am "updated terraform, provider, and resource blocks with EKS clsuter, internet gateway, route table and public subnets"

echo "Pushing to Github Repository"
git push -u origin master
