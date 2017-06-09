git checkout master
git clean -f -d
git pull
git branch -D mxbcoreprod
git subtree split --prefix products/mxberry-core --ignore-joins -b mxbcoreprod
git fetch mxberry-core
git checkout -B mxbcoremaster mxberry-core/master
git clean -f -d
git pull
git subtree merge -P products/mxberry-core --squash mxbcoreprod

