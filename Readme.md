Install for ruby developer
command curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -sSL https://get.rvm.io | bash -s stable
curl -L --create-dirs -o ~/.config/fish/functions/rvm.fish https://raw.github.com/lunks/fish-nuggets/master/functions/rvm.fish
echo "rvm default" >> ~/.config/fish/config.fish
rvm install ruby-2.7.2
gem install solargraph

Install python 2,3 and pynvim

Install diagnostic language server
yarn global add diagnostic-languageserver
