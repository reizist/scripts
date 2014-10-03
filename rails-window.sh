SESSION_NAME="rails/"$1
DEFAULT_WINDOW_NAME="zsh"
GIT="git"
CONSOLE="console"
SERVER="server"
ROOT_DIR="~/rails_project/"$1

# new-session
tmux new-session -d -s $SESSION_NAME -n $DEFAULT_WINDOW_NAME
tmux new-window -k -d -t $SESSION_NAME:1 -n $DEFAULT_WINDOW_NAME
tmux new-window -k -d -t $SESSION_NAME:2 -n $CONSOLE
tmux new-window -k -d -t $SESSION_NAME:3 -n $SERVER
tmux new-window -k -d -t $SESSION_NAME:4 -n $GIT

# split window
#tmux split-window -v -t $SESSION_NAME

for i in $DEFAULT_WINDOW_NAME $GIT $CONSOLE $SERVER
do
  tmux send-keys -t $SESSION_NAME:$i "cd $ROOT_DIR" C-m
done

# for console window
tmux send-keys -t $SESSION_NAME:$CONSOLE "rails c" C-m
# for server window
tmux send-keys -t $SESSION_NAME:$SERVER "rails s" C-m
# for git window
tmux send-keys -t $SESSION_NAME:$GIT "tig" C-m

tmux select-window -t $SESSION_NAME:$DEFAULT_WINDOW_NAME

# 作成されたセッションにアタッチ
tmux attach-session -t $SESSION_NAME
