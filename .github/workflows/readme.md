
When showing CI workflows in Kosli demos, there is a tension created
by the fact that cyber-dojo Flows are unusual in that they need to 
repeat every Kosli step twice; once to report to https://staging.app.kosli.com
and once again to report to https://app.kosli.com
A normal customer CI workflow yml file would only report to the latter.
To resolve this the workflow is split into two parts;
1) build.yml which builds the image and pushes it to its public dockerhub registry
2) aws_main.yml which is called twice;
   once from build.yml's kosli-staging: job, which reports only to https://staging.app.kosli.com
   once from build.yml's kosli-production: job, which reports only to https://app.kosli.com

While these workflows are being built, _no_ workflows run on a push. 
If you are doing a genuine (non CI) commit you will need to manually trigger old_main.yml
