# Contributing to Robby

Robby is a great friend to us all!  To keep Robby running in tip-top shape,
we've introduced some basic contribution guidelines for community development.

## Making Changes

* Create a topic branch from where you want to base your work.
  * This is usually the master branch.
  * To quickly create a topic branch based on master, run `git checkout -b
    my_contribution master`. _Please avoid working directly on the
    `master` branch._
* Make commits of logical units.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Make sure your commit messages are well-formed.
  [This page](https://chris.beams.io/posts/git-commit/) provides some
  information on commit messages.
* Make sure you have added the necessary tests for your changes.
* Run _all_ the tests to assure nothing else was accidentally broken.
  This can be accomplished by running `./test.sh` from the Robby project root.

## Contribution Workflow

1. Check out the `puppetlabs/robby3` project
2. code code code
3. Submit a Pull Request
4. A Robby maintainer will review the pull request

## Community Guidelines

1. *Be nice.*  Robby is a joy to develop.  Let's do our best to celebrate contributions and create a positive environment that welcomes everyone.
   This includes leaving code cleaner than you found it by either cleaning up formatting, applying light refactors for readability, or removing dead code.

2. *Follow established conventions.*  Robby is up for adventure, but still must find the way home.  Let's avoid massive refactors or deviations from well-worn design patterns.

3. *Cover changes with unit tests.*  It's a scary world out there in production!  Better make sure Robby is ready to rumble before pushing out any changes.

4. *Tag repo admins on PRs for reviews.*  Robby is built from protected branches which require approval from repo admins.  This is to ensure we don't inadverently break Robby,
   which can make people sad.

5. *Have fun!*  There will be heinous consequences for those who do not delight in the excrutiating glory of Robby development.  Let thee be warned.
