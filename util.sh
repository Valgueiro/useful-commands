UTIL_PATH="/home/mvalgueiro/personal/useful-commands"
source $UTIL_PATH/.env


setup-vim(){
	ln -fs $UTIL_PATH/dotfiles/.vimrc ~/.vimrc
}

setup-nvim(){
	ln -fs $UTIL_PATH/dotfiles/nvim ~/.config/nvim
}

setup-tmux(){
	ln -fs $UTIL_PATH/dotfiles/.tmux.conf ~/.tmux.conf
}

setup-nvm(){
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
	#nvm alias default node
	#nvm use --lts
}

setup-all(){
	setup-vim
	setup-tmux
	setup-nvim
	setup-nvm
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
# ansible
shell-ansible(){
	inventory_file=$1
	cmd=$2
	ansible -b -i $inventory_file all -m shell -a '$cmd'
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

decode-secret() {
	secret_name=$1
	namespace=$2
	key=$3
	kubectl -n $namespace get secrets $secret_name --template={{.data.$3}} | base64 -d
}


fix-logi-options(){
	kill -9 $(ps aux | grep "MacOS/logioptionsplus_agent" | grep -v grep | awk '{print $2}')
}

get-my-ip(){
	dig +short myip.opendns.com @resolver1.opendns.com
}

cheat(){
	# $1 command that you want to receive a cheatsheet from
	curl cheat.sh/$1 | less
}

zcode(){
	z $1 && code . && cd -
}


zvim(){
	z $1 && vim . && z -
}

run_always() {
	# empty
	echo "nothing to run"
}

# Exports
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export EDITOR=nvim
export KUBE_EDITOR=nvim
export NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/zscaler.crt

# My aliases
alias k="kubectl"
alias tf="terraform"
alias vim="nvim"
alias nv="nvim"
alias td="tmux detach"
alias ta="tmux attach -t 0"
alias python="python3"
## Mobral it to origin
alias git-mobral="git add . && git commit --amend --no-edit && git push -f"

## Clear branches that were deleted on origin
alias git-clean="git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '\$2 == \"[gone]\" {print \$1}' | xargs -r git branch -D"

## make which to work just like zsh
alias which="command -v"

# flux
alias frk="flux reconcile kustomization"
alias frsg="flux reconcile source git"
alias fsk="flux suspend kustomization"
alias frek="flux resume kustomization"

#run_always
