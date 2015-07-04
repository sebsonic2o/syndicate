# Syndicate

Syndicate is an experimental voting app where voters use either direct or representative democracy to vote on individual issues. The first MVP of Syndicate was built in 1 week.

* [Heroku Test Server](http://dbc-syndicate-test.herokuapp.com)
* [Heroku Production Server](http://dbc-syndicate.herokuapp.com)

## Git Workflow

0. Working on your local feature branch you have added and committed your changes locally
1. git fetch origin test-master
2. git merge origin/test-master
3. resolve conflicts (call team mate to help)
4. TEST the application locally
5. git push origin feature-branch
6. create pull request on github from feature-branch to test-master
7. wait for another member of the team to merge pull request


## ENV File

Remember to re-create your .env file locally otherwise you will not be able to access firebase.

* create a .env file "touch .env" - in the root of the project
* add the line FIREBASE_URL=https://your-firebase-url.firebaseio.com/


![Our Schema](schema.png)
