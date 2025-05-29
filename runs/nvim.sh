version="v0.11.1"
if [ ! -z $NVIM_VERSION ]; then
    version="$NVIM_VERSION"
fi

echo "version: \"$version\""

# neovim btw
if [ ! -d $HOME/neovim ]; then
    git clone https://github.com/neovim/neovim.git $HOME/neovim
fi

sudo apt -y install cmake gettext lua5.1 liblua5.1-0-dev

git -C $HOME/neovim fetch --all
git -C $HOME/neovim checkout $version

make -C $HOME/neovim clean
make -C $HOME/neovim CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make -C $HOME/neovim install

echo "Settin up dotfiles"
ln -fs $UTIL_PATH/dotfiles/nvim ~/.config/nvim
ln -fs $UTIL_PATH/dotfiles/.vimrc ~/.vimrc
