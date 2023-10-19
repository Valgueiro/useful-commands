memento-timeout(){
        ## Add a bigger timeout to memento
        memento ssh-add
        memento preference -timeout 35999
}

process-by-port(){
        ## Show processes that are running on specific port
        ## $1 - port number
        sudo lsof -i -P -n | awk '/LISTEN/ && /'.$1.'/'
}

kill-process-by-port(){
        ## Kill processes that are running on specific port
        ## $1 - port number
	sudo kill -3 $(process-by-port $1 | awk '{print $2}') 
}

# K8s

force-delete-pod(){
        ## Force delete pods
        ## $1 - pod name
        ## $2 - namespace
	kubectl delete pod $1 --grace-period=0 --force --namespace $2	
}

delete-failed-pods(){
    kubectl delete pods  -A --field-selector status.phase=Failed
}

fix-logi-options(){
	kill -9 $(ps aux | grep "MacOS/logioptionsplus_agent" | grep -v grep | awk '{print $2}')
}

# My aliases

## Mobral it to origin
alias git-mobral="git add . && git commit --amend --no-edit && git push -f"

## Clear branches that were deleted on origin
alias git-clean="git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '\$2 == \"[gone]\" {print \$1}' | xargs -r git branch -D"
