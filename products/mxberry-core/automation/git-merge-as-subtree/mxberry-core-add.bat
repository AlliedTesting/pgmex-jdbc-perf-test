git checkout master
git clean -f -d
git pull
git remote add -f mxberry-core https://github.com/pgagarinov/mxberry-core.git
git checkout -B mxbcoremaster mxberry-core/master
git clean -f -d
git subtree split -P products/mxberry-core --ignore-joins -b mxbcoreprod
git checkout master
git clean -f -d
git subtree add -P products/mxberry-core --squash mxbcoreprod
