#
# Basic 5 window setup for rails environments
#
function railsdev() {
    WORKDIR=$1

    if [ -z "$WORKDIR" ]
    then
        WORKDIR=`pwd`
    fi

    cd $WORKDIR
 
    SESSION_NAME=`basename $WORKDIR` # | rev | cut -d "_" -f 1 | rev`

    tmux has-session -t ${SESSION_NAME}
 
    if [ $? != 0 ]
    then
        # Create the session - First window is bash
        tmux new-session -s ${SESSION_NAME} -c $WORKDIR -n bash -d
        
        # Emacs (1)
        tmux new-window -n editor -t ${SESSION_NAME}
        tmux send-keys -t ${SESSION_NAME}:2 'emacs' C-m
        
        # Logs (2)
        tmux new-window -n logs -t ${SESSION_NAME}
        tmux send-keys -t ${SESSION_NAME}:3 'tail -f log/development.log' C-m
        
        # rails console (3)
        tmux new-window -n console -t ${SESSION_NAME}
        tmux send-keys -t ${SESSION_NAME}:4 'bundle exec rails c' C-m
        
        # rails db (4)
        tmux new-window -n database -t ${SESSION_NAME}
        tmux send-keys -t ${SESSION_NAME}:5 'bundle exec rails db' C-m
        
        # Start out on the first window when we attach
        tmux select-window -t ${SESSION_NAME}:1
    fi

    echo ${SESSION_NAME}
}

#
# Basic two window setup, shell and editor
#
function basicdev() {
    WORKDIR=$1

    if [ -z "$WORKDIR" ]
    then
        WORKDIR=`pwd`
    fi

    cd $WORKDIR
    
    SESSION_NAME=`basename $WORKDIR` # | rev | cut -d "_" -f 1 | rev`
    
    tmux has-session -t ${SESSION_NAME}
    
    if [ $? != 0 ]
    then
        # Create the session - First window is bash
        tmux new-session -s ${SESSION_NAME} -c $WORKDIR -n bash -d
        
        # Emacs (1)
        tmux new-window -n editor -t ${SESSION_NAME}
        tmux send-keys -t ${SESSION_NAME}:2 'emacs' C-m
        
        # Start out on the first window when we attach
        tmux select-window -t ${SESSION_NAME}:1
    fi

    echo ${SESSION_NAME}
}
