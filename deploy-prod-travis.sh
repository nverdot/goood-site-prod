echo "########## Récupération de la version en béta ##########"
wget http://beta.goood.pro/static/version.txt
versionBeta=$(cat version.txt);
echo "version récupérée de la béta : $versionBeta"
versionProd=$(cat version-prod.txt);
echo "version actuellement en production : $versionProd"
if [ "$versionBeta" != "$versionProd" ]
then
	echo "#### La version de production ne correspond pas à la version actuellement en béta #####"
	exit -1
fi
echo "#### La version correspond, récupération du tag ###"
commitmsg="auto-commit prod"
GITURLBETA=https://github.com/gooodhub/goood-site-dev.git
GITURL=https://github.com/gooodhub/goood-site-prod.git

echo "### Nettoyage du dossier beta si existant ###"
if [ -d "./beta" ]
then
	rm -rf beta
fi

echo "### Récupération de la version actuellement en beta ###"
git clone $GITURLBETA beta
cd beta
git checkout -b versionBeta tags/$versionBeta

if [ -d "./dist" ]
then
	rm -rf dist
fi
git clone -b gh-pages --single-branch $GITURL dist
cd dist
git checkout gh-pages
# ls -a | grep -v '^\.$' | grep -v '^\.\.$' | grep -v '^\.git$' | xargs rm -rf
mv .git ../gitdeploy
cd ..
npm install
NODE_ENV=production node index.js
cd dist
mv CNAME.PROD CNAME
rm CNAME.BETA
mv ../gitdeploy .git

echo "########## Configuration du repo ##########" 
TARGET_BRANCH="gh-pages"
SSH_REPO='git@github.com:gooodhub/goood-site-prod.git'

echo "########## Configuration du compte git pour commit ##########" 
git config user.email "cedric.burceaux@gmail.com"
git config user.name "nrgy"

echo "########## Ajout des données à commit ##########"
git add .
git commit -am "$commitmsg"

echo "########## Chiffrement des données ##########"
openssl aes-256-cbc -K $encrypted_1390a2280077_key -iv $encrypted_1390a2280077_iv -in deploy.enc -out deploy -d
chmod 600 deploy
eval "$(ssh-agent)"
ssh-add deploy

echo "########## Push des modifications ##########" 
# Now that we're all set up, we can push.
git push $SSH_REPO $TARGET_BRANCH --force
