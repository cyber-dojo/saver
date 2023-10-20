
When showing CI workflows in Kosli demos, there is a tension created
by the fact that cyber-dojo Flows are unusual in that they need to 
repeat every Kosli step twice; once to report to https://staging.app.kosli.com
and once again to report to https://app.kosli.com
A normal customer CI workflow yml file would only report to the latter.
To resolve this the core workflow (currently called main_WIP.yml)
has been designed to accept the KOSLI_HOST as a on:workflow_call:input
and there will be two workflow yml files; one to run the core workflow
with KOSLI_HOST set to https://staging.app.kosli.com, and one to run
the core workflow with KOSLI_HOST set to https://app.kosli.com